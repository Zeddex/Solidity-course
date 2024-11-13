import {
  useAccount,
  useConnect,
  useDisconnect,
  useBalance,
  useGasPrice,
} from "wagmi";

function App() {
  const { address, status: accountStatus, chain } = useAccount();
  const { status: connectStatus, error } = useConnect();
  const { disconnect } = useDisconnect();

  // Fetch balance for the connected account
  const {
    data: balance,
    isError: balanceError,
    isLoading: isBalanceLoading,
  } = useBalance({
    address: address,
  });

  const { data: gasPrice } = useGasPrice();

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

        {/* {accountStatus === "connected" && (
          <button type="button" onClick={() => disconnect()}>
            Disconnect
          </button>
        )} */}
      </div>

      <div>
        <w3m-button />
        <div>status: {connectStatus}</div>
        <div>{error?.message}</div>
      </div>
    </>
  );
}

export default App;
