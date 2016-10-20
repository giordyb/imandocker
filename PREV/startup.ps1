$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_101\"
cd c:\install\tomcat\bin\ 
.\startup.bat
while (!(Test-Path c:\dps\logs\dps.log.0)) {
    Start-Sleep -Seconds 10
}
Add-Content c:\windows\system32\drivers\etc\hosts "$env:DMSIP  dms.test.lab"
Get-Content c:\dps\logs\dps.log.0 -wait