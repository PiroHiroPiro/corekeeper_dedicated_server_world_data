# CoreKeeper Dedicated Server Program Path
$CoreKeeperDedicatedServerProgramPath = "C:\Program Files (x86)\Steam\steamapps\common\Core Keeper Dedicated Server"

# Feel free to change these (see README), but keep in mind that changes to this file might be overwritten on update
$CoreKeeperArguments = @("-batchmode", "-logfile", "CoreKeeperServerLog.txt") + $args

try {
    if (Test-Path -Path "$CoreKeeperDedicatedServerProgramPath\GameID.txt") {
        Remove-Item -Path "$CoreKeeperDedicatedServerProgramPath\GameID.txt"
    }

    Start-Process -PassThru -FilePath "$CoreKeeperDedicatedServerProgramPath\CoreKeeperServer.exe" -ArgumentList $CoreKeeperArguments
    Write-Host "Started CoreKeeperServer.exe"

    # Wait for GameID
    while (!(Test-Path -Path "$CoreKeeperDedicatedServerProgramPath\GameID.txt")) {
        Start-Sleep -Milliseconds 100
    }

    Write-Host -NoNewline "Game ID: "
    Get-Content "$CoreKeeperDedicatedServerProgramPath\GameID.txt"
}
finally {
    Pause
}