import { Deployer } from "../web3webdeploy/types";

export interface ERC20VestingDeploymentSettings {}

export interface ERC20VestingDeployment {}

export async function deploy(
  deployer: Deployer,
  settings?: ERC20VestingDeploymentSettings
): Promise<ERC20VestingDeployment> {
  const token = "0x2902b792Af43Ea1481569bc35b62a31BB2C20E95";
  const amount = BigInt(10_000) * BigInt(10) ** BigInt(18);
  const start = Math.round(Date.UTC(2024, 6 - 1, 6) / 1000);
  const duration = 7 * 24 * 60 * 60;
  const merkletreeRoot =
    "0x302f24131c5d4f4bbfc308760fd33784076b2c14cbf5043fa944d0d6c168e714";
  const ownerToken = "0xa84a1cc30864514afEB1E4f9cf8440467308b892";
  await deployer.deploy({
    contract: "MultiERC721TokenLinearERC20TransferVesting",
    args: [token, amount, start, duration, /*merkletreeRoot,*/ ownerToken],
  });

  return {};
}
