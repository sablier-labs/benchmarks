// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierComptroller } from "@sablier/evm-utils/src/interfaces/ISablierComptroller.sol";
import { BaseUtils } from "@sablier/evm-utils/src/tests/BaseUtils.sol";
import { ISablierBatchLockup } from "@sablier/lockup/src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";
import { Lockup } from "@sablier/lockup/src/types/Lockup.sol";
import { Defaults } from "@sablier/lockup/tests/utils/Defaults.sol";
import { Users } from "@sablier/lockup/tests/utils/Types.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

/// @notice Base contract with common logic needed to get gas benchmarks for Lockup streams.
abstract contract LockupBenchmark is BaseUtils, StdCheats {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal immutable AMOUNT_PER_SEGMENT = 100e18;
    uint128 internal immutable AMOUNT_PER_TRANCHE = 100e18;

    /// @dev The directory where the benchmark files are stored.
    string internal RESULTS_DIR = "results/lockup/";

    /// @dev The name of the file where the benchmark results are stored. Each derived contract must set this.
    string internal RESULTS_FILE;

    /// @dev A variable used to store the content to append to the results file.
    string internal contentToAppend;

    /// @dev Minimum fee requires to withdraw from Lockup streams.
    uint256 internal minFeeWei;

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ISablierBatchLockup internal batchLockup;
    Defaults internal defaults;
    ISablierLockup internal lockup;
    IERC20 internal usdc;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        logBlue("Setting up Lockup benchmarks...");

        // Fork Ethereum Mainnet at the latest block.
        vm.createSelectFork({ urlOrAlias: "ethereum" });
        logGreen("Forked Ethereum Mainnet");

        // Load deployed addresses from Ethereum mainnet.
        // See https://docs.sablier.com/guides/lockup/deployments
        batchLockup = ISablierBatchLockup(0x0636D83B184D65C242c43de6AAd10535BFb9D45a);
        lockup = ISablierLockup(0xcF8ce57fa442ba50aCbC57147a62aD03873FfA73);
        logGreen("Loaded Sablier contracts");

        // Load USDC token.
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        logGreen("Loaded USDC token contract");

        // Create test users and deal USDC to them.
        users.alice = payable(makeAddr("alice"));
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));
        logGreen("Created test users");

        deal({ token: address(usdc), to: users.sender, give: type(uint128).max });

        setMsgSender(users.sender);
        usdc.approve(address(batchLockup), type(uint128).max);
        usdc.approve(address(lockup), type(uint128).max);
        logGreen("Funded USDC and approved contracts");

        defaults = new Defaults();
        defaults.setToken(usdc);
        defaults.setUsers(users);

        // Create test streams.
        _setUpStreams();
        logGreen("Created test streams");
        logBlue("Setup complete! Ready to run benchmarks.");

        // Set value for minFeeWei.
        minFeeWei = lockup.comptroller().calculateMinFeeWei({ protocol: ISablierComptroller.Protocol.Lockup });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SHARED LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_Burn(uint256 streamId) internal returns (uint256 gasUsed) {
        setMsgSender(users.recipient);
        // Warp to the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) });

        lockup.withdrawMax{ value: minFeeWei }(streamId, users.recipient);

        uint256 initialGas = gasleft();
        lockup.burn(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Cancel(uint256 streamId) internal returns (uint256 gasUsed) {
        setMsgSender(users.sender);

        // Warp to right before the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) - 1 seconds });

        uint256 initialGas = gasleft();
        lockup.cancel(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Renounce(uint256 streamId) internal returns (uint256 gasUsed) {
        setMsgSender(users.sender);
        // Warp to halfway through the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) / 2 });

        uint256 initialGas = gasleft();
        lockup.renounce(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Withdraw(uint256 streamId, address caller) internal returns (uint256 gasUsed) {
        setMsgSender(caller);

        uint128 withdrawAmount = lockup.withdrawableAmountOf(streamId);
        if (withdrawAmount == 0) {
            revert(string.concat("Withdraw amount is 0 for stream ", vm.toString(streamId)));
        }

        uint256 initialGas = gasleft();
        lockup.withdraw{ value: minFeeWei }(streamId, users.recipient, withdrawAmount);
        gasUsed = initialGas - gasleft();
    }

    function instrument_WithdrawCompleted(
        uint256 streamId,
        address caller
    )
        internal
        returns (uint256 gasUsed, string memory config)
    {
        // Warp to right past the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) + 1 seconds });

        gasUsed = instrument_Withdraw(streamId, caller);

        if (caller == users.recipient) {
            config = "vesting completed && called by recipient";
        } else {
            config = "vesting completed && called by third-party";
        }
    }

    function instrument_WithdrawOngoing(
        uint256 streamId,
        address caller
    )
        internal
        returns (uint256 gasUsed, string memory config)
    {
        // Warp to right before the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) - 1 seconds });
        gasUsed = instrument_Withdraw(streamId, caller);

        if (caller == users.recipient) {
            config = "vesting ongoing && called by recipient";
        } else {
            config = "vesting ongoing && called by third-party";
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Private function to create one stream with each model. These streams will help in initializing the state
    /// variables.
    function _setUpStreams() private {
        Lockup.CreateWithTimestamps memory params = defaults.createWithTimestamps();
        lockup.createWithTimestampsLD({ params: params, segments: defaults.segments() });
        lockup.createWithTimestampsLL({
            params: params,
            unlockAmounts: defaults.unlockAmounts(),
            cliffTime: defaults.CLIFF_TIME()
        });
        lockup.createWithTimestampsLT({ params: params, tranches: defaults.tranches() });
    }
}
