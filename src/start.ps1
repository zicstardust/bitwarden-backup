function Remove-OldBackups {
    $files_list = $(Get-ChildItem -Path "/data/").name

    if ($files_list.Length -ge $env:KEEP_LAST) {
        
        for ($i = 0; $i -lt $($files_list.Length - $env:KEEP_LAST); $i++) {
           Remove-Item -LiteralPath "/data/$($files_list[$i])" -Force -Confirm:$false -Verbose
        }

    } else {
        Write-Output "Number of backups less than KEEP_LAST"
    }
    
}

function Backup {
    $DATE=(Get-Date -Format "yyyy.MM.dd-HH:mm:ss")
    $FILENAME="${DATE}_bitwarden-backup.json"
    $FILENAME_ORG="${DATE}_ORG_${env:ORGANIZATION_ID}.json"

    $status=$(/usr/local/bin/bw status)

    if (-not($status.Contains($env:BW_SERVER))) {
        /usr/local/bin/bw config server $env:BW_SERVER | Out-Null
    }

    #login
    if (-not($status.Contains($env:CLIENT_ID))) {
        /usr/local/bin/bw login --apikey | Out-Null
    }

    #get session
    $BW_SESSION=$(/usr/local/bin/bw unlock --raw $env:MASTER_PASSWORD)

    #backup
    if ($env:BACKUP_ORGANIZATION_ONLY -eq "True"){
        Write-Output "BACKUP_ORGANIZATION_ONLY is True, skip individual vault backup"
    } else {
        Write-Output "Backup individual vault..."
        /usr/local/bin/bw --raw --session $BW_SESSION `
    export --format encrypted_json `
    --password $env:ENCRYPTION_KEY | `
    Out-File -FilePath "/data/$FILENAME"
    }

    #backup organization
    if ($env:ORGANIZATION_ID) {
        Write-Output "Backup organization vault..."
        /usr/local/bin/bw --raw --session $BW_SESSION `
        export --organizationid $env:ORGANIZATION_ID --format encrypted_json `
        --password $env:ENCRYPTION_KEY | `
        Out-File -FilePath "/data/$FILENAME_ORG"

    }

}

function Main {
    if (-not ($env:BW_CLIENTID)){
        Write-Output "BW_CLIENTID not set"
        exit 1
    }
    
    if (-not ($env:BW_CLIENTSECRET)){
        Write-Output "BW_CLIENTSECRET not set"
        exit 1
    }
    
    if (-not ($env:MASTER_PASSWORD)){
        Write-Output "MASTER_PASSWORD not set"
        exit 1
    }
    
    if (-not ($env:ENCRYPTION_KEY)){
        Write-Output "ENCRYPTION_KEY not set"
        exit 1
    }

    while ($true) {
        Backup
        Remove-OldBackups
        Write-Output "next execution in $env:INTERVAL seconds"
        Start-Sleep -Seconds $env:INTERVAL
    }
    
}

Main
