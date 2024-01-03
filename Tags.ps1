param (
    [string]$ExclusionFile = "",
    [string]$InclusionFile = ""
)

# Validar que solo se use uno de los archivos
if ($ExclusionFile -ne "" -and $InclusionFile -ne "") {
    Write-Host "Error: Debes especificar solo uno de los archivos, ya sea ExclusionFile o InclusionFile."
    Exit 1
}

# Instalar el módulo de Azure PowerShell si no está instalado
if (!(Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
}

# Obtener información sobre todas las máquinas virtuales en la suscripción
$vms = Get-AzVM

# Iniciar sesión en Azure
Connect-AzAccount

# Obtener la lista de máquinas excluidas
$ExcludedVMs = @()
if ($ExclusionFile -ne "" -and (Test-Path $ExclusionFile)) {
    $ExcludedVMs = Get-Content $ExclusionFile
}

# Obtener la lista de máquinas incluidas
$IncludedVMs = @()
if ($InclusionFile -ne "" -and (Test-Path $InclusionFile)) {
    $IncludedVMs = Get-Content $InclusionFile
}

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

    # Verificar si la VM está en la lista de inclusiones o si no se proporciona el archivo de inclusión
    if ($IncludedVMs -contains $vmName -or $InclusionFile -eq "") {
        # Asignar tags según el sistema operativo
        if ($osType -eq 'Linux') {
            Write-Host "Añadiendo tag wls:linux_true a la VM $vmName"
            Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'linux_true'} -Force
        } elseif ($osType -eq 'Windows') {
            Write-Host "Añadiendo tag wls:windows_true a la VM $vmName"
            Set-AzResource -ResourceId $vm.Id -Tag @{'wls' = 'windows_true'} -Force
        }
    }
}

Write-Host "Proceso completado."
