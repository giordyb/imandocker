$services = @("Worksite Connector", "Worksite Active Content","Worksite Active DIH", "Worksite Content", "Worksite IDOL", "Worksite Ingestion Server")
foreach ($service in $services) {
    cd "C:\Program Files\Autonomy\indexer\$service"
    Write-Output "Installing $service"
    start-process -FilePath "$service.exe" -ArgumentList "-install" -Wait
}
cd "C:\Program Files\Autonomy\indexer\Worksite SyncTool"
Write-Output "Installing Worksite SyncTool"
start-process -filepath "_install_service.bat"
Write-Output $(Get-Service -Name Worksite*)