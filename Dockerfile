FROM mcr.microsoft.com/windows:1809

# Set the PowerShell execution policy
RUN [ "powershell", "-command \"Set-ExecutionPolicy -ExecutionPolicy Bypass -Force\""]

COPY UIAutomation C:/UIAutomation/
COPY BlogDemoApp.exe C:/BlogDemoApp.exe
COPY Test-App.ps1 C:/Test-App.ps1

WORKDIR "C:/"

ENTRYPOINT [ "powershell", "C:/Test-App.ps1" ]