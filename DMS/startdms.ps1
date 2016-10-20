param(
[Parameter(Mandatory=$true)]
[string]$sqlserver = $ENV:SQLSERVER,

[Parameter(Mandatory=$true)]
[string]$previewserver = $ENV:PREVIEWSERVER

)
function Disable-SSLValidation {
<#
.SYNOPSIS
    Disables SSL certificate validation
.DESCRIPTION
    Disable-SSLValidation disables SSL certificate validation by using reflection to implement the System.Net.ICertificatePolicy class.
 
    Author: Matthew Graeber (@mattifestation)
    License: BSD 3-Clause
.NOTES
    Reflection is ideal in situations when a script executes in an environment in which you cannot call csc.ese to compile source code. If compiling code is an option, then implementing System.Net.ICertificatePolicy in C# and Add-Type is trivial.
.LINK
    http://www.exploit-monday.com
#>
 
    Set-StrictMode -Version 2
 
    # You have already run this function
    if ([System.Net.ServicePointManager]::CertificatePolicy.ToString() -eq 'IgnoreCerts') { Return }
 
    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('IgnoreCerts')
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('IgnoreCerts', $false)
    $TypeBuilder = $ModuleBuilder.DefineType('IgnoreCerts', 'AutoLayout, AnsiClass, Class, Public, BeforeFieldInit', [System.Object], [System.Net.ICertificatePolicy])
    $TypeBuilder.DefineDefaultConstructor('PrivateScope, Public, HideBySig, SpecialName, RTSpecialName') | Out-Null
    $MethodInfo = [System.Net.ICertificatePolicy].GetMethod('CheckValidationResult')
    $MethodBuilder = $TypeBuilder.DefineMethod($MethodInfo.Name, 'PrivateScope, Public, Virtual, HideBySig, VtableLayoutMask', $MethodInfo.CallingConvention, $MethodInfo.ReturnType, ([Type[]] ($MethodInfo.GetParameters() | % {$_.ParameterType})))
    $ILGen = $MethodBuilder.GetILGenerator()
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ldc_I4_1)
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ret)
    $TypeBuilder.CreateType() | Out-Null
 
    # Disable SSL certificate validation
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object IgnoreCerts
    
}

# [Environment]::SetEnvironmentVariable("IMCC_SERVERNAME", "localhost", [EnvironmentVariableTarget]::Machine)
# [Environment]::SetEnvironmentVariable("IMCC_PORT", "1086", [EnvironmentVariableTarget]::Machine)
# [Environment]::SetEnvironmentVariable("IMCC_PROTOCOL", "http", [EnvironmentVariableTarget]::Machine)
# $env:IMCC_SERVERNAME = "localhost"
# $env:IMCC_PORT = "1086"
# $env:IMCC_PROTOCOL = "http"

Add-OdbcDsn -Name ACTIVE -Drivername "SQL Server" -Platform '64-bit' -DSNType System -SetPropertyValue @("Server=$sqlserver","Trusted_Connection=No", "Database=ACTIVE")
[Environment]::SetEnvironmentVariable("REQUESTS_CA_BUNDLE", "C:\Program Files\Autonomy\WorkSite\Server\work-cert.crt", [EnvironmentVariableTarget]::Machine)

[Environment]::SetEnvironmentVariable("PLUGIN0_ENDPOINT", "http://$($previewserver):8080", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("JRE_HOME", "C:\Program Files\Java\jre1.8.0_101\", [EnvironmentVariableTarget]::Machine)
$env:PLUGIN0_ENDPOINT = "http://$($previewserver):8080"
$env:JRE_HOME = "C:\Program Files\Java\jre1.8.0_101\"
$env:REQUESTS_CA_BUNDLE = "C:\Program Files\Autonomy\WorkSite\Server\work-cert.crt"

#reconfigure certificate path
$confcontent = Get-Content "C:\Program Files\Autonomy\WorkSite\Apache\conf\worksite.conf"
$confcontent = $confcontent.replace('SSLCertificateFile ""','SSLCertificateFile "C:\Program Files\Autonomy\WorkSite\Server\work-cert.crt"').replace('SSLCertificateKeyFile ""','SSLCertificateKeyFile "C:\Program Files\Autonomy\WorkSite\Server\work-key.key"')
Set-Content -path "C:\Program Files\Autonomy\WorkSite\Apache\conf\worksite.conf" -Value $confcontent

#reconfigure rendition file
$rendcontent = Get-Content "C:\Program Files\iManage\MicroServicesHub\config\rendition.cfg"
$rendcontent = $rendcontent.replace('end_point = http://localhost:8080',"end_point = http://$($previewserver):8080")
Set-Content -path "C:\Program Files\iManage\MicroServicesHub\config\rendition.cfg" -Value $rendcontent

#workaround
$myip = $(Get-NetIPAddress -InterfaceAlias vethernet* -AddressFamily ipv4).IPaddress

Add-Content c:\windows\system32\drivers\etc\hosts "$myip  dms.test.lab"

#Copy-Item -Path "c:\dmsshare\web_module" -Destination "C:\Program Files\Autonomy\WorkSite" -Recurse -Force
regedit /s c:\dmsshare\imanage.reg
#stop-service -Name imfmasvc
#stop-service -Name iManageMicroServiceHub
#remove-item -Path "C:\Program Files\Autonomy\WorkSite\Server\Logs\FmaLog.txt"
Start-Service -Name imDmsSvc

Disable-SSLValidation
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
import-certificate -FilePath "C:\Program Files\Autonomy\WorkSite\Server\work-cert.crt" -CertStoreLocation Cert:\LocalMachine\Root
#Invoke-WebRequest -uri https://127.0.0.1 -Method get

Start-Sleep -Seconds 3

start-service -Name imfmasvc
start-service -Name activemq
Start-Sleep -Seconds 3
start-service -Name iManageMicroServiceHub
Start-Sleep -Seconds 3
<#while ($true) {
    if (Test-Path -Path "C:\Program Files\Autonomy\WorkSite\Server\Logs\DmsLog.txt"){
        get-content "C:\Program Files\Autonomy\WorkSite\Server\Logs\DmsLog.txt" -wait
    }
    Start-Sleep -Seconds 1
}#>
while ($true) {
    if (Test-Path -Path "C:\Program Files\iManage\MicroServicesHub\\apache\Logs\MicroServicesHub.log"){
        get-content "C:\Program Files\iManage\MicroServicesHub\\apache\Logs\MicroServicesHub.log" -wait
    }
    Start-Sleep -Seconds 1
}