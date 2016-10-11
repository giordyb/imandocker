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


regedit /s c:\dmsshare\imanage.reg
stop-service -Name imfmasvc
remove-item -Path "C:\Program Files\Autonomy\WorkSite\Server\Logs\FmaLog.txt"
Start-Service -Name imDmsSvc
start-service -Name imfmasvc

Disable-SSLValidation
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
import-certificate -FilePath "c:\INSTALL\work-cert.crt" -CertStoreLocation Cert:\LocalMachine\Root
Invoke-WebRequest -uri https://127.0.0.1 -Method get

Start-Sleep -Seconds 3

while ($true) {
    if (Test-Path -Path "C:\Program Files\Autonomy\WorkSite\Server\Logs\DmsLog.txt"){
        get-content "C:\Program Files\Autonomy\WorkSite\Server\Logs\DmsLog.txt" -wait
    }
    Start-Sleep -Seconds 1
}
Stop-Service -Name imdmssvc