// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";

import {
    BatchLockup as BL,
    Lockup as L,
    LockupDynamic as LD,
    LockupTranched as LT
} from "@sablier/lockup/src/types/DataTypes.sol";
import { BatchLockupBuilder } from "@sablier/lockup/tests/utils/Defaults.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Contract for benchmarking {SablierBatchLockup}.
/// @dev This contract creates a Markdown file with the gas usage of each function.
/// NOTE: this benchmark takes a long time to run.
contract BatchLockupBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128 internal constant AMOUNT_PER_ITEM = 10e18;
    uint8[5] internal _batchSizes = [5, 10, 20, 50];
    uint8[5] internal _segmentCounts = [24, 24, 24, 12];

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        RESULTS_FILE = "results/lockup/batch-lockup.md";

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: RESULTS_FILE,
            data: string.concat(
                "| Lockup Model | Function | Batch Size | Segments/Tranches | Gas Usage |\n",
                "| :----------- | :------- | :--------- | :---------------- | :-------- |\n"
            )
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_BatchLockupBenchmark() external {
        logBlue("\nStarting BatchLockup function benchmarks...");

        for (uint256 i = 0; i < _batchSizes.length; ++i) {
            logBlue(string.concat("Benchmarking batch size: ", vm.toString(_batchSizes[i])));

            // Benchmarks for LL.
            instrument_BatchCreateWithDurationsLL(_batchSizes[i]);
            instrument_BatchCreateWithTimestampsLL(_batchSizes[i]);

            // Benchmarks for LD.
            instrument_BatchCreateWithDurationsLD({ batchSize: _batchSizes[i], segmentCount: _segmentCounts[i] });
            instrument_BatchCreateWithTimestampsLD({ batchSize: _batchSizes[i], segmentCount: _segmentCounts[i] });

            // Benchmarks for LT.
            instrument_BatchCreateWithDurationsLT({ batchSize: _batchSizes[i], trancheCount: _segmentCounts[i] });
            instrument_BatchCreateWithTimestampsLT({ batchSize: _batchSizes[i], trancheCount: _segmentCounts[i] });

            logGreen(string.concat("Completed batch size: ", vm.toString(_batchSizes[i])));
        }

        logBlue("\nCompleted all benchmarks");
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INSTRUMENTATION FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function instrument_BatchCreateWithDurationsLD(uint256 batchSize, uint256 segmentCount) internal {
        L.CreateWithDurations memory createParams = defaults.createWithDurationsBrokerNull();
        createParams.totalAmount = uint128(AMOUNT_PER_ITEM * segmentCount);
        LD.SegmentWithDuration[] memory segments = _generateSegmentsWithDuration(segmentCount);
        BL.CreateWithDurationsLD[] memory batchParams = BatchLockupBuilder.fillBatch(createParams, segments, batchSize);

        uint256 initialGas = gasleft();
        batchLockup.createWithDurationsLD(lockup, dai, batchParams);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithDurationsLD", "Dynamic", batchSize, vm.toString(segmentCount), gasUsed);
    }

    function instrument_BatchCreateWithTimestampsLD(uint256 batchSize, uint256 segmentCount) internal {
        L.CreateWithTimestamps memory createParams = defaults.createWithTimestampsBrokerNull();
        LD.Segment[] memory segments = _generateSegments(segmentCount);
        createParams.timestamps.start = getBlockTimestamp();
        createParams.timestamps.end = segments[segments.length - 1].timestamp;
        createParams.totalAmount = uint128(AMOUNT_PER_ITEM * segmentCount);
        BL.CreateWithTimestampsLD[] memory params = BatchLockupBuilder.fillBatch(createParams, segments, batchSize);

        uint256 initialGas = gasleft();
        batchLockup.createWithTimestampsLD(lockup, dai, params);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithTimestampsLD", "Dynamic", batchSize, vm.toString(segmentCount), gasUsed);
    }

    function instrument_BatchCreateWithDurationsLL(uint256 batchSize) internal {
        BL.CreateWithDurationsLL[] memory batchParams = BatchLockupBuilder.fillBatch({
            params: defaults.createWithDurationsBrokerNull(),
            unlockAmounts: defaults.unlockAmounts(),
            durations: defaults.durations(),
            batchSize: batchSize
        });

        uint256 initialGas = gasleft();
        batchLockup.createWithDurationsLL(lockup, dai, batchParams);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithDurationsLL", "Linear", batchSize, "N/A", gasUsed);
    }

    function instrument_BatchCreateWithTimestampsLL(uint256 batchSize) internal {
        BL.CreateWithTimestampsLL[] memory batchParams = BatchLockupBuilder.fillBatch({
            params: defaults.createWithTimestampsBrokerNull(),
            unlockAmounts: defaults.unlockAmounts(),
            cliffTime: defaults.CLIFF_TIME(),
            batchSize: batchSize
        });

        uint256 initialGas = gasleft();
        batchLockup.createWithTimestampsLL(lockup, dai, batchParams);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithTimestampsLL", "Linear", batchSize, "N/A", gasUsed);
    }

    function instrument_BatchCreateWithDurationsLT(uint256 batchSize, uint256 trancheCount) internal {
        L.CreateWithDurations memory createParams = defaults.createWithDurationsBrokerNull();
        LT.TrancheWithDuration[] memory tranches = _generateTranchesWithDuration(trancheCount);
        createParams.totalAmount = uint128(AMOUNT_PER_ITEM * trancheCount);
        BL.CreateWithDurationsLT[] memory batchParams = BatchLockupBuilder.fillBatch(createParams, tranches, batchSize);

        uint256 initialGas = gasleft();
        batchLockup.createWithDurationsLT(lockup, dai, batchParams);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithDurationsLT", "Tranched", batchSize, vm.toString(trancheCount), gasUsed);
    }

    function instrument_BatchCreateWithTimestampsLT(uint256 batchSize, uint256 trancheCount) internal {
        L.CreateWithTimestamps memory createParams = defaults.createWithTimestampsBrokerNull();
        LT.Tranche[] memory tranches = _generateTranches(trancheCount);
        createParams.timestamps.start = getBlockTimestamp();
        createParams.timestamps.end = tranches[tranches.length - 1].timestamp;
        createParams.totalAmount = uint128(AMOUNT_PER_ITEM * trancheCount);
        BL.CreateWithTimestampsLT[] memory batchParams = BatchLockupBuilder.fillBatch(createParams, tranches, batchSize);

        uint256 initialGas = gasleft();
        batchLockup.createWithTimestampsLT(lockup, dai, batchParams);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("createWithTimestampsLT", "Tranched", batchSize, vm.toString(trancheCount), gasUsed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _appendRow(
        string memory functionName,
        string memory lockupModel,
        uint256 batchSize,
        string memory segmentOrTrancheCount,
        uint256 gasUsed
    )
        private
    {
        string memory row = string.concat(
            "` | ",
            lockupModel,
            "| `",
            functionName,
            " | ",
            vm.toString(batchSize),
            " | ",
            segmentOrTrancheCount,
            " | ",
            vm.toString(gasUsed),
            " |"
        );
        vm.writeLine({ path: RESULTS_FILE, data: row });
    }

    function _generateSegments(uint256 segmentCount) private view returns (LD.Segment[] memory) {
        LD.Segment[] memory segments = new LD.Segment[](segmentCount);

        for (uint256 i = 0; i < segmentCount; ++i) {
            segments[i] = LD.Segment({
                amount: AMOUNT_PER_ITEM,
                exponent: ud2x18(0.5e18),
                timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
            });
        }

        return segments;
    }

    function _generateSegmentsWithDuration(uint256 segmentCount)
        private
        view
        returns (LD.SegmentWithDuration[] memory)
    {
        LD.SegmentWithDuration[] memory segments = new LD.SegmentWithDuration[](segmentCount);

        for (uint256 i; i < segmentCount; ++i) {
            segments[i] = LD.SegmentWithDuration({
                amount: AMOUNT_PER_ITEM,
                exponent: ud2x18(0.5e18),
                duration: defaults.CLIFF_DURATION()
            });
        }

        return segments;
    }

    function _generateTranches(uint256 trancheCount) private view returns (LT.Tranche[] memory) {
        LT.Tranche[] memory tranches = new LT.Tranche[](trancheCount);

        for (uint256 i = 0; i < trancheCount; ++i) {
            tranches[i] = (
                LT.Tranche({
                    amount: AMOUNT_PER_ITEM,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        return tranches;
    }

    function _generateTranchesWithDuration(uint256 trancheCount)
        private
        view
        returns (LT.TrancheWithDuration[] memory)
    {
        LT.TrancheWithDuration[] memory tranches = new LT.TrancheWithDuration[](trancheCount);

        for (uint256 i; i < trancheCount; ++i) {
            tranches[i] = LT.TrancheWithDuration({ amount: AMOUNT_PER_ITEM, duration: defaults.CLIFF_DURATION() });
        }

        return tranches;
    }
}
