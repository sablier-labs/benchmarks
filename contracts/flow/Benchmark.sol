// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud21x18 } from "@prb/math/src/UD21x18.sol";
import { ISablierFlow } from "@sablier/flow/src/interfaces/ISablierFlow.sol";
import { Constants } from "@sablier/flow/tests/utils/Constants.sol";
import { Utils } from "@sablier/flow/tests/utils/Utils.sol";
import { Users } from "@sablier/flow/tests/utils/Types.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

/// @notice Contract to benchmark Flow streams.
/// @dev This contract creates a Markdown file with the gas usage of each function.
contract FlowBenchmark is Constants, StdCheats, Utils {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The path to the file where the benchmark results are stored.
    string internal benchmarkResultsFile = "results/flow/SablierFlow.md";

    uint256 internal streamId;

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
        // Fork Ethereum Mainnet at the latest block.
        vm.createSelectFork("mainnet");

        // Load deployed addresses from Ethereum mainnet.
        flow = ISablierFlow(0x3DF2AAEdE81D2F6b261F79047517713B8E844E04);

        // Load USDC token.
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        // Create some users.
        users.recipient = payable(makeAddr("recipient"));
        users.sender = payable(makeAddr("sender"));

        deal({ token: address(usdc), to: users.sender, give: type(uint128).max });
        resetPrank({ msgSender: users.sender });
        usdc.approve(address(flow), type(uint128).max);

        for (uint8 count; count < 100; ++count) {
            depositDefaultAmount({ _streamId: createDefaultStream() });
        }

        // Set the streamId to 50 for the test function.
        streamId = 50;

        // Create the file if it doesn't exist, otherwise overwrite it.
        vm.writeFile({
            path: benchmarkResultsFile,
            data: string.concat("# Benchmarks using 6-decimal token \n\n", "| Function | Gas Usage |\n", "| --- | --- |\n")
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function testComputeGas_Implementations() external {
        // {flow.adjustRatePerSecond}
        computeGas(
            "adjustRatePerSecond",
            abi.encodeCall(flow.adjustRatePerSecond, (streamId, ud21x18(RATE_PER_SECOND_U128 + 1)))
        );

        // {flow.create}
        computeGas(
            "create", abi.encodeCall(flow.create, (users.sender, users.recipient, RATE_PER_SECOND, usdc, TRANSFERABLE))
        );

        // {flow.deposit}
        computeGas(
            "deposit", abi.encodeCall(flow.deposit, (streamId, DEPOSIT_AMOUNT_6D, users.sender, users.recipient))
        );

        // {flow.pause}
        computeGas("pause", abi.encodeCall(flow.pause, (streamId)));

        // {flow.refund} on an incremented stream ID
        computeGas("refund", abi.encodeCall(flow.refund, (++streamId, REFUND_AMOUNT_6D)));

        // {flow.refundMax} on an incremented stream ID.
        computeGas("refundMax", abi.encodeCall(flow.refundMax, (++streamId)));

        // Pause the current stream to test the restart function.
        flow.pause(streamId);

        // {flow.restart}
        computeGas("restart", abi.encodeCall(flow.restart, (streamId, RATE_PER_SECOND)));

        // {flow.void} (on a solvent stream)
        computeGas("void (solvent stream)", abi.encodeCall(flow.void, (streamId)));

        // Warp time to accrue uncovered debt for the next call on an incremented stream ID..
        vm.warp(flow.depletionTimeOf(++streamId) + 2 days);

        // {flow.void} (on an insolvent stream)
        computeGas("void (insolvent stream)", abi.encodeCall(flow.void, (streamId)));

        // {flow.withdraw} (on an insolvent stream) on an incremented stream ID.
        computeGas(
            "withdraw (insolvent stream)",
            abi.encodeCall(flow.withdraw, (++streamId, users.recipient, WITHDRAW_AMOUNT_6D))
        );

        // Deposit amount on an incremented stream ID to make stream solvent.
        flow.deposit(
            ++streamId, uint128(flow.uncoveredDebtOf(streamId)) + DEPOSIT_AMOUNT_6D, users.sender, users.recipient
        );

        // {flow.withdraw} (on a solvent stream).
        computeGas(
            "withdraw (solvent stream)", abi.encodeCall(flow.withdraw, (streamId, users.recipient, WITHDRAW_AMOUNT_6D))
        );

        // {flow.withdrawMax} on an incremented stream ID.
        computeGas("withdrawMax", abi.encodeCall(flow.withdrawMax, (++streamId, users.recipient)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Compute gas usage of a given function using low-level call.
    function computeGas(string memory name, bytes memory payload) internal {
        // Simulate the passage of time.
        vm.warp(getBlockTimestamp() + 2 days);

        uint256 initialGas = gasleft();
        (bool status,) = address(flow).call(payload);
        string memory gasUsed = vm.toString(initialGas - gasleft());

        // Ensure the function call was successful.
        require(status, "Benchmark: call failed");

        // Append the gas usage to the benchmark results file.
        string memory contentToAppend = string.concat("| `", name, "` | ", gasUsed, " |");
        vm.writeLine({ path: benchmarkResultsFile, data: contentToAppend });
    }

    function createDefaultStream() internal returns (uint256) {
        return flow.create({
            sender: users.sender,
            recipient: users.recipient,
            ratePerSecond: RATE_PER_SECOND,
            token: usdc,
            transferable: TRANSFERABLE
        });
    }

    function depositDefaultAmount(uint256 _streamId) internal {
        uint8 decimals = flow.getTokenDecimals(_streamId);
        uint128 depositAmount = getDefaultDepositAmount(decimals);

        flow.deposit(_streamId, depositAmount, users.sender, users.recipient);
    }
}
