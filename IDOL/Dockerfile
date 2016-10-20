FROM microsoft/windowsservercore
ENV sqlserver _
ENV defaulthost _
VOLUME c:\\dmsshare
RUN sc config lanmanworkstation depend= "MrxSmb20/NSI"
RUN mkdir c:\INSTALL
ADD INSTALL c:\INSTALL
RUN powershell -Command \
start-process c:\INSTALL\jre-8u101-windows-i586.exe -ArgumentList '/s INSTALLDIR=C:\JRE REPAIRMODE=1 WEB_JAVA=0' -Wait
RUN C:\INSTALL\vcredist_2005_x64.exe /q
RUN C:\INSTALL\vcredist_2005_x86.exe /q
RUN C:\INSTALL\vcredist_2010_x86.exe /q
RUN C:\INSTALL\vcredist_2010_x64.exe /q
WORKDIR c:\\INSTALL\\deploy
ADD reconfigurejvmpath.ps1 .
RUN powershell ./reconfigurejvmpath
RUN _deploy_services.bat
ADD install_services.ps1 .
RUN powershell ./install_services
WORKDIR c:\\INSTALL
ADD stop-worksiteservices.ps1 .
RUN powershell ./stop-worksiteservices
ADD reconfigureidol.ps1 .
CMD powershell ./reconfigureidol -sqlserver %sqlserver% -defaulthost %defaulthost%