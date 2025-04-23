// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud, ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup, LockupLinear } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Contract to benchmark Lockup streams created using Linear model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupLinearBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                COMPUTE GAS FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testComputeGas_Implementations() external {
        // Set the file path.
        benchmarkResultsFile = string.concat(benchmarkResults, "SablierLockup_Linear.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
            data: string.concat(
                "# Benchmarks for the Lockup Linear model\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        gasCancel();

        gasRenounce();

        gasCreateWithDurationsLL({ cliffDuration: 0 });
        gasCreateWithDurationsLL({ cliffDuration: defaults.CLIFF_DURATION() });

        gasCreateWithTimestampsLL({ cliffTime: 0 });
        gasCreateWithTimestampsLL({ cliffTime: defaults.CLIFF_TIME() });

        gasWithdraw_ByRecipient(streamIds[3], streamIds[4], "");
        gasWithdraw_ByAnyone(streamIds[5], streamIds[6], "");
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurationsLL(uint40 cliffDuration) internal {
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

        string memory cliffSetOrNot = cliffDuration == 0 ? " (cliff not set)" : " (cliff set)";

        contentToAppend = string.concat("| `createWithDurationsLL`", cliffSetOrNot, " | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    function gasCreateWithTimestampsLL(uint40 cliffTime) internal {
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

        string memory cliffSetOrNot = cliffTime == 0 ? " (cliff not set)" : " (cliff set)";

        contentToAppend = string.concat("| `createWithTimestampsLL`", cliffSetOrNot, " | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }
}
