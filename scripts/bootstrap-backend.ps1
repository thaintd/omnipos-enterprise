$ErrorActionPreference = "Stop"

$RG_STATE = "rg-omnipos-tfstate"
$STORAGE_ACCOUNT = "stomnipostf2026vn"
$CONTAINER_NAME = "tfstate"
$LOCATION = "indiasouthcentral"

Write-Host "1. Dang tao Resource Group quan tri Terraform State..." -ForegroundColor Cyan
az group create --name $RG_STATE --location $LOCATION

Write-Host "2. Dang tao Storage Account luu tru State..." -ForegroundColor Cyan
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RG_STATE `
  --location $LOCATION `
  --sku Standard_LRS `
  --allow-blob-public-access false

Write-Host "3. Dang tao Blob Container..." -ForegroundColor Cyan
az storage container create `
  --name $CONTAINER_NAME `
  --account-name $STORAGE_ACCOUNT `
  --auth-mode login

Write-Host "Hoan tat Bootstrap! San sang chay terraform init." -ForegroundColor Green