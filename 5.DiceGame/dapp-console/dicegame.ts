import {
    createPublicClient,
    createWalletClient,
    http,
    parseEther,
    encodeFunctionData,
    decodeEventLog,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { sepolia } from "viem/chains";
import { formatEther } from "viem";

import { config } from "./config";
import { dicegameAbi } from "./abi";

const account = privateKeyToAccount(config.PRIVATE_KEY as `0x${string}`);

const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(),
});

const walletClient = createWalletClient({
    account,
    chain: sepolia,
    transport: http(),
});

// Type Definitions
type BetResultEvent = {
    player: `0x${string}`;
    won: boolean;
    payout: bigint;
    randomNumber: number;
};

// Function to Place a Bet
async function placeBet(
    guessedNumber: number,
    betAmount: string
): Promise<void> {
    const data = encodeFunctionData({
        abi: dicegameAbi,
        functionName: "placeBet",
        args: [guessedNumber],
    });

    try {
        const tx = await walletClient.sendTransaction({
            to: config.CONTRACT_ADDRESS as `0x${string}`,
            value: parseEther(betAmount),
            data,
        });
        console.log("Transaction sent:", tx);
    } catch (err) {
        console.error("Error placing bet:", err);
    }
}

// Function to Process a Bet
async function processBet(requestId: bigint): Promise<void> {
    const data = encodeFunctionData({
        abi: dicegameAbi,
        functionName: "processBet",
        args: [requestId],
    });

    try {
        const tx = await walletClient.sendTransaction({
            to: config.CONTRACT_ADDRESS as `0x${string}`,
            data,
        });
        console.log("Transaction sent:", tx);
    } catch (err) {
        console.error("Error processing bet:", err);
    }
}

// Function to Listen for Bet Results
async function listenForBetResults(): Promise<void> {
    publicClient.watchContractEvent({
        address: config.CONTRACT_ADDRESS as `0x${string}`,
        abi: dicegameAbi,
        eventName: "BetResult",
        onLogs: (logs) => {
            logs.forEach((log) => {
                const event = decodeEventLog({
                    abi: ABI,
                    data: log.data,
                    topics: log.topics,
                    eventName: "BetResult",
                }) as BetResultEvent;

                console.log("Bet Result:");
                console.log(`Player: ${event.player}`);
                console.log(`Won: ${event.won}`);
                console.log(`Payout: ${event.payout} wei`);
                console.log(`Random Number: ${event.randomNumber}`);
            });
        },
        pollingInterval: 5000, // Poll every 5 seconds
    });
}

// Example Usage
(async () => {
    // Listen for Bet Results
    listenForBetResults();

    // Place a Bet
    await placeBet(3, "0.01"); // Guessing number 3 with 0.01 ETH

    // Process a Bet
    await processBet(BigInt(1)); // Replace 1 with the actual requestId
})();

// try {
//     const client = createPublicClient({
//         chain: sepolia,
//         transport: http(),
//     });

//     client.watchContractEvent({
//         address: config.CONTRACT_ADDRESS as `0x${string}`,
//         abi: dicegameAbi,
//         onLogs: (logs) => {
//             // const messages = logs.map(
//             //     ({ eventName, args }) =>
//             //         `<b>${eventName}</b> <code>${
//             //             args["account"]
//             //         }</code> <i>${formatEther(args["amount"])}</i> `
//             // );
//             // const messages = logs.map((log) => `${log}`);
//             // console.log(messages.join("\n"));

//             onLogs: (logs) => console.log(logs);
//         },
//     });
// } catch (error) {
//     console.error(error);
//     process.exitCode = 1;
// }
