param(
[Parameter(Mandatory=$true)]
[string]$sqlserver,

[Parameter(Mandatory=$true)]
[string]$defaulthost
)
Write-Output "reconfiguring idol..."
Write-Output "sqlserver parameter is $sqlserver"
Write-Output "default host parameter is $defaulthost"
$scriptpath= 'C:\Program Files\Autonomy\Indexer'
set-location $scriptpath
$cfgfiles = Get-ChildItem *.cfg -Recurse
foreach ($cfgfile in $cfgfiles) {
    $content = Get-Content $cfgfile
    $content = $content.replace('##defaulthost##',$defaulthost).replace('##sqlserver##',$sqlserver)
    Set-Content -path $cfgfile -Value $content
}
c:\install\deploy\_start_services.bat

while ($true) { 
    get-content "c:\program files\autonomy\indexer\worksite connector\logs\worksitecrawler.log" -wait
}
c:\install\deploy\_stop_services.bat
