import { useState } from "react";
import {
    useAccount,
    useConnect,
    useDisconnect,
    useWriteContract,
    useSimulateContract,
    useWatchContractEvent,
} from "wagmi";
import { decodeEventLog, parseEther } from "viem";
import DiceGameABI from "./DiceGameABI.json";

const CONTRACT_ADDRESS = "0x9482c00b0b85b50557085D5935e670efcB05872B";

function App() {
    const { address, isConnected } = useAccount();
    const { connect, connectors } = useConnect();
    const { disconnect } = useDisconnect();

    const [selectedNumber, setSelectedNumber] = useState<number>(1);
    const [betAmount, setBetAmount] = useState<string>("0.001");
    const [betId, setBetId] = useState<bigint | null>(null);
    const [result, setResult] = useState<string | null>(null);

    const { writeContractAsync } = useWriteContract();
    const {
        data: simulatedBetId,
        isError,
        error,
    } = useSimulateContract({
        abi: DiceGameABI,
        address: CONTRACT_ADDRESS,
        functionName: "placeBet",
        args: [selectedNumber],
        account: address,
        value: parseEther(betAmount),
    });

    const handlePlaceBet = async () => {
        if (isError) {
            console.error("Simulation failed:", error);
            return;
        }

        try {
            console.log("Simulated Bet ID:", simulatedBetId);

            // Ensure the result is a bigint and handle undefined cases
            const betIdFromSimulation = simulatedBetId?.result as
                | bigint
                | undefined;

            if (!betIdFromSimulation) {
                console.error("Simulation did not return a valid bet ID.");
                return;
            }

            setBetId(betIdFromSimulation);
            console.log("Bet ID from simulation:", betIdFromSimulation);

            // Execute the transaction
            const txHash = await writeContractAsync({
                abi: DiceGameABI,
                address: CONTRACT_ADDRESS,
                functionName: "placeBet",
                args: [selectedNumber],
                value: parseEther(betAmount),
            });

            console.log("Transaction hash:", txHash);
        } catch (err) {
            console.error("Error placing bet:", err);
        }
    };

    const handleProcessBet = async () => {
        if (!betId) {
            console.error("No bet ID available. Place a bet first.");
            return;
        }

        try {
            // Call processBet function on the contract
            const txHash = await writeContractAsync({
                abi: DiceGameABI,
                address: CONTRACT_ADDRESS,
                functionName: "processBet",
                args: [betId],
            });

            console.log("Transaction hash:", txHash);
            setResult("Bet processed successfully!");
        } catch (err) {
            console.error("Error processing bet:", err);
        }
    };

    // Watch for BetResult events
    useWatchContractEvent({
        address: CONTRACT_ADDRESS,
        abi: DiceGameABI,
        eventName: "BetResult",
        onLogs: (logs) => {
            logs.forEach((log) => {
                try {
                    // Decode the log using viem's decodeEventLog
                    const decodedLog = decodeEventLog({
                        abi: DiceGameABI,
                        data: log.data,
                        topics: log.topics,
                        eventName: "BetResult",
                    });

                    // Safely extract args and typecast them
                    const args = decodedLog.args as unknown as {
                        player: string;
                        won: boolean;
                        payout: bigint;
                        randomNumber: number;
                    };

                    const { player, won, payout, randomNumber } = args;

                    if (player.toLowerCase() === address?.toLowerCase()) {
                        if (won) {
                            setResult(
                                `Congratulations! You guessed correctly. Random number: ${randomNumber}`
                            );
                        } else {
                            setResult(
                                `Sorry, you lost. Random number: ${randomNumber}`
                            );
                        }
                    }
                } catch (err) {
                    console.error("Error decoding log:", err);
                }
            });
        },
        onError: (error) => {
            console.error("Error watching event:", error);
        },
    });

    return (
        <div>
            <h1>Dice Game</h1>

            {!isConnected ? (
                <div>
                    <h2>Connect Wallet</h2>
                    {connectors.map((connector) => (
                        <button
                            key={connector.id}
                            onClick={() => connect({ connector })}
                        >
                            Connect with {connector.name}
                        </button>
                    ))}
                </div>
            ) : (
                <div>
                    <h2>Welcome, {address}</h2>
                    <button onClick={() => disconnect()}>Disconnect</button>
                </div>
            )}

            {isConnected && (
                <div>
                    <h2>Place Your Bet</h2>
                    <label>
                        Select a number (1-6):
                        <input
                            type="number"
                            min="1"
                            max="6"
                            value={selectedNumber}
                            onChange={(e) =>
                                setSelectedNumber(parseInt(e.target.value))
                            }
                        />
                    </label>
                    <br />
                    <label>
                        Bet Amount (ETH):
                        <input
                            type="text"
                            value={betAmount}
                            onChange={(e) => setBetAmount(e.target.value)}
                        />
                    </label>
                    <br />
                    <button onClick={handlePlaceBet}>Place Bet</button>

                    <h2>Roll Dice</h2>
                    <button onClick={handleProcessBet}>Roll Dice</button>

                    {result && (
                        <div>
                            <h2>Game Result</h2>
                            <p>{result}</p>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}

export default App;
