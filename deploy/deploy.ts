import { Deployer } from "../web3webdeploy/types";

export interface VestingDeploymentSettings {}

export interface VestingDeployment {}

export async function deploy(
  deployer: Deployer,
  settings?: VestingDeploymentSettings
): Promise<VestingDeployment> {
  return {};
}
