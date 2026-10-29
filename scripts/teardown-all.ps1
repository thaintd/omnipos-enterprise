$ErrorActionPreference = "Stop"

Write-Host "Dang thu hoi toan bo ha tang Giỏ 2 (rg-omnipos-prod) ve 0 dong..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot\..\infra"

terraform destroy -auto-approve

Write-Host "Da xoa sach ha tang tinh phi! File State trong Giỏ 1 van duoc bao toan." -ForegroundColor Green
Set-Location -Path "$PSScriptRoot\.."