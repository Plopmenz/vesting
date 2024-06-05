import { Deployer } from "../web3webdeploy/types";

export interface ERC20VestingDeploymentSettings {}

export interface ERC20VestingDeployment {}

export async function deploy(
  deployer: Deployer,
  settings?: ERC20VestingDeploymentSettings
): Promise<ERC20VestingDeployment> {
  return {};
}
