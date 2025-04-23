// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { ZERO } from "@prb/math/src/UD60x18.sol";
import { Lockup, LockupDynamic } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Benchmarks for Lockup streams with an LD model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupDynamicBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128[] internal _segmentCounts = [2, 10, 100];
    uint256[] internal _dynamicStreamIds = new uint256[](4);

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupDynamicBenchmark() external {
        logBlue("\nStarting LockupDynamic function benchmarks...");

        // Create the file if it doesn't exist, otherwise overwrite it.
        resultsFile = string.concat(RESULTS_DIR, "sablier-lockup-dynamic.md");
        vm.writeFile({
            path: resultsFile,
            data: string.concat(
                "# Benchmarks for the LockupDynamic model\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        logBlue("Benchmarking: create with different segment counts...");
        // Create streams with different segment counts.
        for (uint256 i; i < _segmentCounts.length; ++i) {
            logBlue(string.concat("Benchmarking with ", vm.toString(_segmentCounts[i]), " segments..."));

            instrument_CreateWithDurationsLD(_segmentCounts[i]);
            instrument_CreateWithTimestampsLD(_segmentCounts[i]);

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_segmentCounts[i]), " segments"));
        }
        logGreen("Completed create  benchmarks");

        logBlue("Benchmarking: withdraw functions with different segment counts...");
        // Create streams with different segment counts.
        for (uint256 i; i < _segmentCounts.length; ++i) {
            logBlue(string.concat("Benchmarking with ", vm.toString(_segmentCounts[i]), " segments..."));

            _setUpDynamicStreams(_segmentCounts[i]);
            instrument_Withdraw_ByRecipient({
                streamId1: _dynamicStreamIds[0],
                streamId2: _dynamicStreamIds[1],
                extraInfo: string.concat("(", vm.toString(_segmentCounts[i]), " segments)")
            });
            instrument_Withdraw_ByOthers({
                streamId1: _dynamicStreamIds[2],
                streamId2: _dynamicStreamIds[3],
                extraInfo: string.concat("(", vm.toString(_segmentCounts[i]), " segments)")
            });

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_segmentCounts[i]), " segments"));
        }
        logGreen("Completed withdraw benchmarks");

        logBlue("Benchmarking: renounce...");
        vm.warp({ newTimestamp: defaults.START_TIME() });
        instrument_Renounce(streamIds[0]);
        logGreen("Completed renounce benchmarks");

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

    function instrument_CreateWithDurationsLD(uint128 segmentCount) internal {
        resetPrank({ msgSender: users.sender });

        (Lockup.CreateWithDurations memory params, LockupDynamic.SegmentWithDuration[] memory segments) =
            _paramsCreateWithDurationLD(segmentCount);
        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLD(params, segments);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithDurationsLD` (", vm.toString(segmentCount), " segments)| ", gasUsed, " |");
        _appendLine(resultsFile, contentToAppend);
    }

    function instrument_CreateWithTimestampsLD(uint128 segmentCount) internal {
        resetPrank({ msgSender: users.sender });

        _appendLine(resultsFile, contentToAppend);

        (Lockup.CreateWithTimestamps memory params, LockupDynamic.Segment[] memory segments) =
            _paramsCreateWithTimestampsLD(segmentCount);

        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLD(params, segments);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithTimestampsLD` (", vm.toString(segmentCount), " segments) | ", gasUsed, " |");
        _appendLine(resultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _paramsCreateWithDurationLD(uint128 segmentCount)
        private
        view
        returns (Lockup.CreateWithDurations memory params, LockupDynamic.SegmentWithDuration[] memory segments_)
    {
        segments_ = new LockupDynamic.SegmentWithDuration[](segmentCount);

        for (uint256 i = 0; i < segmentCount; ++i) {
            segments_[i] = (
                LockupDynamic.SegmentWithDuration({
                    amount: AMOUNT_PER_SEGMENT,
                    exponent: ud2x18(0.5e18),
                    duration: defaults.CLIFF_DURATION()
                })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * segmentCount;

        params = defaults.createWithDurations();
        params.totalAmount = depositAmount;
        params.broker.fee = ZERO;
        return (params, segments_);
    }

    function _paramsCreateWithTimestampsLD(uint128 segmentCount)
        private
        view
        returns (Lockup.CreateWithTimestamps memory params, LockupDynamic.Segment[] memory segments_)
    {
        segments_ = new LockupDynamic.Segment[](segmentCount);

        for (uint256 i = 0; i < segmentCount; ++i) {
            segments_[i] = (
                LockupDynamic.Segment({
                    amount: AMOUNT_PER_SEGMENT,
                    exponent: ud2x18(0.5e18),
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * segmentCount;

        params = defaults.createWithTimestamps();
        params.totalAmount = depositAmount;
        params.timestamps.start = getBlockTimestamp();
        params.timestamps.end = segments_[segmentCount - 1].timestamp;
        params.broker.fee = ZERO;
        return (params, segments_);
    }

    function _setUpDynamicStreams(uint128 segmentCount) internal {
        resetPrank({ msgSender: users.sender });
        (Lockup.CreateWithDurations memory params, LockupDynamic.SegmentWithDuration[] memory segments) =
            _paramsCreateWithDurationLD(segmentCount);
        _dynamicStreamIds[0] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[1] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[2] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[3] = lockup.createWithDurationsLD(params, segments);
    }
}
