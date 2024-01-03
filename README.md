# Deploy-Workload-Security-to-Azure-Virtual-Machines
Set of scripts used to deploy massive workload security to azure virtual machines

## Prerequisites

- PowerShell
- Azure PowerShell Module (Az)
  - Install the module by running `Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser` if not already installed.
- Otherwise you can use Azure cloudshell

# Usage

1. **Clone or Download the Script:**
   Clone this repository
       git clone https://github.com/alejogaci/Deploy-Workload-Security-to-Azure-Virtual-Machines.git

3. **Configure Execution Policy:**
   Before running the script, ensure that PowerShell allows script execution. You can do this by running the following command in PowerShell:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Azure VM Tagging Script (Tags.ps1)

The Tags.ps1 script selects the virtual machines in the Azure subscription to which Workload Security is going to be installed. If you do not want to make exceptions and it is going to be installed on all the machines in the subscription, the script must be used in the following way.

    ./Tags.ps1



