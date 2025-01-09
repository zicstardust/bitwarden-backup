function Interval {
    param (
        [Parameter(Mandatory)]
        [string]$Interval,
        [Parameter(Mandatory=$false)]
        [Switch]$CheckError
    )

    if ($CheckError){
        if((-not($Interval.Substring(0, $Interval.Length - 1) -match "^\d+$")) -Or (-not($Interval[-1] -match "[s|m|h|d|w]"))){
            return $true
        } else {
            return $false
        }
    }

    [char]$lastChar = $Interval[-1]
    [Int64]$time = $Interval.Substring(0, $Interval.Length - 1)

    if ($lastChar -Eq "s") {
        return $time
    }

    if ($lastChar -Eq "m") {
        return $time*60
    }

    if ($lastChar -Eq "h") {
        return $time*3600
    }

    if ($lastChar -Eq "d") {
        return $time*86400
    }

    if ($lastChar -Eq "w") {
        return $time*604800
    }
}

function CheckVariables {
    if (-not ($env:BW_CLIENTID)){
        Write-Error "BW_CLIENTID not set"
        exit 1
    }
    
    if (-not ($env:BW_CLIENTSECRET)){
        Write-Error "BW_CLIENTSECRET not set"
        exit 1
    }
    
    if (-not ($env:MASTER_PASSWORD)){
        Write-Error "MASTER_PASSWORD not set"
        exit 1
    }
    
    if (-not ($env:ENCRYPTION_KEY)){
        Write-Error "ENCRYPTION_KEY not set"
        exit 1
    }

    if(-not($env:KEEP_LAST -match "^\d+$")){
        Write-Error "invalid KEEP_LAST"
        exit 1
    }
    
    if($(Interval -Interval $env:INTERVAL -CheckError) -eq $true){
        Write-Error "invalid INTERVAL"
        exit 1
    }
   
}

function Remove-OldBackups {
    param (
        [Parameter(Mandatory)]
        [string]$Include
    )

    if ($env:KEEP_LAST -eq 0){
        return
    }

    [Array]$files_list = $(Get-ChildItem -Path "/data/" -Name -Include "*$Include*")

    if ($files_list.Length -ge $env:KEEP_LAST) {
        
        for ($i = 0; $i -lt $($files_list.Length - $env:KEEP_LAST); $i++) {
           Remove-Item -LiteralPath "/data/$($files_list[$i])" -Force -Confirm:$false -Verbose
        }

    } else {
        Write-Output "Number of backups less than KEEP_LAST"
    }
    
}

function Set-URLServer {

    $BW_SERVER="$env:BW_SERVER_BASE "

    if ($env:BW_SERVER_WEB_VAULT){
        $BW_SERVER = $BW_SERVER + "--web-vault $env:BW_SERVER_WEB_VAULT "
    }

    if ($env:BW_SERVER_API){
        $BW_SERVER = $BW_SERVER + "--api $env:BW_SERVER_API "
    }

    if ($env:BW_SERVER_IDENTITY){
        $BW_SERVER = $BW_SERVER + "--identity $env:BW_SERVER_IDENTITY "
    }

    if ($env:BW_SERVER_ICONS){
        $BW_SERVER = $BW_SERVER + "--icons $env:BW_SERVER_ICONS "
    }

    if ($env:BW_SERVER_NOTIFICATIONS){
        $BW_SERVER = $BW_SERVER + "--notifications $env:BW_SERVER_NOTIFICATIONS "
    }

    if ($env:BW_SERVER_EVENTS){
        $BW_SERVER = $BW_SERVER + "--events $env:BW_SERVER_EVENTS "
    }

    if ($env:BW_SERVER_KEY_CONNECTOR){
        $BW_SERVER = $BW_SERVER + "--key-connector $env:BW_SERVER_KEY_CONNECTOR "
    }

    /usr/local/bin/bw config server $BW_SERVER | Out-Null
}

function Backup {
    $DATE=(Get-Date -Format "yyyy.MM.dd-HH:mm:ss")

    $status=$(/usr/local/bin/bw status)

    if ($env:SELF_HOSTED -eq "True"){
        Set-URLServer
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
        $FILENAME="${DATE}_bitwarden-backup.json"
        Write-Output "Backup individual vault..."
        /usr/local/bin/bw --raw --session $BW_SESSION `
                            export --format encrypted_json `
                            --password $env:ENCRYPTION_KEY | `
                            Out-File -FilePath "/data/$FILENAME"
        Remove-OldBackups -Include "bitwarden-backup"
    }

    #backup organizations
    if ($env:ORGANIZATION_IDS) {
        $ORGANIZATIONS=$env:ORGANIZATION_IDS.Split(',')

        Write-Output "Backup organization vault..."

        foreach ($ORGANIZATION in $ORGANIZATIONS) {
            $FILENAME_ORG="${DATE}_ORG_${ORGANIZATION}.json"

            /usr/local/bin/bw --raw --session $BW_SESSION `
                                export --organizationid $ORGANIZATION --format encrypted_json `
                                --password $env:ENCRYPTION_KEY | `
                                Out-File -FilePath "/data/$FILENAME_ORG"
            Remove-OldBackups -Include "ORG_${ORGANIZATION}"
        }
    }
}

function Main {

    while ($true) {
        CheckVariables
        Backup
        Write-Output "next execution in $env:INTERVAL"
        Start-Sleep -Seconds $(Interval -Interval $env:INTERVAL)
    }
    
}

Main
