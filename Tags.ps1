param (
    [string]$ExclusionFile = ""
)

# Instalar el módulo de Azure PowerShell si no está instalado
if (!(Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
}

# Verificar si se proporcionó un archivo de exclusión
if ($ExclusionFile -and (Test-Path $ExclusionFile)) {
    $ExcludedVMs = Get-Content $ExclusionFile
} else {
    $ExcludedVMs = @()
}

# Iniciar sesión en Azure
Connect-AzAccount

# Obtener información sobre todas las máquinas virtuales en la suscripción
$vms = Get-AzVM

# Iterar sobre las máquinas virtuales y asignar tags
foreach ($vm in $vms) {
    $resourceGroupName = $vm.ResourceGroupName
    $vmName = $vm.Name
    $osType = $vm.StorageProfile.OsDisk.OsType

    # Verificar si la VM está en la lista de exclusiones
    if ($ExcludedVMs -contains $vmName) {
        Write-Host "La VM $vmName está excluida. No se aplicarán tags."
        continue
    }

    # Asignar tags según el sistema operativo
    if ($osType -eq 'Linux') {
        Write-Host "Añadiendo tag wls:linux_true a la VM $vmName"
        Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'linux_true'} -Force
    } elseif ($osType -eq 'Windows') {
        Write-Host "Añadiendo tag wls:windows_true a la VM $vmName"
        Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'windows_true'} -Force
    }
}

Write-Host "Proceso completado."
