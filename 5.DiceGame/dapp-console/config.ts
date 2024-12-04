import * as dotenv from "dotenv";
import { parseEnv, z } from "znv";

dotenv.config();

export const config = parseEnv(process.env, {
    PRIVATE_KEY: z.string().regex(/^0x[a-fA-F0-9]{40}$/),
    CONTRACT_ADDRESS: z.string().regex(/^0x[a-fA-F0-9]{40}$/),
});
