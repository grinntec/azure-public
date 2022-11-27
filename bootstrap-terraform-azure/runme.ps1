function Set-ConfigVars
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $FileName
    )

    if (Test-Path -Path $FileName) 
    {
        $values = @{}
        Get-Content $FileName | Where-Object {$_.length -gt 0} | Where-Object {!$_.StartsWith("#")} | ForEach-Object {
            $var = $_.Split('=',2).Trim()
            $values[$var[0]] = $var[1]
        }
        return $values
    }
    else
    {
        Write-Error "Configuration file missing."
        exit 1
    }
}

function main 
{
    #load the environment variables
    $configVarsFileName = "the-environment.env"
    $configVars = Set-ConfigVars -FileName $configVarsFileName

    #connect to azure
    write-host ""
    write-host "Connecting to Azure..." -ForegroundColor Magenta
    Connect-AzAccount -SubscriptionId $configVars.az_sub_id -TenantId $configvars.az_tenant_id -ErrorAction Stop | Out-Null
    Write-Host "Logged into Azure subscription:" $(Get-AzContext).Subscription.Name -ForegroundColor Green

    #create resource group
    $rg_name_joined = $configVars.rg_name + $configVars.ref
    Write-Host ""
    Write-Host "Creating resource group: " $rg_name_joined -ForegroundColor Magenta
    New-AzResourceGroup -Name $rg_name_joined `
                        -Location $configVars.az_region
    #create tags
    Write-Host "Creating tags" -ForegroundColor Magenta
    $tag1 = $configVars.tag1 | ConvertFrom-StringData
    $tag2 = $configVars.tag2 | ConvertFrom-StringData
    $resource = Get-AzResourceGroup -Name $rg_name_joined
    New-AzTag   -ResourceId $resource.resourceid `
                -Tag $tag1
    
    Update-AzTag -ResourceId $resource.ResourceId `
                 -Tag $tag2 `
                 -Operation Merge

    Start-Sleep -Seconds 15

    #create lock
    Write-Host "Creating resource group level CanNotDeletelock" -ForegroundColor Magenta
    New-AzResourceLock  -LockName "CanNotDelete" `
                        -LockLevel CanNotDelete `
                        -LockNotes "Created by bootstrap-terraform-azure" `
                        -ResourceGroupName $rg_name_joined `
                        -Confirm:$false `
                        -force
    
    #create a new storage account
    $sa_name_joined = $configVars.sa_name + $configVars.ref
    write-host ""
    Write-Host "Creating storage account: " $sa_name_joined -ForegroundColor Magenta
    New-AzStorageAccount -ResourceGroupName $rg_name_joined `
                         -Name $sa_name_joined `
                         -Location $configVars.az_region `
                         -SkuName Standard_LRS `
                         -ErrorAction Stop

    #create a new storage account container
    write-host ""
    Write-Host "Creating storage account container: " $configvars.sa_con_name -ForegroundColor Magenta
    $ctx = New-AzStorageContext -StorageAccountName $sa_name_joined -UseConnectedAccount
    New-AzStorageContainer  -Name $configVars.sa_con_name `
                            -Permission Off `
                            -Context $ctx `
                            -ErrorAction Stop

    #create a new storage account container
    $kv_name_joined = $configVars.kv_name + $configVars.ref
    write-host ""
    Write-Host "Creating key vault: " $kv_name_joined -ForegroundColor Magenta
    New-AzKeyVault  -Name $kv_name_joined `
                    -ResourceGroupName $rg_name_joined `
                    -Location $configVars.az_region

    #create sp
    $sp_name_joined = $configVars.sp_name + $configVars.ref
    write-host ""
    Write-Host "Creating service principal: " $sp_name_joined -ForegroundColor Magenta
    $subId = (Get-AzContext).Subscription.id
    $tenId = (Get-AzContext).Tenant.id
    $sp = New-AzADServicePrincipal -DisplayName $sp_name_joined -Role "Contributor"
    
    #write values to key vault
    $sp.AppId
    $sp.PasswordCredentials.SecretText
    $ARM_CLIENT_ID = ConvertTo-SecureString $sp.AppId -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName kvtfstategrinntecsandbox -Name "ARMCLIENTID" -SecretValue $ARM_CLIENT_ID
    $ARM_CLIENT_SECRET = ConvertTo-SecureString $sp.PasswordCredentials.SecretText -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName kvtfstategrinntecsandbox -Name "ARMCLIENTSECRET" -SecretValue $ARM_CLIENT_SECRET
    $ARM_SUBSCRIPTION_ID = ConvertTo-SecureString $subId -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName kvtfstategrinntecsandbox -Name "ARMSUBSCRIPTIONID" -SecretValue $ARM_SUBSCRIPTION_ID
    $ARM_TENANT_ID = ConvertTo-SecureString $tenId -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName kvtfstategrinntecsandbox -Name "ARMTENANTID" -SecretValue $ARM_TENANT_ID
}

main
