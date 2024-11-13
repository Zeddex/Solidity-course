import { createPublicClient, getContract, http } from "viem";
import { sepolia } from "viem/chains";
import { formatEther } from "viem";
import { Telegram } from "telegram-send";

import { config } from "./config";
import { bankAbi } from "./abi";

const tg = new Telegram(config.BOT_TOKEN, config.CHAT_ID.toString());

try {
  const client = createPublicClient({
    chain: sepolia,
    transport: http(),
  });

  //   const contract = getContract({
  //     address: "0x000000",
  //     abi: bankAbi,
  //     client,
  //   });

  //   const balance = await contract.read.balanceOf("0x000000");

  //client.getBalance({address: "0x000000"});

  const unwatch = client.watchContractEvent({
    address: config.CONTRACT_ADDRESS as `0x${string}`,
    abi: bankAbi,
    onLogs: (logs) => {
      const messages = logs.map(
        ({ eventName, args }) =>
          `<b>${eventName}</b> <code>${args["account"]}</code> <i>${formatEther(
            args["amount"]
          )}</i> `
      );
      tg.send(messages.join("\n"));
    },
  });
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}
