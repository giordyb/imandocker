FROM microsoft/windowsservercore
ARG PIDKEY
ARG MOBILITY_PIDKEY
ARG SDK_LICENSE_PIDKEY
ARG CLUSTERING_PIDKEY
ARG APACHE_SERVER_NAME
ENV SQLSERVER _
ENV PREVIEWSERVER _
RUN mkdir C:\dmsshare
RUN mkdir c:\INSTALL
ADD INSTALL c:\INSTALL
WORKDIR C:\\INSTALL
RUN sc config lanmanworkstation depend= "MrxSmb20/NSI"
RUN powershell -Command \
copy-item -Path c:\INSTALL\mapi32.dll -Destination c:\windows\system32\mapi32.dll
RUN vc2008sp1redist_x64.exe /Q
RUN vc2008sp1redist_x86.exe /Q
RUN NDP451-KB2858728-x86-x64-AllOS-ENU.exe /q /norestart 
RUN c:\windows\system32\msiexec.exe /i python-2.7.9.amd64.msi /qn ALLUSERS=1 MSIFASTINSTALL=7 REBOOT=ReallySuppress CLIENTUILEVEL=3 MSICLIENTUSESEXTERNALUI=1 CLIENTPROCESSID=1020
RUN c:\INSTALL\vc_2005_sp1_redist_x64.exe /Q
RUN c:\INSTALL\vc_2013_redist_x64.exe /quiet /norestart
RUN c:\windows\system32\msiexec.exe /i Redis-x64-3.0.500.msi /qn
RUN powershell.exe -Command \
start-process jre-8u101-windows-x64.exe -ArgumentList '/s REPAIRMODE=1 WEB_JAVA=0' -wait
RUN c:\windows\system32\msiexec.exe /qn /i imanage.msi PIDKEY=%PIDKEY% MOBILITY_PIDKEY=%MOBILITY_PIDKEY% SDK_LICENSE_PIDKEY=%SDK_LICENSE_PIDKEY% APACHE_SERVER_NAME=%APACHE_SERVER_NAME% SVRCONFIG_OPTIONS=generate
RUN powershell stop-service imdmssvc
RUN c:\windows\system32\msiexec.exe /qn /i clustering.msi SERIALNUMBER=%CLUSTERING_PIDKEY%
RUN C:\windows\system32\msiexec.exe /qn /i SetupMicroServices.msi
RUN powershell stop-process -name httpd -Force
RUN powershell Set-Service -Name imdmssvc -StartupType Manual
RUN powershell Set-Service -Name activemq -StartupType Manual
RUN powershell Set-Service -Name iManageMicroServiceHub -StartupType Manual
RUN powershell Set-Service -Name imfmasvc -StartupType Manual
RUN powershell Set-Service -Name imDsSyncSvc -StartupType Manual
ADD jre.reg .
RUN regedit /s jre.reg
VOLUME c:\\dmsshare
ADD startdms.ps1 . 
CMD powershell ./startdms -sqlserver %SQLSERVER% -previewserver %PREVIEWSERVER%
