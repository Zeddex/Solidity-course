import { useState } from "react";
import { parseEther } from "viem";
import {
  useAccount,
  useConnect,
  useDisconnect,
  useBalance,
  useGasPrice,
  useSendTransaction,
} from "wagmi";

function App() {
  const { address, status: accountStatus, chain } = useAccount();
  const { status: connectStatus, error } = useConnect();
  const { disconnect } = useDisconnect();

  const { sendTransaction } = useSendTransaction();
  const [toAddress, setToAddress] = useState("");
  const [ethAmount, setEthAmount] = useState("");

  // Fetch balance for the connected account
  const {
    data: balance,
    isError: balanceError,
    isLoading: isBalanceLoading,
  } = useBalance({
    address: address,
  });

  const { data: gasPrice } = useGasPrice();

  const handleSendTransaction = async () => {
    if (!toAddress || !ethAmount) {
      alert("Please enter a valid address and amount.");
      return;
    }

    try {
      sendTransaction({
        to: toAddress as `0x${string}`,
        value: parseEther(ethAmount),
      });
    } catch (error) {
      alert("Error sending transaction");
    }
  };

  return (
    <>
      <div>
        <h2>Account</h2>

        <div>
          status: {accountStatus}
          <br />
          address: {JSON.stringify(address)}
          <br />
          chainName: {chain?.name}
          <br />
          chainId: {chain?.id}
          <br />
          gasPrice: {gasPrice?.toString()}
          <br />
          balance:
          {isBalanceLoading
            ? "Loading..."
            : balanceError
              ? "Error fetching balance"
              : `${balance?.formatted} ${balance?.symbol}`}
        </div>

        {/* Disconnect Button */}
        {/* {accountStatus === "connected" && (
          <button type="button" onClick={() => disconnect()}>
            Disconnect
          </button>
        )} */}
      </div>

      {/* Connect Status */}
      <div>
        <w3m-button />
        <div>status: {connectStatus}</div>
        <div>{error?.message}</div>
      </div>

      {/* Send Transaction Form */}
      <div>
        <h3>Send Transaction</h3>
        <input
          type="text"
          placeholder="Recipient Address"
          value={toAddress}
          onChange={(e) => setToAddress(e.target.value)}
        />
        <input
          type="number"
          placeholder="ETH Amount"
          value={ethAmount}
          onChange={(e) => setEthAmount(e.target.value)}
        />
        <button type="button" onClick={handleSendTransaction}>
          Send Transaction
        </button>
      </div>
    </>
  );
}

export default App;
