// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierBatchLockup } from "@sablier/lockup/src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";
import { Defaults } from "@sablier/lockup/tests/utils/Defaults.sol";
import { Lockup } from "@sablier/lockup/src/types/DataTypes.sol";
import { Users } from "@sablier/lockup/tests/utils/Types.sol";
import { Utils } from "@sablier/lockup/tests/utils/Utils.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Logger } from "../Logger.sol";

/// @notice Base contract with common logic needed to get gas benchmarks for Lockup streams.
abstract contract LockupBenchmark is Logger, StdCheats, Utils {
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
        vm.createSelectFork({ urlOrAlias: "mainnet" });

        uint256 chainId = block.chainid;
        if (chainId != 1) {
            revert("Benchmarking only works on Ethereum Mainnet. Update your RPC URL in .env");
        }
        logGreen("Forked Ethereum Mainnet");

        // Load deployed addresses from Ethereum mainnet.
        // See https://docs.sablier.com/guides/lockup/deployments
        batchLockup = ISablierBatchLockup(0x3F6E8a8Cffe377c4649aCeB01e6F20c60fAA356c);
        lockup = ISablierLockup(0x7C01AA3783577E15fD7e272443D44B92d5b21056);
        logGreen("Loaded Sablier contracts");

        // Load USDC token.
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        logGreen("Loaded USDC token contract");

        // Create some users.
        users.alice = payable(makeAddr("alice"));
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));
        logGreen("Created test users");

        deal({ token: address(usdc), to: users.sender, give: type(uint128).max });
        resetPrank({ msgSender: users.sender });
        usdc.approve(address(batchLockup), type(uint128).max);
        usdc.approve(address(lockup), type(uint128).max);
        logGreen("Funded and approved USDC");

        defaults = new Defaults();
        defaults.setToken(usdc);
        defaults.setUsers(users);

        _setUpStreams();
        logGreen("Created test streams");
        logBlue("Setup complete! Ready to run benchmarks.");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SHARED LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_Burn(uint256 streamId) internal returns (uint256 gasUsed) {
        resetPrank({ msgSender: users.recipient });
        // Warp to the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) });

        lockup.withdrawMax(streamId, users.recipient);

        uint256 initialGas = gasleft();
        lockup.burn(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Cancel(uint256 streamId) internal returns (uint256 gasUsed) {
        resetPrank({ msgSender: users.sender });
        // Warp to right before the end of the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) - 1 seconds });

        uint256 initialGas = gasleft();
        lockup.cancel(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Renounce(uint256 streamId) internal returns (uint256 gasUsed) {
        resetPrank({ msgSender: users.sender });
        // Warp to halfway through the stream.
        vm.warp({ newTimestamp: lockup.getEndTime(streamId) / 2 });

        uint256 initialGas = gasleft();
        lockup.renounce(streamId);
        gasUsed = initialGas - gasleft();
    }

    function instrument_Withdraw(uint256 streamId, address caller) internal returns (uint256 gasUsed) {
        resetPrank({ msgSender: caller });

        uint128 withdrawAmount = lockup.withdrawableAmountOf(streamId);
        if (withdrawAmount == 0) {
            revert(string.concat("Withdraw amount is 0 for stream ", vm.toString(streamId)));
        }

        uint256 initialGas = gasleft();
        lockup.withdraw(streamId, users.recipient, withdrawAmount);
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
        Lockup.CreateWithTimestamps memory params = defaults.createWithTimestampsBrokerNull();
        lockup.createWithTimestampsLD({ params: params, segments: defaults.segments() });
        lockup.createWithTimestampsLL({
            params: params,
            unlockAmounts: defaults.unlockAmounts(),
            cliffTime: defaults.CLIFF_TIME()
        });
        lockup.createWithTimestampsLT({ params: params, tranches: defaults.tranches() });
    }
}
