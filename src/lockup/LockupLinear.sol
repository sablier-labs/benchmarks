// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud, ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup, LockupLinear } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Benchmarks for Lockup streams with an LL model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupLinearBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupLinearBenchmark() external {
        logBlue("\nStarting LockupLinear function benchmarks...");

        // Create the file if it doesn't exist, otherwise overwrite it.
        resultsFile = string.concat(RESULTS_DIR, "sablier-lockup-linear.md");
        vm.writeFile({
            path: resultsFile,
            data: string.concat(
                "# Benchmarks for the LockupLinear model\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        logBlue("Benchmarking: create functions with different cliffs...");
        instrument_CreateWithDurationsLL({ cliffDuration: 0 });
        instrument_CreateWithDurationsLL({ cliffDuration: defaults.CLIFF_DURATION() });
        instrument_CreateWithTimestampsLL({ cliffTime: 0 });
        instrument_CreateWithTimestampsLL({ cliffTime: defaults.CLIFF_TIME() });
        logGreen("Completed create function benchmarks");

        logBlue("Benchmarking: withdraw...");
        instrument_Withdraw_ByRecipient({ streamId1: streamIds[0], streamId2: streamIds[1], extraInfo: "" });
        instrument_Withdraw_ByOthers({ streamId1: streamIds[2], streamId2: streamIds[3], extraInfo: "" });
        logGreen("Completed withdraw function benchmarks");

        logBlue("Benchmarking: renounce...");
        instrument_Renounce(streamIds[4]);
        logGreen("Completed renounce benchmark");

        logBlue("Benchmarking: cancel...");
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        instrument_Cancel(streamIds[5]);
        logGreen("Completed cancel benchmark");

        logBlue("Benchmarking: burn...");
        vm.warp({ newTimestamp: defaults.END_TIME() });
        instrument_Burn(streamIds[6]);
        logGreen("Completed burn benchmark");

        logBlue("\nCompleted all benchmarks");
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INSTRUMENTATION FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_CreateWithDurationsLL(uint40 cliffDuration) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        // Calculate gas usage.
        Lockup.CreateWithDurations memory params = defaults.createWithDurations();
        LockupLinear.Durations memory durations = defaults.durations();
        params.broker.fee = ZERO;
        params.totalAmount = defaults.DEPOSIT_AMOUNT();
        durations.cliff = cliffDuration;

        LockupLinear.UnlockAmounts memory unlockAmounts = defaults.unlockAmounts();
        if (cliffDuration == 0) unlockAmounts.cliff = 0;

        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLL(params, unlockAmounts, durations);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        string memory cliffSetOrNot = cliffDuration == 0 ? " (no cliff)" : " (with cliff)";
        contentToAppend = string.concat("| `createWithDurationsLL`", cliffSetOrNot, " | ", gasUsed, " |");

        // Append the content to the file.
        _appendLine(resultsFile, contentToAppend);
    }

    function instrument_CreateWithTimestampsLL(uint40 cliffTime) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        // Calculate gas usage.
        Lockup.CreateWithTimestamps memory params = defaults.createWithTimestamps();
        params.broker.fee = ud(0);
        params.totalAmount = defaults.DEPOSIT_AMOUNT();

        LockupLinear.UnlockAmounts memory unlockAmounts = defaults.unlockAmounts();
        if (cliffTime == 0) unlockAmounts.cliff = 0;

        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLL(params, unlockAmounts, cliffTime);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        string memory cliffSetOrNot = cliffTime == 0 ? " (no cliff)" : " (with cliff)";
        contentToAppend = string.concat("| `createWithTimestampsLL`", cliffSetOrNot, " | ", gasUsed, " |");

        // Append the content to the file.
        _appendLine(resultsFile, contentToAppend);
    }
}
