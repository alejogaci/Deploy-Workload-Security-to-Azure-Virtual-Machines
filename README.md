# Deploy-Workload-Security-to-Azure-Virtual-Machines
Set of scripts used to deploy massive workload security to azure virtual machines either Windows or Linux in any of its supported distributions.

## Prerequisites

- PowerShell
- Azure PowerShell Module (Az)
  - Install the module by running `Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser` if not already installed.
- Otherwise you can use Azure cloudshell
- Download the Deployment script from Trend Micro Vision One

# Usage

1. **Clone or Download the Script:**
   Clone this repository:
   ```powershell
   git clone https://github.com/alejogaci/Deploy-Workload-Security-to-Azure-Virtual-Machines.git

2. **Azure VM Tagging Script (Tags.ps1):**
   The Tags.ps1 script selects the virtual machines in the Azure subscription to which Workload Security is going to be installed. If you do not want to make exceptions and it is going to be installed on all the machines in the subscription, the script must be used in the following way.
   ```powershell
   ./Tags.ps1
    ```
    If there are machines that are going to be excluded from the installation, the script must be used as follows
   ```powershell
   ./Tags.ps1 -ExclusionFile "path\to\Exclusions.txt"
    ```
    Alternatively, if Workload Security is only going to be installed on a short list of machines, so as not to have a very long list of exclusions, this list can be indicated as follows:
   ```powershell
   ./Tags.ps1 -InclusionFile ""path\to\Inclusions.txt""
    ```
   
    In the exclusions or inclusions file you must put the names of the virtual machines, here is an example of what these files should look like.
   ```bash
   Linux1
   windows2
   Debian1
   windowsserver2
   ```
4. **Deploy to all VM (DeploytoAll.ps1):**
   The DeploytoAll.ps1 script deploys workload security on all subscription machines, this script must be executed together with the deployment script downloaded from Vision One as follows:
   ```powershell
   ./DeploytoAll.ps1 -LinuxScriptPath "path\to\LinuxDeploymentScript.sh" -WindowsScriptPath "path\to\WindowsDeploymentScript"
    ```
    The previous example assumes that it is going to be deployed in bulk for both Linux and Widnows, however the script can be executed with at least one of the -LinuxScriptPath or -WindowsScriptPath arguments, both are not necessary.



