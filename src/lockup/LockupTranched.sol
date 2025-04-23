// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup, LockupTranched } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Benchmarks for Lockup streams with an LT model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupTranchedBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128[] internal _trancheCounts = [2, 10, 100];
    uint256[] internal _tranchedStreamIds = new uint256[](4);

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupTranchedBenchmark() external {
        logBlue("\nStarting LockupTranched function benchmarks...");

        // Create the file if it doesn't exist, otherwise overwrite it.
        resultsFile = string.concat(RESULTS_DIR, "sablier-lockup-tranched.md");
        vm.writeFile({
            path: resultsFile,
            data: string.concat(
                "# Benchmarks for the LockupTranched model\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        logBlue("Benchmarking: create with different tranche counts...");
        for (uint256 i; i < _trancheCounts.length; ++i) {
            logBlue(string.concat("Benchmarking create with ", vm.toString(_trancheCounts[i]), " tranches..."));

            instrument_CreateWithDurationsLT(_trancheCounts[i]);
            instrument_CreateWithTimestampsLT(_trancheCounts[i]);

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_trancheCounts[i]), " tranches"));
        }
        logGreen("Completed create benchmarks");

        logBlue("Benchmarking: withdraw with different tranche counts...");
        for (uint256 i; i < _trancheCounts.length; ++i) {
            logBlue(string.concat("Benchmarking withdraw with ", vm.toString(_trancheCounts[i]), " tranches..."));

            _setUpTranchedStreams(_trancheCounts[i]);
            instrument_Withdraw_ByRecipient({
                streamId1: _tranchedStreamIds[0],
                streamId2: _tranchedStreamIds[1],
                extraInfo: string.concat("(", vm.toString(_trancheCounts[i]), " tranches)")
            });
            instrument_Withdraw_ByOthers({
                streamId1: _tranchedStreamIds[2],
                streamId2: _tranchedStreamIds[3],
                extraInfo: string.concat("(", vm.toString(_trancheCounts[i]), " tranches)")
            });

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_trancheCounts[i]), " tranches"));
        }
        logGreen("Completed withdraw benchmarks");

        logBlue("Benchmarking: renounce...");
        vm.warp({ newTimestamp: defaults.START_TIME() });
        instrument_Renounce(streamIds[0]);
        logGreen("Completed renounce benchmark");

        logBlue("Benchmarking: cancel...");
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });
        instrument_Cancel(streamIds[1]);
        logGreen("Completed cancel benchmark");

        logBlue("Benchmarking: burn...");
        vm.warp({ newTimestamp: defaults.END_TIME() });
        instrument_Burn(streamIds[2]);
        logGreen("Completed burn benchmark");

        logBlue("\nCompleted all benchmarks");
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INSTRUMENTATION FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_CreateWithDurationsLT(uint128 trancheCount) internal {
        resetPrank({ msgSender: users.sender });

        (Lockup.CreateWithDurations memory params, LockupTranched.TrancheWithDuration[] memory tranches) =
            _paramsCreateWithDurationLT(trancheCount);

        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLT(params, tranches);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithDurationsLT` (", vm.toString(trancheCount), " tranches) | ", gasUsed, " |");
        _appendLine(resultsFile, contentToAppend);
    }

    function instrument_CreateWithTimestampsLT(uint128 trancheCount) internal {
        resetPrank({ msgSender: users.sender });

        (Lockup.CreateWithTimestamps memory params, LockupTranched.Tranche[] memory tranches) =
            _paramsCreateWithTimestampsLT(trancheCount);
        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLT(params, tranches);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithTimestampsLT` (", vm.toString(trancheCount), " tranches) | ", gasUsed, " |");
        _appendLine(resultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _paramsCreateWithDurationLT(uint128 trancheCount)
        private
        view
        returns (Lockup.CreateWithDurations memory params, LockupTranched.TrancheWithDuration[] memory tranches_)
    {
        tranches_ = new LockupTranched.TrancheWithDuration[](trancheCount);

        // Populate tranches
        for (uint256 i = 0; i < trancheCount; ++i) {
            tranches_[i] = (
                LockupTranched.TrancheWithDuration({ amount: AMOUNT_PER_TRANCHE, duration: defaults.CLIFF_DURATION() })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * trancheCount;

        params = defaults.createWithDurations();
        params.broker.fee = ZERO;
        params.totalAmount = depositAmount;
        return (params, tranches_);
    }

    function _paramsCreateWithTimestampsLT(uint128 trancheCount)
        private
        view
        returns (Lockup.CreateWithTimestamps memory params, LockupTranched.Tranche[] memory tranches_)
    {
        tranches_ = new LockupTranched.Tranche[](trancheCount);

        // Populate tranches.
        for (uint256 i = 0; i < trancheCount; ++i) {
            tranches_[i] = (
                LockupTranched.Tranche({
                    amount: AMOUNT_PER_TRANCHE,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * trancheCount;

        params = defaults.createWithTimestamps();
        params.broker.fee = ZERO;
        params.timestamps.start = getBlockTimestamp();
        params.timestamps.end = tranches_[trancheCount - 1].timestamp;
        params.totalAmount = depositAmount;
        return (params, tranches_);
    }

    function _setUpTranchedStreams(uint128 trancheCount) internal {
        resetPrank({ msgSender: users.sender });
        (Lockup.CreateWithDurations memory params, LockupTranched.TrancheWithDuration[] memory tranches) =
            _paramsCreateWithDurationLT(trancheCount);
        _tranchedStreamIds[0] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[1] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[2] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[3] = lockup.createWithDurationsLT(params, tranches);
    }
}
