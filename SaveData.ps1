#  Core Keeper Save Data Script
#  Version: 1.2.0
#  Last Updated: 2023/01/08 16:17
#  Author: Hiroyuki Nishizawa

# CoreKeeper Dedicated Server Program Path
$Script:CoreKeeperDedicatedServerProgramPath = "C:\Users\pirop\steamcmd\steamapps\common\Core Keeper Dedicated Server"
# CoreKeeper Dedicated Server Save Data Path
$Script:CoreKeeperDedicatedServerSaveDataPath = "C:\Users\pirop\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer"
# Log File Path
$Script:LogFilePath = "$Script:CoreKeeperDedicatedServerSaveDataPath\SaveData.log"
# -season
# 0:None 
# 1:Easter
# 2:Halloween
# 3:Christmas 
# 4:Valentine
# 5:Anniversary
# 6:Cherry blossom
$Script:Season = 1

# CoreKeeper arguments
$Script:CoreKeeperArguments = @("-batchmode", "-logfile", "CoreKeeperServerLog.txt", "-season", "$Script:Season")

function Quit-CoreKeeperDedicatedServer {
    $Script:ckds_process = Get-Process -Name "CoreKeeperServer" -ErrorAction SilentlyContinue

    if ($Script:ckds_process -ne $null) {
        $Script:ckds_pid = $Script:ckds_process.Id
        taskkill /F /pid $Script:ckds_pid
        Wait-Process -InputObject $Script:ckds_process
        Add-Content -Path $LogFilePath -Value "Stopped CoreKeeperServer.exe (PID: $Script:ckds_pid)"
        Write-Host "Stopped CoreKeeperServer.exe (PID: $Script:ckds_pid)"
    }
}

function Launch-CoreKeeperDedicatedServer {
    if (Test-Path -Path "$Script:CoreKeeperDedicatedServerSaveDataPath\GameID.txt") {
        Remove-Item -Path "$Script:CoreKeeperDedicatedServerSaveDataPath\GameID.txt"
    }

    $Script:ckds_process = Start-Process -PassThru -FilePath "$Script:CoreKeeperDedicatedServerProgramPath\CoreKeeperServer.exe" -ArgumentList $Script:CoreKeeperArguments
    $Script:ckds_pid = $Script:ckds_process.Id
    Add-Content -Path $LogFilePath -Value "Started CoreKeeperServer.exe (PID: $Script:ckds_pid)"
    Write-Host "Started CoreKeeperServer.exe (PID: $Script:ckds_pid)"

    # Wait for GameID
    while (!(Test-Path -Path "$Script:CoreKeeperDedicatedServerSaveDataPath\GameID.txt")) {
        Start-Sleep -Milliseconds 100
    }

    $Script:GameId = Get-Content "$Script:CoreKeeperDedicatedServerSaveDataPath\GameID.txt"
    Add-Content -Path $LogFilePath -NoNewline -Value "Game ID: $Script:GameId"
    Write-Host -NoNewline "Game ID: $Script:GameId"
}

function Update-CoreKeeperDedicatedServer {
    & 'C:\Users\pirop\steamcmd\steamcmd.exe' +login anonymous +app_update 1963720 +quit 
    Add-Content -Path $LogFilePath -Value "Updated CoreKeeperDedicatedServer"
    Write-Host "Updated CoreKeeperDedicatedServer"
}

function Save-CoreKeeperDedicatedServerData {
    Set-Location -Path $Script:CoreKeeperDedicatedServerSaveDataPath
    
    & 'C:\Program Files\Git\cmd\git.exe' add .
    $Script:CurrentDate = Get-Date -Format "yyyy/MM/dd HH:mm K"
    & 'C:\Program Files\Git\cmd\git.exe' commit -m ":+1: save at $Script:CurrentDate"
    & 'C:\Program Files\Git\cmd\git.exe' push origin main
    Add-Content -Path $LogFilePath -Value "Save latest data"
    Write-Host "Save latest data"
}

$Script:CurrentDate = Get-Date -Format "yyyy/MM/dd HH:mm K"
Add-Content -Path $LogFilePath -Value "----- Script starts at $Script:CurrentDate -----"

Quit-CoreKeeperDedicatedServer
Update-CoreKeeperDedicatedServer    
Save-CoreKeeperDedicatedServerData
Launch-CoreKeeperDedicatedServer

Add-Content -Path $LogFilePath -Value ""
Write-Host ""
