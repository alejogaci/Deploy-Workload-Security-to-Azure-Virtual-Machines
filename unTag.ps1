# Instalar el módulo de Azure PowerShell si no está instalado
if (!(Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
}

# Obtener información sobre todas las máquinas virtuales en la suscripción
$vms = Get-AzVM

# Iniciar sesión en Azure
Connect-AzAccount

# Iterar sobre las máquinas virtuales y quitar tags
foreach ($vm in $vms) {
    $resourceGroupName = $vm.ResourceGroupName
    $vmName = $vm.Name
    $osType = $vm.StorageProfile.OsDisk.OsType

    # Quitar tags según el sistema operativo
    if ($osType -eq 'Linux') {
        Write-Host "Quitando tag wls:linux_true de la VM $vmName"
        Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = $null} -Force
    } elseif ($osType -eq 'Windows') {
        Write-Host "Quitando tag wls:windows_true de la VM $vmName"
        Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = $null} -Force
    }
}

Write-Host "Proceso completado. Se han quitado los tags especificados."