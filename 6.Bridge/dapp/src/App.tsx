import { useState } from "react";
import {
    parseEther,
    decodeEventLog,
    encodeFunctionData,
    createWalletClient,
    http,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import {
    useReadContract,
    useWriteContract,
    useWatchContractEvent,
    useBalance,
    useAccount,
    useConnect,
    useDisconnect,
    useSwitchChain,
} from "wagmi";
import { polygonAmoy, bscTestnet } from "wagmi/chains";
import BridgeABI from "./abis/Bridge.json";
import TokenABI from "./abis/Token.json";
import WrappedTokenABI from "./abis/WrappedToken.json";

const BSC_BRIDGE_ADDRESS = import.meta.env
    .VITE_BSC_BRIDGE_ADDRESS as `0x${string}`;
const POLYGON_BRIDGE_ADDRESS = import.meta.env
    .VITE_POLYGON_BRIDGE_ADDRESS as `0x${string}`;
const BSC_TOKEN_ADDRESS = import.meta.env
    .VITE_BSC_TOKEN_ADDRESS as `0x${string}`;
const POLYGON_WTOKEN_ADDRESS = import.meta.env
    .VITE_POLYGON_WTOKEN_ADDRESS as `0x${string}`;
const PRIVATE_KEY = import.meta.env.VITE_PRIVATE_KEY as `0x${string}`;

function App() {
    const { isConnected } = useAccount();
    const { connect, connectors } = useConnect();
    const { disconnect } = useDisconnect();
    const [ethAmount, setEthAmount] = useState("");
    const [network, setNetwork] = useState("bsc");
    const { address, status: accountStatus, chain } = useAccount();
    const { switchChain } = useSwitchChain();
    const { writeContractAsync } = useWriteContract();
    const account = privateKeyToAccount(PRIVATE_KEY);

    const clientPolygonOwner = createWalletClient({
        account,
        chain: polygonAmoy,
        transport: http(),
    });

    const clientBscOwner = createWalletClient({
        account,
        chain: bscTestnet,
        transport: http(),
    });

    // Fetch balance for the connected account
    const {
        data: balance,
        isError: balanceError,
        isLoading: isBalanceLoading,
    } = useBalance({
        address: address,
    });

    // Fetch token balance for the connected account
    const {
        data: bscData,
        isError: bscError,
        isLoading: bscLoading,
    } = useReadContract({
        address: BSC_TOKEN_ADDRESS,
        abi: TokenABI,
        functionName: "balanceOf",
        chainId: bscTestnet.id,
        args: [address],
    });

    // Fetch token balance for the connected account
    const {
        data: polygonData,
        isError: polygonError,
        isLoading: polygonLoading,
    } = useReadContract({
        address: POLYGON_WTOKEN_ADDRESS,
        abi: WrappedTokenABI,
        functionName: "balanceOf",
        chainId: polygonAmoy.id,
        args: [address],
    });

    // Listen for TokensLocked on BSC
    useWatchContractEvent({
        address: BSC_BRIDGE_ADDRESS,
        abi: BridgeABI,
        eventName: "TokensLocked",
        chainId: bscTestnet.id,
        onLogs: (logs) => {
            console.log("New TokensLocked event", logs),
                logs.forEach(async (log) => {
                    try {
                        const decodedLog = decodeEventLog({
                            abi: BridgeABI,
                            data: log.data,
                            topics: log.topics,
                            eventName: "TokensLocked",
                        });

                        const args = decodedLog.args as unknown as {
                            user: string;
                            amount: bigint;
                            targetChain: string;
                        };

                        const { user, amount, targetChain } = args;

                        console.log(
                            `Lock tokens for user: ${user}, amount: ${amount}, target chain: ${targetChain}`
                        );

                        if (targetChain === "Polygon") {
                            console.log("Switching network to Polygon...");

                            switchNetwork(polygonAmoy.id);
                        }

                        mintTokens(user, amount);
                    } catch (err) {
                        console.error("Error decoding log: ", err);
                    }
                });
        },
        onError: (error) => {
            console.error("Error watching event: ", error);
        },
    });

    // Listen for TokensBurned on Polygon
    useWatchContractEvent({
        address: BSC_BRIDGE_ADDRESS,
        abi: BridgeABI,
        eventName: "TokensBurned",
        chainId: polygonAmoy.id,
        onLogs: (logs) => {
            console.log("New TokensBurned event", logs),
                logs.forEach(async (log) => {
                    try {
                        const decodedLog = decodeEventLog({
                            abi: BridgeABI,
                            data: log.data,
                            topics: log.topics,
                            eventName: "TokensBurned",
                        });

                        const args = decodedLog.args as unknown as {
                            user: string;
                            amount: bigint;
                            sourceChain: string;
                        };

                        const { user, amount, sourceChain } = args;

                        console.log(
                            `Burn tokens for user: ${user}, amount: ${amount}, source chain: ${sourceChain}`
                        );

                        if (sourceChain === "BSC") {
                            console.log("Switching network to BSC...");

                            switchNetwork(bscTestnet.id);
                        }

                        releaseTokens(user, amount);
                    } catch (err) {
                        console.error("Error decoding log: ", err);
                    }
                });
        },
        onError: (error) => {
            console.error("Error watching event: ", error);
        },
    });

    async function switchNetwork(toNetworkId: number) {
        if (chain?.id === bscTestnet.id && toNetworkId === polygonAmoy.id) {
            console.log("Switching network to Polygon...");
            switchChain({ chainId: toNetworkId });
        } else if (
            chain?.id === polygonAmoy.id &&
            toNetworkId === bscTestnet.id
        ) {
            console.log("Switching network to BSC...");
            switchChain({ chainId: toNetworkId });
        }
    }

    // Mint tokens on Polygon (viem hook)
    async function mintTokens(user: string, amount: bigint) {
        try {
            const functionData = encodeFunctionData({
                abi: BridgeABI,
                functionName: "mintTokens",
                args: [user, amount],
            });

            const tx = await clientPolygonOwner.sendTransaction({
                to: POLYGON_BRIDGE_ADDRESS,
                data: functionData,
            });

            console.log("Mint Tokens TX: ", tx);
        } catch (error) {
            console.error("Error minting tokens: ", error);
        }
    }

    // Release tokens on BSC (viem hook)
    async function releaseTokens(user: string, amount: bigint) {
        try {
            const functionData = encodeFunctionData({
                abi: BridgeABI,
                functionName: "releaseTokens",
                args: [user, amount],
            });

            const tx = await clientBscOwner.sendTransaction({
                to: BSC_BRIDGE_ADDRESS,
                data: functionData,
            });

            console.log("Release Tokens TX: ", tx);
        } catch (error) {
            console.error("Error releasing tokens: ", error);
        }
    }

    // Get approve to lock tokens
    const lockApprove = async () => {
        try {
            const tx = await writeContractAsync({
                address: BSC_TOKEN_ADDRESS,
                abi: TokenABI,
                functionName: "approve",
                chainId: bscTestnet.id,
                args: [BSC_BRIDGE_ADDRESS, parseEther(ethAmount)],
            });
            console.log("Lock Approve TX: ", tx);
        } catch (error) {
            console.error("Error approving: ", error);
        }
    };

    // Lock Tokens on BSC
    const lockTokens = async () => {
        try {
            const tx = await writeContractAsync({
                address: BSC_BRIDGE_ADDRESS,
                abi: BridgeABI,
                functionName: "lockTokens",
                chainId: bscTestnet.id,
                args: [parseEther(ethAmount), "Polygon"],
            });

            console.log("Lock Tokens TX: ", tx);
        } catch (error) {
            console.error("Error locking tokens: ", error);
        }
    };

    // Get approve to burn tokens
    const burnApprove = async () => {
        try {
            const tx = await writeContractAsync({
                address: POLYGON_WTOKEN_ADDRESS,
                abi: WrappedTokenABI,
                functionName: "approve",
                chainId: polygonAmoy.id,
                args: [POLYGON_BRIDGE_ADDRESS, parseEther(ethAmount)],
            });
            console.log("Burn Approve TX: ", tx);
        } catch (error) {
            console.error("Error approving: ", error);
        }
    };

    // Burn Tokens on Polygon
    const burnTokens = async () => {
        try {
            const tx = await writeContractAsync({
                address: POLYGON_BRIDGE_ADDRESS,
                abi: BridgeABI,
                functionName: "burnTokens",
                chainId: polygonAmoy.id,
                args: [parseEther(ethAmount), "BSC"],
            });
            console.log("Burn Tokens TX:", tx);
        } catch (error) {
            console.error("Error burning tokens: ", error);
        }
    };

    // Handle form submit
    const handleSubmit = async (e: { preventDefault: () => void }) => {
        e.preventDefault();
        if (network === "bsc") {
            switchNetwork(bscTestnet.id);

            await lockApprove();
            await lockTokens();
        } else {
            switchNetwork(polygonAmoy.id);

            await burnApprove();
            await burnTokens();
        }
    };

    return (
        <div>
            <div>
                <h2>Wallet info</h2>
                <div>
                    Status: {accountStatus}
                    <br />
                    Chain: {chain?.name}
                    <br />
                    Address: {address}
                    <br />
                    Balance:{" "}
                    {isBalanceLoading
                        ? "Loading..."
                        : balanceError
                        ? "Error fetching balance"
                        : `${balance?.formatted} ${balance?.symbol}`}
                    <br />
                    <br />
                    BSC Testnet Token Balance:{" "}
                    {bscLoading
                        ? "Loading..."
                        : bscError
                        ? "-"
                        : `${(Number(bscData) / 1e18).toFixed(6)}`}{" "}
                    CAT
                    <br />
                    Polygon Testnet Token Balance:{" "}
                    {polygonLoading
                        ? "Loading..."
                        : polygonError
                        ? "-"
                        : `${(Number(polygonData) / 1e18).toFixed(6)}`}{" "}
                    wCAT
                    <br />
                    <br />
                </div>

                {accountStatus === "connected" && (
                    <button type="button" onClick={() => disconnect()}>
                        Disconnect
                    </button>
                )}
            </div>
            <div className="bridge-container">
                <h2>Bridge Tokens</h2>

                {!isConnected && (
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
                )}

                {isConnected && (
                    <form onSubmit={handleSubmit}>
                        <label>Select Network: </label>
                        <select
                            value={network}
                            onChange={(e) => setNetwork(e.target.value)}
                        >
                            <option value="bsc">BSC to Polygon</option>
                            <option value="polygon">Polygon to BSC</option>
                        </select>

                        <br />

                        <label>Amount to Transfer: </label>
                        <input
                            type="number"
                            value={ethAmount}
                            onChange={(e) => setEthAmount(e.target.value)}
                            placeholder="Enter amount (eth)"
                            required
                        />

                        <br />
                        <br />

                        <button type="submit">Submit</button>
                    </form>
                )}
            </div>
        </div>
    );
}

export default App;
