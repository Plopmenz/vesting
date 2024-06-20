export const MultiERC721TokenLinearERC20TransferVestingContract = {
  address: "0x9d1E8A8F2a0C290bbD1e43862e9658466D6A0A6b",
  abi: [
    {
      type: "constructor",
      inputs: [
        { name: "_token", type: "address", internalType: "contract IERC20" },
        { name: "_amount", type: "uint96", internalType: "uint96" },
        { name: "_start", type: "uint64", internalType: "uint64" },
        { name: "_duration", type: "uint64", internalType: "uint64" },
        {
          name: "_ownerToken",
          type: "address",
          internalType: "contract IERC721",
        },
      ],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "amount",
      inputs: [],
      outputs: [{ name: "", type: "uint96", internalType: "uint96" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "beneficiary",
      inputs: [{ name: "_tokenId", type: "uint256", internalType: "uint256" }],
      outputs: [{ name: "", type: "address", internalType: "address" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "duration",
      inputs: [],
      outputs: [{ name: "", type: "uint64", internalType: "uint64" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "ownerToken",
      inputs: [],
      outputs: [
        { name: "", type: "address", internalType: "contract IERC721" },
      ],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "releasable",
      inputs: [{ name: "_tokenId", type: "uint256", internalType: "uint256" }],
      outputs: [{ name: "", type: "uint96", internalType: "uint96" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "release",
      inputs: [{ name: "_tokenId", type: "uint256", internalType: "uint256" }],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "released",
      inputs: [{ name: "tokenId", type: "uint256", internalType: "uint256" }],
      outputs: [{ name: "", type: "uint96", internalType: "uint96" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "start",
      inputs: [],
      outputs: [{ name: "", type: "uint64", internalType: "uint64" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "token",
      inputs: [],
      outputs: [{ name: "", type: "address", internalType: "contract IERC20" }],
      stateMutability: "view",
    },
    {
      type: "event",
      name: "ERC20Released",
      inputs: [
        {
          name: "beneficiary",
          type: "address",
          indexed: false,
          internalType: "address",
        },
        {
          name: "amount",
          type: "uint256",
          indexed: false,
          internalType: "uint256",
        },
      ],
      anonymous: false,
    },
    {
      type: "error",
      name: "AddressEmptyCode",
      inputs: [{ name: "target", type: "address", internalType: "address" }],
    },
    {
      type: "error",
      name: "AddressInsufficientBalance",
      inputs: [{ name: "account", type: "address", internalType: "address" }],
    },
    { type: "error", name: "FailedInnerCall", inputs: [] },
    {
      type: "error",
      name: "SafeERC20FailedOperation",
      inputs: [{ name: "token", type: "address", internalType: "address" }],
    },
  ],
} as const;
