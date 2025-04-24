// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ud2x18 } from "@prb/math/src/UD2x18.sol";
import { ZERO } from "@prb/math/src/UD60x18.sol";
import { Lockup as L, LockupDynamic as LD } from "@sablier/lockup/src/types/DataTypes.sol";

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
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        RESULTS_FILE = "results/lockup/lockup-dynamic.md";
        vm.writeFile({
            path: RESULTS_FILE,
            data: string.concat(
                "## Benchmarks for the LockupDynamic model\n\n",
                "| Function | Segments | Configuration | Gas Usage |\n",
                "| :------- | :------- | :------------ | :-------- |\n"
            )
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupDynamicBenchmark() external {
        logBlue("\nStarting LockupDynamic benchmarks...");

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

        /* ---------------------------- CREATE & WITHDRAW --------------------------- */

        logBlue("Benchmarking: create and withdraw with different segment counts...");
        for (uint256 i; i < _segmentCounts.length; ++i) {
            logBlue(string.concat("Benchmarking with ", vm.toString(_segmentCounts[i]), " segments..."));

            instrument_CreateWithDurationsLD(_segmentCounts[i]);
            instrument_CreateWithTimestampsLD(_segmentCounts[i]);

            _setUpDynamicStreams(_segmentCounts[i]);
            instrument_WithdrawOngoing(_dynamicStreamIds[0], users.recipient, _segmentCounts[i]);
            instrument_WithdrawCompleted(_dynamicStreamIds[1], users.recipient, _segmentCounts[i]);
            instrument_WithdrawOngoing(_dynamicStreamIds[2], users.alice, _segmentCounts[i]);
            instrument_WithdrawCompleted(_dynamicStreamIds[3], users.alice, _segmentCounts[i]);

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_segmentCounts[i]), " segments"));
        }
        logGreen("Completed create and withdraw benchmarks");

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

        _appendRow("burn", defaults.SEGMENT_COUNT(), "N/A", gasUsed);
    }

    function instrument_Cancel(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.cancel(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("cancel", defaults.SEGMENT_COUNT(), "N/A", gasUsed);
    }

    function instrument_CreateWithDurationsLD(uint128 segmentCount) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.START_TIME() });

        (L.CreateWithDurations memory params, LD.SegmentWithDuration[] memory segments) =
            _paramsCreateWithDurationLD(segmentCount);
        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLD(params, segments);
        uint256 gasUsed = beforeGas - gasleft();

        _appendRow("createWithDurationsLD", segmentCount, "N/A", gasUsed);
    }

    function instrument_CreateWithTimestampsLD(uint128 segmentCount) internal {
        resetPrank({ msgSender: users.sender });

        (L.CreateWithTimestamps memory params, LD.Segment[] memory segments) =
            _paramsCreateWithTimestampsLD(segmentCount);

        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLD(params, segments);
        uint256 gasUsed = beforeGas - gasleft();

        _appendRow("createWithTimestampsLD", segmentCount, "N/A", gasUsed);
    }

    function instrument_Renounce(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.renounce(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("renounce", defaults.SEGMENT_COUNT(), "N/A", gasUsed);
    }

    function instrument_Withdraw(
        uint256 streamId,
        address caller,
        uint256 segmentCount,
        string memory config
    )
        internal
    {
        uint256 gasUsed = withdraw({ streamId: streamId, caller: caller, to: users.recipient });
        _appendRow("withdraw", segmentCount, config, gasUsed);
    }

    function instrument_WithdrawOngoing(uint256 streamId, address caller, uint256 segmentCount) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() - 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, segmentCount, "vesting ongoing && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, segmentCount, "vesting ongoing && called by third-party");
        }
    }

    function instrument_WithdrawCompleted(uint256 streamId, address caller, uint256 segmentCount) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() + 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, segmentCount, "vesting completed && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, segmentCount, "vesting completed && called by third-party");
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a row to the results file with the given function name, config, and gas used.
    function _appendRow(
        string memory functionName,
        uint256 segmentCount,
        string memory config,
        uint256 gasUsed
    )
        private
    {
        string memory row = string.concat(
            "| `", functionName, "` | ", vm.toString(segmentCount), " | ", config, " | ", vm.toString(gasUsed), " |"
        );
        vm.writeLine({ path: RESULTS_FILE, data: row });
    }

    function _paramsCreateWithDurationLD(uint128 segmentCount)
        private
        view
        returns (L.CreateWithDurations memory params, LD.SegmentWithDuration[] memory segments_)
    {
        segments_ = new LD.SegmentWithDuration[](segmentCount);

        for (uint256 i = 0; i < segmentCount; ++i) {
            segments_[i] = (
                LD.SegmentWithDuration({
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
        returns (L.CreateWithTimestamps memory params, LD.Segment[] memory segments_)
    {
        segments_ = new LD.Segment[](segmentCount);

        for (uint256 i = 0; i < segmentCount; ++i) {
            segments_[i] = (
                LD.Segment({
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

    function _setUpDynamicStreams(uint128 segmentCount) private {
        resetPrank({ msgSender: users.sender });
        (L.CreateWithDurations memory params, LD.SegmentWithDuration[] memory segments) =
            _paramsCreateWithDurationLD(segmentCount);
        _dynamicStreamIds[0] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[1] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[2] = lockup.createWithDurationsLD(params, segments);
        _dynamicStreamIds[3] = lockup.createWithDurationsLD(params, segments);
    }
}
