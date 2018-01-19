# https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime
#Create
Login-AzureRmAccount

$resouceGroupName = "lalofran-sea-rg-03"
$dataFactoryName = "lalofrandf01"
$selfHostedIntegrationRuntimeName = "lalofrandfruntime01"

$selfHostedIntegrationRuntime = New-AzureRmDataFactoryV2IntegrationRuntime -ResourceGroupName $resouceGroupName `
    -DataFactoryName $dataFactoryName `
    -Name $selfHostedIntegrationRuntimeName `
    -Type SelfHosted `
    -Description "MongoDb"

Get-AzureRmDataFactoryV2IntegrationRuntimeKey -ResourceGroupName `
    $resouceGroupName -DataFactoryName `
    $dataFactoryName -Name `
    $selfHostedIntegrationRuntimeName