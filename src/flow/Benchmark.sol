// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud21x18 } from "@prb/math/src/UD21x18.sol";
import { ISablierFlow } from "@sablier/flow/src/interfaces/ISablierFlow.sol";
import { Constants } from "@sablier/flow/tests/utils/Constants.sol";
import { Utils } from "@sablier/flow/tests/utils/Utils.sol";
import { Users } from "@sablier/flow/tests/utils/Types.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Logger } from "../Logger.sol";

/// @notice Contract to benchmark Flow streams.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract FlowBenchmark is Constants, Logger, StdCheats, Utils {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    uint8 internal constant USDC_DECIMALS = 6;
    string internal RESULTS_FILE = "results/flow/flow.md";
    uint256[7] internal streamIds;
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                      CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IERC20 internal usdc;
    ISablierFlow internal flow;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public {
        logBlue("Setting up Flow benchmarks...");

        // Fork Ethereum Mainnet at the latest block.
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        uint256 chainId = block.chainid;
        if (chainId != 1) {
            revert("Benchmarking only works on Ethereum Mainnet. Update your RPC URL in .env");
        }
        logGreen("Forked Ethereum Mainnet");

        // Load deployed addresses from Ethereum mainnet.
        // See https://docs.sablier.com/guides/flow/deployments
        flow = ISablierFlow(0x3DF2AAEdE81D2F6b261F79047517713B8E844E04);
        logGreen("Loaded SablierFlow contract");

        // Load USDC token.
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        logGreen("Loaded USDC token contract");

        // Create some users.
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));
        logGreen("Created test users");

        deal({ token: address(usdc), to: users.sender, give: type(uint128).max });
        resetPrank({ msgSender: users.sender });
        usdc.approve(address(flow), type(uint128).max);
        logGreen("Funded and approved USDC");

        for (uint256 i = 0; i < 7; i++) {
            streamIds[i] = _createAndFundStream();
        }
        logGreen("Created 7 test streams");

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: RESULTS_FILE,
            data: string.concat(
                "## Benchmarks for SablierFlow\n\n",
                "With USDC as the streaming token.\n\n",
                "<!-- prettier-sort-markdown-table -->\n",
                "| Function | Stream Solvency | Gas Usage |\n",
                "| :------- | :-------------- | :-------- |\n"
            )
        });
        logBlue("Setup complete! Ready to run benchmarks.");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     BENCHMARK
    //////////////////////////////////////////////////////////////////////////*/

    function test_FlowBenchmark() external {
        logBlue("\nStarting Flow benchmarks...");

        /* -------------------------------- STREAM 0 -------------------------------- */

        instrument(
            "adjustRatePerSecond",
            "N/A",
            abi.encodeCall(flow.adjustRatePerSecond, (streamIds[0], ud21x18(RATE_PER_SECOND_U128 + 1)))
        );

        instrument(
            "create",
            "N/A",
            abi.encodeCall(flow.create, (users.sender, users.recipient, RATE_PER_SECOND, usdc, TRANSFERABLE))
        );
        instrument(
            "deposit",
            "N/A",
            abi.encodeCall(flow.deposit, (streamIds[0], DEPOSIT_AMOUNT_6D, users.sender, users.recipient))
        );

        instrument("pause", "N/A", abi.encodeCall(flow.pause, (streamIds[0])));

        /* -------------------------------- STREAM 1 -------------------------------- */

        instrument("refund", "Solvent", abi.encodeCall(flow.refund, (streamIds[1], REFUND_AMOUNT_6D)));

        /* -------------------------------- STREAM 2 -------------------------------- */

        instrument("refundMax", "Solvent", abi.encodeCall(flow.refundMax, (streamIds[2])));

        // pause in order to instrument restart.
        flow.pause(streamIds[2]);

        instrument("restart", "N/A", abi.encodeCall(flow.restart, (streamIds[2], RATE_PER_SECOND)));

        instrument("void", "Solvent", abi.encodeCall(flow.void, (streamIds[2])));

        /* -------------------------------- STREAM 3 -------------------------------- */

        // warp time to accrue uncovered debt.
        vm.warp(flow.depletionTimeOf(streamIds[3]) + 3 days);
        instrument("void", "Insolvent", abi.encodeCall(flow.void, (streamIds[3])));

        /* -------------------------------- STREAM 4 -------------------------------- */

        // withdraw from an insolvent stream.
        instrument(
            "withdraw", "Insolvent", abi.encodeCall(flow.withdraw, (streamIds[4], users.recipient, WITHDRAW_AMOUNT_6D))
        );

        /* -------------------------------- STREAM 5 -------------------------------- */

        uint128 depositAmount = uint128(flow.uncoveredDebtOf(streamIds[5])) + DEPOSIT_AMOUNT_6D;
        flow.deposit(streamIds[5], depositAmount, users.sender, users.recipient);

        // withdraw from a solvent stream.
        instrument(
            "withdraw", "Solvent", abi.encodeCall(flow.withdraw, (streamIds[5], users.recipient, WITHDRAW_AMOUNT_6D))
        );

        /* -------------------------------- STREAM 6 -------------------------------- */

        instrument("withdrawMax", "Solvent", abi.encodeCall(flow.withdrawMax, (streamIds[6], users.recipient)));

        logBlue("\nCompleted all benchmarks");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Appends a row to the benchmark results file.
    function appendRow(string memory name, string memory solvency, uint256 gasUsed) internal {
        string memory row = string.concat("| `", name, "` | ", solvency, " | ", vm.toString(gasUsed), " |");
        vm.writeLine({ path: RESULTS_FILE, data: row });
    }

    /// @dev Instrument a function call and log the gas usage to the benchmark results file.
    function instrument(string memory name, string memory solvency, bytes memory payload) internal {
        // Simulate the passage of time.
        vm.warp(getBlockTimestamp() + 2 days);

        // Run the function and instrument the gas usage.
        logBlue(string.concat("Benchmarking: ", name));
        uint256 initialGas = gasleft();
        (bool status, bytes memory revertData) = address(flow).call(payload);
        uint256 gasUsed = initialGas - gasleft();
        if (!status) {
            _bubbleUpRevert(revertData);
        }
        logGreen(string.concat("Gas used: ", vm.toString(gasUsed)));

        // Append the row to the benchmark results file.
        appendRow(name, solvency, gasUsed);
    }

    function _bubbleUpRevert(bytes memory revertData) private pure {
        assembly {
            // Get the length of the result stored in the first 32 bytes.
            let resultSize := mload(revertData)

            // Forward the pointer by 32 bytes to skip the length argument, and revert with the result.
            revert(add(32, revertData), resultSize)
        }
    }

    function _createAndFundStream() private returns (uint256) {
        // Create the stream.
        uint256 streamId = flow.create({
            sender: users.sender,
            recipient: users.recipient,
            ratePerSecond: RATE_PER_SECOND,
            token: usdc,
            transferable: TRANSFERABLE
        });

        // Fund the stream.
        uint128 depositAmount = getDefaultDepositAmount(USDC_DECIMALS);
        flow.deposit(streamId, depositAmount, users.sender, users.recipient);

        // Return the stream ID.
        return streamId;
    }
}
