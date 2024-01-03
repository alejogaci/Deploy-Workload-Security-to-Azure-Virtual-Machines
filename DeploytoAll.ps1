param (
    [string]$LinuxScriptPath,
    [string]$WindowsScriptPath
)

# Verificar si Azure CLI está instalado
if (!(Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it before running this script."
    Exit 1
}

# Obtener información sobre todas las máquinas virtuales en la suscripción
$vms = az vm list --query "[].{Name:name, ResourceGroup:resourceGroup, Tags:tags}" --output json | ConvertFrom-Json

# Configurar el número máximo de trabajos en paralelo
$maximumJobs = 10  # Puedes ajustar este valor según tus necesidades

# Crear un script block para el comando Invoke-AzVMRunCommand
$scriptBlockLinux = {
    param ($resourceGroupName, $vmName, $scriptPath)
    Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -Name $vmName -CommandId 'RunShellScript' -ScriptPath $scriptPath
}

$scriptBlockWindows = {
    param ($resourceGroupName, $vmName, $scriptPath)
    Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptPath $scriptPath
}

# Ejecutar el comando en paralelo para máquinas virtuales con el tag "wls:linux_true" o "wls:windows_true"
$jobs = @()
foreach ($vm in $vms) {
    if ($vm.Tags) {
        if ($vm.Tags.wls -eq "linux_true") {
            $job = Start-ThreadJob -ScriptBlock $scriptBlockLinux -ArgumentList $vm.ResourceGroup, $vm.Name, $LinuxScriptPath
        } elseif ($vm.Tags.wls -eq "windows_true") {
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

# Esperar a que todos los trabajos se completen
$jobs | Receive-Job -Wait -AutoRemoveJob

Write-Host "Proceso completado."
