export const dicegameAbi = [
    [
        { inputs: [], stateMutability: "nonpayable", type: "constructor" },
        {
            anonymous: false,
            inputs: [
                {
                    indexed: true,
                    internalType: "address",
                    name: "player",
                    type: "address",
                },
                {
                    indexed: false,
                    internalType: "uint256",
                    name: "amount",
                    type: "uint256",
                },
                {
                    indexed: false,
                    internalType: "uint8",
                    name: "guessedNumber",
                    type: "uint8",
                },
            ],
            name: "BetPlaced",
            type: "event",
        },
        {
            anonymous: false,
            inputs: [
                {
                    indexed: true,
                    internalType: "address",
                    name: "player",
                    type: "address",
                },
                {
                    indexed: false,
                    internalType: "bool",
                    name: "won",
                    type: "bool",
                },
                {
                    indexed: false,
                    internalType: "uint256",
                    name: "payout",
                    type: "uint256",
                },
                {
                    indexed: false,
                    internalType: "uint8",
                    name: "randomNumber",
                    type: "uint8",
                },
            ],
            name: "BetResult",
            type: "event",
        },
        {
            inputs: [
                {
                    internalType: "uint256",
                    name: "requestId",
                    type: "uint256",
                },
            ],
            name: "bets",
            outputs: [
                { internalType: "address", name: "player", type: "address" },
                { internalType: "uint256", name: "amount", type: "uint256" },
                {
                    internalType: "uint8",
                    name: "guessedNumber",
                    type: "uint8",
                },
            ],
            stateMutability: "view",
            type: "function",
        },
        {
            inputs: [],
            name: "fundContract",
            outputs: [],
            stateMutability: "payable",
            type: "function",
        },
        {
            inputs: [],
            name: "owner",
            outputs: [{ internalType: "address", name: "", type: "address" }],
            stateMutability: "view",
            type: "function",
        },
        {
            inputs: [
                {
                    internalType: "uint8",
                    name: "guessedNumber",
                    type: "uint8",
                },
            ],
            name: "placeBet",
            outputs: [],
            stateMutability: "payable",
            type: "function",
        },
        {
            inputs: [
                {
                    internalType: "uint256",
                    name: "requestId",
                    type: "uint256",
                },
            ],
            name: "processBet",
            outputs: [],
            stateMutability: "nonpayable",
            type: "function",
        },
        {
            inputs: [],
            name: "withdraw",
            outputs: [],
            stateMutability: "nonpayable",
            type: "function",
        },
    ],
] as const;