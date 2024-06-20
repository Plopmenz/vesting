import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { writeFileSync } from "fs";
import { replacer } from "./json.js";

const treeType: "uint256" | "address" = "uint256";
const treeValues = [
  BigInt(
    "66865460347234752678960140969186284171427803471896834805845375773322248855196"
  ),
  BigInt(
    "27119446983538875518964261104627996864456975630380434672876616786595364534019"
  ),
  BigInt(
    "87891659457111812605629781959708134444463429165428336399599890698422167512910"
  ),
  BigInt(
    "8776161139390468814759143453328985317609269510652187071484032175585997510460"
  ),
];

const tree = StandardMerkleTree.of(
  treeValues.map((val) => [val]),
  [treeType]
);

console.log("Merkle Root:", tree.root);

writeFileSync("tree.json", JSON.stringify(tree.dump(), replacer));
