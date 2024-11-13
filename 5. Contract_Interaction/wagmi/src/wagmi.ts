import { mainnet, sepolia } from "@reown/appkit/networks";
import { createAppKit } from "@reown/appkit/react";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";

const projectId = "33ecd2ea4d40ad7239e40e3610ab8820";

const metadata = {
  name: "AppKit",
  description: "AppKit Example",
  url: "https://web3modal.com", // origin must match your domain & subdomain
  icons: ["https://avatars.githubusercontent.com/u/179229932"],
};

export const networks = [mainnet, sepolia];

const wagmiAdapter = new WagmiAdapter({
  ssr: true,
  networks,
  projectId,
});

export const config = wagmiAdapter.wagmiConfig;

createAppKit({
  adapters: [wagmiAdapter],
  networks: [mainnet, sepolia],
  metadata,
  projectId,
  features: {
    analytics: true,
  },
});
