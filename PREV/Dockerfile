FROM microsoft/windowsservercore
RUN mkdir c:\INSTALL
ADD INSTALL c:\INSTALL
WORKDIR C:\\INSTALL
RUN powershell.exe -Command \
start-process jdk-8u101-windows-x64.exe -ArgumentList '/s REPAIRMODE=1 WEB_JAVA=0' -wait
RUN mkdir c:\dps
RUN mkdir c:\dps\conf
RUN copy c:\install\credentials.txt c:\dps\conf
RUN copy c:\install\dps.* c:\dps\conf
ENV DMSIP _
ADD startup.ps1 .
CMD powershell.exe -File c:\install\startup.ps1