// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ZERO } from "@prb/math/src/UD60x18.sol";

import { Lockup, LockupTranched } from "@sablier/lockup/src/types/DataTypes.sol";

import { LockupBenchmark } from "./Benchmark.sol";

/// @notice Contract to benchmark Lockup streams created using Tranched model.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract LockupTranchedBenchmark is LockupBenchmark {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint128[] internal _tranches = [2, 10, 100];
    uint256[] internal _streamIdsForWithdraw = new uint256[](4);

    /*//////////////////////////////////////////////////////////////////////////
                                COMPUTE GAS FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testComputeGas_Implementations() external {
        // Set the file path.
        benchmarkResultsFile = string.concat(benchmarkResults, "SablierLockup_Tranched.md");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
            data: string.concat(
                "# Benchmarks for the Lockup Tranched model\n\n", "| Implementation | Gas Usage |\n", "| --- | --- |\n"
            )
        });

        vm.warp({ newTimestamp: defaults.END_TIME() });
        gasBurn();

        vm.warp({ newTimestamp: defaults.WARP_26_PERCENT() });

        gasCancel();

        gasRenounce();

        // Create streams with different number of tranches.
        for (uint256 i; i < _tranches.length; ++i) {
            gasCreateWithDurationsLT({ totalTranches: _tranches[i] });
            gasCreateWithTimestampsLT({ totalTranches: _tranches[i] });

            gasWithdraw_ByRecipient(
                _streamIdsForWithdraw[0],
                _streamIdsForWithdraw[1],
                string.concat("(", vm.toString(_tranches[i]), " tranches)")
            );
            gasWithdraw_ByAnyone(
                _streamIdsForWithdraw[2],
                _streamIdsForWithdraw[3],
                string.concat("(", vm.toString(_tranches[i]), " tranches)")
            );
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                        GAS BENCHMARKS FOR CREATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function gasCreateWithDurationsLT(uint128 totalTranches) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        // Calculate gas usage.
        (Lockup.CreateWithDurations memory params, LockupTranched.TrancheWithDuration[] memory tranches) =
            _createWithDurationParamsLT(totalTranches);

        uint256 beforeGas = gasleft();
        lockup.createWithDurationsLT(params, tranches);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithDurationsLT` (", vm.toString(totalTranches), " tranches) | ", gasUsed, " |");

        _appendToFile(benchmarkResultsFile, contentToAppend);

        // Store the last 2 streams IDs for withdraw gas benchmark.
        _streamIdsForWithdraw[0] = lockup.nextStreamId() - 2;
        _streamIdsForWithdraw[1] = lockup.nextStreamId() - 1;

        // Create 2 more streams for withdraw gas benchmark.
        _streamIdsForWithdraw[2] = lockup.createWithDurationsLT(params, tranches);
        _streamIdsForWithdraw[3] = lockup.createWithDurationsLT(params, tranches);
    }

    function gasCreateWithTimestampsLT(uint128 totalTranches) internal {
        // Set the caller to the Sender for the next calls and change timestamp to before end time.
        resetPrank({ msgSender: users.sender });

        (Lockup.CreateWithTimestamps memory params, LockupTranched.Tranche[] memory tranches) =
            _createWithTimestampParamsLT(totalTranches);
        uint256 beforeGas = gasleft();
        lockup.createWithTimestampsLT(params, tranches);
        string memory gasUsed = vm.toString(beforeGas - gasleft());

        contentToAppend =
            string.concat("| `createWithTimestampsLT` (", vm.toString(totalTranches), " tranches) | ", gasUsed, " |");

        // Append the content to the file.
        _appendToFile(benchmarkResultsFile, contentToAppend);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createWithDurationParamsLT(uint128 totalTranches)
        private
        view
        returns (Lockup.CreateWithDurations memory params, LockupTranched.TrancheWithDuration[] memory tranches_)
    {
        tranches_ = new LockupTranched.TrancheWithDuration[](totalTranches);

        // Populate tranches
        for (uint256 i = 0; i < totalTranches; ++i) {
            tranches_[i] = (
                LockupTranched.TrancheWithDuration({ amount: AMOUNT_PER_TRANCHE, duration: defaults.CLIFF_DURATION() })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalTranches;

        params = defaults.createWithDurations();
        params.broker.fee = ZERO;
        params.totalAmount = depositAmount;
        return (params, tranches_);
    }

    function _createWithTimestampParamsLT(uint128 totalTranches)
        private
        view
        returns (Lockup.CreateWithTimestamps memory params, LockupTranched.Tranche[] memory tranches_)
    {
        tranches_ = new LockupTranched.Tranche[](totalTranches);

        // Populate tranches.
        for (uint256 i = 0; i < totalTranches; ++i) {
            tranches_[i] = (
                LockupTranched.Tranche({
                    amount: AMOUNT_PER_TRANCHE,
                    timestamp: getBlockTimestamp() + uint40(defaults.CLIFF_DURATION() * (1 + i))
                })
            );
        }

        uint128 depositAmount = AMOUNT_PER_SEGMENT * totalTranches;

        params = defaults.createWithTimestamps();
        params.broker.fee = ZERO;
        params.timestamps.start = getBlockTimestamp();
        params.timestamps.end = tranches_[totalTranches - 1].timestamp;
        params.totalAmount = depositAmount;
        return (params, tranches_);
    }
}
