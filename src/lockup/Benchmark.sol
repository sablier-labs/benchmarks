// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierBatchLockup } from "@sablier/lockup/src/interfaces/ISablierBatchLockup.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";
import { Defaults } from "@sablier/lockup/tests/utils/Defaults.sol";
import { Lockup as L } from "@sablier/lockup/src/types/DataTypes.sol";
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

    uint256[7] internal streamIds;

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ISablierBatchLockup internal batchLockup;
    IERC20 internal dai;
    Defaults internal defaults;
    ISablierLockup internal lockup;

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

        // Load DAI token.
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        logGreen("Loaded DAI token contract");

        // Create some users.
        users.alice = payable(makeAddr("alice"));
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));
        logGreen("Created test users");

        deal({ token: address(dai), to: users.sender, give: type(uint128).max });
        resetPrank({ msgSender: users.sender });
        dai.approve(address(batchLockup), type(uint128).max);
        dai.approve(address(lockup), type(uint128).max);
        logGreen("Funded and approved DAI");

        defaults = new Defaults();
        defaults.setToken(dai);
        defaults.setUsers(users);

        _setUpStreams();
        logGreen("Created test streams");
        logBlue("Setup complete! Ready to run benchmarks.");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SHARED LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    function withdraw(uint256 streamId, address caller, address to) internal returns (uint256 gasUsed) {
        resetPrank({ msgSender: caller });

        // If caller is not the recipient, the withdrawal address must be the recipient.
        bool isCallerRecipient = caller == users.recipient;
        if (!isCallerRecipient) {
            to = users.recipient;
        }

        uint128 withdrawAmount = lockup.withdrawableAmountOf(streamId);
        if (withdrawAmount == 0) {
            revert(string.concat("Withdraw amount is 0 for stream ", vm.toString(streamId)));
        }

        uint256 initialGas = gasleft();
        lockup.withdraw(streamId, to, withdrawAmount);
        return initialGas - gasleft();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Internal function to creates a few streams in each Lockup contract.
    function _setUpStreams() internal {
        L.CreateWithTimestamps memory params = defaults.createWithTimestamps();

        streamIds[0] = lockup.createWithTimestampsLD({ params: params, segments: defaults.segments() });
        streamIds[1] = lockup.createWithTimestampsLD({ params: params, segments: defaults.segments() });
        streamIds[2] = lockup.createWithTimestampsLL({
            params: params,
            unlockAmounts: defaults.unlockAmounts(),
            cliffTime: defaults.CLIFF_TIME()
        });
        streamIds[3] = lockup.createWithTimestampsLL({
            params: params,
            unlockAmounts: defaults.unlockAmounts(),
            cliffTime: defaults.CLIFF_TIME()
        });
        streamIds[4] = lockup.createWithTimestampsLT({ params: params, tranches: defaults.tranches() });
        streamIds[5] = lockup.createWithTimestampsLT({ params: params, tranches: defaults.tranches() });
        streamIds[6] = lockup.createWithTimestampsLT({ params: params, tranches: defaults.tranches() });
    }
}
