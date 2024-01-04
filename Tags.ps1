param (
    [string]$ExclusionFile = "",
    [string]$InclusionFile = ""
)

# Check that only one of the files is used
if ($ExclusionFile -ne "" -and $InclusionFile -ne "") {
    Write-Host "Error: You must specify only one of the files, either ExclusionFile or InclusionFile."
    Exit 1
}

# Install the Azure PowerShell module if it is not installed
if (!(Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
}

# Get information about all virtual machines in the subscription
$vms = Get-AzVM

# Sign in to Azure
Connect-AzAccount

# Obtener la lista de máquinas excluidas
$ExcludedVMs = @()
if ($ExclusionFile -ne "" -and (Test-Path $ExclusionFile)) {
    $ExcludedVMs = Get-Content $ExclusionFile
}

# Get the list of included machines
$IncludedVMs = @()
if ($InclusionFile -ne "" -and (Test-Path $InclusionFile)) {
    $IncludedVMs = Get-Content $InclusionFile
}

# Iterate over virtual machines and assign tags
foreach ($vm in $vms) {
    $resourceGroupName = $vm.ResourceGroupName
    $vmName = $vm.Name
    $osType = $vm.StorageProfile.OsDisk.OsType

    # Verificar si la VM está en la lista de exclusiones
    if ($ExcludedVMs -contains $vmName) {
        Write-Host "VM $vmName is excluded. No tags will be applied."
        continue
    }

    #Check if the VM is in the include list or if the include file is not provided
    if ($IncludedVMs -contains $vmName -or $InclusionFile -eq "") {
        # Asignar tags según el sistema operativo
        if ($osType -eq 'Linux') {
            Write-Host "Adding wls:linux_true tag to VM $vmName"
            Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'linux_true'} -Force
        } elseif ($osType -eq 'Windows') {
            Write-Host "Adding wls:windows_true tag to VM $vmName"
            Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'windows_true'} -Force
        }
    }
}

Write-Host "Completed process."
