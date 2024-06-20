import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { readFileSync } from "fs";
import { reviver } from "./json.js";

const item = BigInt(
  "27119446983538875518964261104627996864456975630380434672876616786595364534019"
);

const tree = StandardMerkleTree.load(
  JSON.parse(readFileSync("tree.json", { encoding: "utf-8" }), reviver)
);

console.log("Proof:", tree.getProof([item]));
