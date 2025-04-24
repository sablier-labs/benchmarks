// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud, ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup as L, LockupLinear as LL } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Benchmarks for Lockup streams with an LL model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupLinearBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        RESULTS_FILE = "results/lockup/lockup-linear.md";
        vm.writeFile({
            path: RESULTS_FILE,
            data: string.concat(
                "## Benchmarks for the LockupLinear model\n\n",
                "| Function | Configuration | Gas Usage |\n",
                "| :------- | :------------ | :-------- |\n"
            )
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupLinearBenchmark() external {
        logBlue("\nStarting LockupLinear benchmarks...");

        /* ---------------------------------- BURN ---------------------------------- */
        logBlue("Benchmarking: burn...");
        instrument_Burn(streamIds[0]);
        logGreen("Completed burn benchmark");

        /* --------------------------------- CANCEL --------------------------------- */

        logBlue("Benchmarking: cancel...");
        instrument_Cancel(streamIds[1]);
        logGreen("Completed cancel benchmark");

        /* -------------------------------- RENOUNCE -------------------------------- */

        logBlue("Benchmarking: renounce...");
        instrument_Renounce(streamIds[2]);
        logGreen("Completed renounce benchmark");

        /* --------------------------------- CREATE --------------------------------- */

        logBlue("Benchmarking: create with different cliffs...");
        instrument_CreateWithDurationsLL({ cliffDuration: 0 });
        instrument_CreateWithDurationsLL({ cliffDuration: defaults.CLIFF_DURATION() });
        instrument_CreateWithTimestampsLL({ cliffTime: 0 });
        instrument_CreateWithTimestampsLL({ cliffTime: defaults.CLIFF_TIME() });
        logGreen("Completed create benchmarks");

        /* -------------------------------- WITHDRAW -------------------------------- */

        logBlue("Benchmarking: withdraw...");
        instrument_WithdrawOngoing(streamIds[3], users.recipient);
        instrument_WithdrawCompleted(streamIds[4], users.recipient);
        instrument_WithdrawOngoing(streamIds[5], users.alice);
        instrument_WithdrawCompleted(streamIds[6], users.alice);
        logGreen("Completed withdraw benchmarks");

        logBlue("\nCompleted all benchmarks");
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INSTRUMENTATION FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_Burn(uint256 streamId) internal {
        resetPrank({ msgSender: users.recipient });
        vm.warp({ newTimestamp: defaults.END_TIME() });

        lockup.withdrawMax(streamId, users.recipient);

        uint256 initialGas = gasleft();
        lockup.burn(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("burn", "N/A", gasUsed);
    }

    function instrument_Cancel(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.cancel(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("cancel", "N/A", gasUsed);
    }

    function instrument_CreateWithDurationsLL(uint40 cliffDuration) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.START_TIME() });

        L.CreateWithDurations memory params = defaults.createWithDurations();
        LL.Durations memory durations = defaults.durations();
        params.broker.fee = ZERO;
        params.totalAmount = defaults.DEPOSIT_AMOUNT();
        durations.cliff = cliffDuration;

        LL.UnlockAmounts memory unlockAmounts = defaults.unlockAmounts();
        if (cliffDuration == 0) unlockAmounts.cliff = 0;

        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLL(params, unlockAmounts, durations);
        uint256 gasUsed = beforeGas - gasleft();

        string memory cliffConfig = cliffDuration == 0 ? "no cliff" : " with cliff";
        _appendRow("createWithDurationsLL", cliffConfig, gasUsed);
    }

    function instrument_CreateWithTimestampsLL(uint40 cliffTime) internal {
        resetPrank({ msgSender: users.sender });

        L.CreateWithTimestamps memory params = defaults.createWithTimestamps();
        params.broker.fee = ud(0);
        params.totalAmount = defaults.DEPOSIT_AMOUNT();

        LL.UnlockAmounts memory unlockAmounts = defaults.unlockAmounts();
        if (cliffTime == 0) unlockAmounts.cliff = 0;

        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLL(params, unlockAmounts, cliffTime);
        uint256 gasUsed = beforeGas - gasleft();

        string memory cliffConfig = cliffTime == 0 ? "no cliff" : " with cliff";
        _appendRow("createWithTimestampsLL", cliffConfig, gasUsed);
    }

    function instrument_Renounce(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.renounce(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("renounce", "N/A", gasUsed);
    }

    function instrument_Withdraw(uint256 streamId, address caller, string memory config) internal {
        uint256 gasUsed = withdraw({ streamId: streamId, caller: caller, to: users.recipient });
        _appendRow("withdraw", config, gasUsed);
    }

    function instrument_WithdrawOngoing(uint256 streamId, address caller) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() - 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, "vesting ongoing && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, "vesting ongoing && called by third-party");
        }
    }

    function instrument_WithdrawCompleted(uint256 streamId, address caller) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() + 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, "vesting completed && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, "vesting completed && called by third-party");
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a row to the results file with the given function name, configuration, and gas used.
    function _appendRow(string memory functionName, string memory configuration, uint256 gasUsed) private {
        string memory row = string.concat("| `", functionName, "` | ", configuration, " | ", vm.toString(gasUsed), " |");
        vm.writeLine({ path: RESULTS_FILE, data: row });
    }
}
