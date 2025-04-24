// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup as L, LockupTranched as LT } from "@sablier/lockup/src/types/DataTypes.sol";

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
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        RESULTS_FILE = "results/lockup/lockup-tranched.md";
        vm.writeFile({
            path: RESULTS_FILE,
            data: string.concat(
                "| Function | Tranches | Configuration | Gas Usage |\n",
                "| :------- | :------- | :------------ | :-------- |\n"
            )
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_LockupTranchedBenchmark() external {
        logBlue("\nStarting LockupTranched benchmarks...");

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
        for (uint256 i; i < _trancheCounts.length; ++i) {
            logBlue(string.concat("Benchmarking with ", vm.toString(_trancheCounts[i]), " segments..."));

            instrument_CreateWithDurationsLT(_trancheCounts[i]);
            instrument_CreateWithTimestampsLT(_trancheCounts[i]);

            _setUpTranchedStreams(_trancheCounts[i]);
            instrument_WithdrawOngoing(_tranchedStreamIds[0], users.recipient, _trancheCounts[i]);
            // instrument_WithdrawCompleted(_tranchedStreamIds[1], users.recipient, _trancheCounts[i]);
            // instrument_WithdrawOngoing(_tranchedStreamIds[2], users.alice, _trancheCounts[i]);
            // instrument_WithdrawCompleted(_tranchedStreamIds[3], users.alice, _trancheCounts[i]);

            logGreen(string.concat("Completed benchmarks with ", vm.toString(_trancheCounts[i]), " segments"));
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

        _appendRow("burn", defaults.TRANCHE_COUNT(), "N/A", gasUsed);
    }

    function instrument_Cancel(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.cancel(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("cancel", defaults.TRANCHE_COUNT(), "N/A", gasUsed);
    }

    function instrument_CreateWithDurationsLT(uint128 trancheCount) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.START_TIME() });

        (L.CreateWithDurations memory params, LT.TrancheWithDuration[] memory tranches) =
            _paramsCreateWithDurationLT(trancheCount);

        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLT(params, tranches);
        uint256 gasUsed = beforeGas - gasleft();

        _appendRow("createWithDurationsLT", trancheCount, "N/A", gasUsed);
    }

    function instrument_CreateWithTimestampsLT(uint128 trancheCount) internal {
        resetPrank({ msgSender: users.sender });

        (L.CreateWithTimestamps memory params, LT.Tranche[] memory tranches) =
            _paramsCreateWithTimestampsLT(trancheCount);
        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLT(params, tranches);
        uint256 gasUsed = beforeGas - gasleft();

        _appendRow("createWithTimestampsLT", trancheCount, "N/A", gasUsed);
    }

    function instrument_Renounce(uint256 streamId) internal {
        resetPrank({ msgSender: users.sender });
        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        uint256 initialGas = gasleft();
        lockup.renounce(streamId);
        uint256 gasUsed = initialGas - gasleft();

        _appendRow("renounce", defaults.TRANCHE_COUNT(), "N/A", gasUsed);
    }

    function instrument_Withdraw(
        uint256 streamId,
        address caller,
        uint256 trancheCount,
        string memory config
    )
        internal
    {
        uint256 gasUsed = withdraw({ streamId: streamId, caller: caller, to: users.recipient });
        _appendRow("withdraw", trancheCount, config, gasUsed);
    }

    function instrument_WithdrawOngoing(uint256 streamId, address caller, uint256 trancheCount) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() - 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, trancheCount, "vesting ongoing && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, trancheCount, "vesting ongoing && called by third-party");
        }
    }

    function instrument_WithdrawCompleted(uint256 streamId, address caller, uint256 trancheCount) internal {
        vm.warp({ newTimestamp: defaults.END_TIME() + 1 seconds });
        if (caller == users.recipient) {
            instrument_Withdraw(streamId, caller, trancheCount, "vesting completed && called by recipient");
        } else {
            instrument_Withdraw(streamId, caller, trancheCount, "vesting completed && called by third-party");
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Append a row to the results file with the given function name, config, and gas used.
    function _appendRow(
        string memory functionName,
        uint256 trancheCount,
        string memory config,
        uint256 gasUsed
    )
        private
    {
        string memory row = string.concat(
            "| `", functionName, "` | ", vm.toString(trancheCount), " | ", config, " | ", vm.toString(gasUsed), " |"
        );
        vm.writeLine({ path: RESULTS_FILE, data: row });
    }

    function _paramsCreateWithDurationLT(uint128 trancheCount)
        private
        view
        returns (L.CreateWithDurations memory params, LT.TrancheWithDuration[] memory tranches_)
    {
        tranches_ = new LT.TrancheWithDuration[](trancheCount);

        // Populate tranches
        for (uint256 i = 0; i < trancheCount; ++i) {
            tranches_[i] = (LT.TrancheWithDuration({ amount: AMOUNT_PER_TRANCHE, duration: defaults.CLIFF_DURATION() }));
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
        returns (L.CreateWithTimestamps memory params, LT.Tranche[] memory tranches_)
    {
        tranches_ = new LT.Tranche[](trancheCount);

        for (uint256 i = 0; i < trancheCount; ++i) {
            tranches_[i] = (
                LT.Tranche({
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

    function _setUpTranchedStreams(uint128 trancheCount) private {
        resetPrank({ msgSender: users.sender });
        (L.CreateWithDurations memory params, LT.TrancheWithDuration[] memory tranches) =
            _paramsCreateWithDurationLT(trancheCount);
        _tranchedStreamIds[0] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[1] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[2] = lockup.createWithDurationsLT(params, tranches);
        _tranchedStreamIds[3] = lockup.createWithDurationsLT(params, tranches);
    }
}
