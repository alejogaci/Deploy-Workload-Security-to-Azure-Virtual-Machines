param (
    [string]$LinuxScriptPath,
    [string]$WindowsScriptPath
)

# Check if at least one script path is provided
if (-not $LinuxScriptPath -and -not $WindowsScriptPath) {
    Write-Host "Error: At least one of LinuxScriptPath or WindowsScriptPath must be provided."
    Exit 1
}

# Check if Azure CLI is installed
if (!(Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it before running this script."
    Exit 1
}

# Get information about all virtual machines in the subscription
$vms = az vm list --query "[].{Name:name, ResourceGroup:resourceGroup, Tags:tags}" --output json | ConvertFrom-Json

# Configure the maximum number of parallel jobs
$maximumJobs = 10  # Puedes ajustar este valor según tus necesidades

# Create a script block for the Invoke-AzVMRunCommand command if LinuxScriptPath is provided
$scriptBlockLinux = if ($LinuxScriptPath) {
    {
        param ($resourceGroupName, $vmName, $scriptPath)
        Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -Name $vmName -CommandId 'RunShellScript' -ScriptPath $scriptPath
    }
}

# Create a script block for the Invoke-AzVMRunCommand command if WindowsScriptPath is provided
$scriptBlockWindows = if ($WindowsScriptPath) {
    {
        param ($resourceGroupName, $vmName, $scriptPath)
        Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptPath $scriptPath
    }
}

# Run the command in parallel only if a script block and script path are provided
if ($scriptBlockLinux -or $scriptBlockWindows) {
    $jobs = @()
    foreach ($vm in $vms) {
        if ($vm.Tags) {
            if ($vm.Tags.wls -eq "linux_true" -and $scriptBlockLinux) {
                $job = Start-ThreadJob -ScriptBlock $scriptBlockLinux -ArgumentList $vm.ResourceGroup, $vm.Name, $LinuxScriptPath
            } elseif ($vm.Tags.wls -eq "windows_true" -and $scriptBlockWindows) {
                $job = Start-ThreadJob -ScriptBlock $scriptBlockWindows -ArgumentList $vm.ResourceGroup, $vm.Name, $WindowsScriptPath
            }

            if ($job) {
                $jobs += $job
                if ($jobs.Count -ge $maximumJobs) {
                    # Esperar a que se completen algunos trabajos antes de iniciar más
                    $completedJobs = $jobs | Where-Object { $_.State -eq 'Completed' }
                    $completedJobs | Receive-Job -Wait -AutoRemoveJob
                    $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
                }
            }
        }
    }

    # Wait for all jobs to complete
    $jobs | Receive-Job -Wait -AutoRemoveJob

    Write-Host "Completed process."
} else {
    Write-Host "Error: No valid script path provided. Please provide either LinuxScriptPath or WindowsScriptPath."
}
