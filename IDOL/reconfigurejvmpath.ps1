$scriptpath= split-path $myInvocation.MyCommand.Path
set-location $scriptpath
$cfgfiles = Get-ChildItem *.cfg -Recurse
foreach ($cfgfile in $cfgfiles) {
$content = Get-Content $cfgfile
$content = $content.replace('//JVMLibraryPath=./jre/bin/client','JVMLibraryPath=C:\jre\bin\client')
Set-Content -path $cfgfile -Value $content
}
