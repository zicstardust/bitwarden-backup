function bw (args, envs = ""){
    const execSync = require("child_process").execSync;
    //const result = execSync(envs + " ./node_modules/@bitwarden/cli/build/bw.js " + args);
    const result = execSync(envs + " /usr/local/bin/bw " + args);
    return result.toString("utf8");
}

/*
function bw (args){
    const execSync = require("child_process").execSync;
    //const result = execSync("./node_modules/@bitwarden/cli/build/bw.js " + args);
    const result = execSync("/usr/local/bin/bw " + args);
    return result.toString("utf8");
}




const { exit } = require("process");
function bw (args){
    const { exec } = require("child_process");    
    exec("/usr/local/bin/bw " + args, (error, stdout, stderr) => {
    //exec("node_modules/@bitwarden/cli/build/bw.js " + args, (error, stdout, stderr) => {
        if (error) {
            return console.log(`${error.message}`);
        }
        if (stderr) {
            return console.log(`${stderr}`);;
        }
        return console.log(`${stdout}`);
    });
}
*/
function Interval(interval) {
    var lastChar = interval.substr(interval.length - 1);
    var time = interval.slice(0, -1);

    if(lastChar == "s") { 
        mm = time*1000
    } 
    else if(lastChar == "m") { 
        mm = (time*60)*1000
    }
    else if(lastChar == "h") { 
        mm = (time*3600)*1000
    }
    else if(lastChar == "d") { 
        mm = (time*86400)*1000
    }
    else if(lastChar == "w") { 
        mm = (time*604800)*1000
    }
    else { 
        console.log("interval invalid")
        exit(1)
    }
    //return new Promise(resolve => setTimeout(resolve, seconds));
    //return setTimeout("", seconds*1000)
    return mm
}

function CheckVariables (){
    if (!process.env.BW_CLIENTID){
        console.log("BW_CLIENTID not set")
        exit(1)
    }

    if (!process.env.BW_CLIENTSECRET){
        console.log("BW_CLIENTSECRET not set")
        exit(1)
    }

    if (!process.env.MASTER_PASSWORD){
        console.log("MASTER_PASSWORD not set")
        exit(1)
    }

    if (!process.env.ENCRYPTION_KEY){
        console.log("ENCRYPTION_KEY not set")
        exit(1)
    }

    var regex = new RegExp('^[0-9]$')
    if (!regex.test(process.env.KEEP_LAST)){
        console.log("invalid KEEP_LAST")
        exit(1)
    }

    //if (!process.env.INTERVAL){
    //    console.log("INTERVAL not set")
    //    exit(1)
    //}
}

function RemoveOldBackups(include){

    if (process.env.KEEP_LAST == 0){
        return console.log("Delete old backup: KEEP_LAST=0, keeping all backups")
    }

    var fs = require('fs');
    var dirContents = fs.readdirSync('/data/');
    var files_list = dirContents.filter((dirContents) => dirContents.match(`${include}`));

    if (files_list.length >= process.env.KEEP_LAST){
        for (var i = 0; i < (files_list.length - process.env.KEEP_LAST); i++) {
            fs.unlink("/data/" + i);
            console.log("Delete old backup: " + i);
          }
    } else {
        console.log("Delete old backup: Nothing - Number of backups less than KEEP_LAST");
    }
}

function SetURLServer(){
    var BW_SERVER = process.env.BW_SERVER_BASE

    if(process.env.BW_SERVER_WEB_VAULT) {
        BW_SERVER = BW_SERVER + ` --web-vault ${process.env.BW_SERVER_WEB_VAULT}`;
    }

    if(process.env.BW_SERVER_API) {
        BW_SERVER = BW_SERVER + ` --api ${process.env.BW_SERVER_API}`;
    }

    if(process.env.BW_SERVER_IDENTITY) {
        BW_SERVER = BW_SERVER + ` --identity ${process.env.BW_SERVER_IDENTITY}`;
    }

    if(process.env.BW_SERVER_ICONS) {
        BW_SERVER = BW_SERVER + ` --icons ${process.env.BW_SERVER_ICONS}`;
    }

    if(process.env.BW_SERVER_NOTIFICATIONS) {
        BW_SERVER = BW_SERVER + ` --notifications ${process.env.BW_SERVER_NOTIFICATIONS}`;
    }

    if(process.env.BW_SERVER_EVENTS) {
        BW_SERVER = BW_SERVER + ` --events ${process.env.BW_SERVER_EVENTS}`;
    }

    if(process.env.BW_SERVER_KEY_CONNECTOR) {
        BW_SERVER = BW_SERVER + ` --key-connector ${process.env.BW_SERVER_KEY_CONNECTOR}`;
    }

    bw(`config server ${BW_SERVER}`);
}

function Backup(){
    var now = new Date();
    //date = now.getFullYear() + "." + now.getMonth() + "." + now.getDate() + "-" + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds()
    date = `${now.getFullYear()}.${now.getMonth()}.${now.getDate()}-${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`

    check_status = bw("status")


    if (process.env.BW_SERVER_BASE) {
        SetURLServer()
    }
    
    //login
    if(check_status.search(`${process.env.CLIENT_ID}`) < 0){
        //console.log("login...")
        bw("login --apikey",`BW_CLIENTID=${process.env.BW_CLIENTID} BW_CLIENTSECRET=${process.env.BW_CLIENTSECRET}`)
    }

    //get session
    BW_SESSION = bw(`unlock --raw ${process.env.MASTER_PASSWORD}`)


    //backup
    if (process.env.BACKUP_ORGANIZATION_ONLY == true) {
        console.log("BACKUP_ORGANIZATION_ONLY is True, skip individual vault backup...")
    } else {
        FILENAME = date + "_bitwarden-backup.json"
        backup = bw(`--raw --session ${BW_SESSION} export --format encrypted_json --password ${process.env.ENCRYPTION_KEY}`) 
        const fs = require('fs')
        fs.writeFile("/data/" + FILENAME, backup, (err) => {
            if (err) throw err;
        })
        console.log("Backup individual vault done: " + FILENAME)
        RemoveOldBackups("bitwarden-backup")
    }

    //backup organizations
    if(process.env.ORGANIZATION_IDS) {
        ORGANIZATIONS = process.env.ORGANIZATION_IDS.split(',')

        ORGANIZATIONS.forEach(element => {
            FILENAME = date + "_ORG_" + element + ".json"
            backup = bw(`--raw --session ${BW_SESSION} export --organizationid ${element} --format encrypted_json --password ${process.env.ENCRYPTION_KEY}`) 
            const fs = require('fs')
            fs.writeFile("/data/" + FILENAME, backup, (err) => {
                if (err) throw err;
            })
        })
        console.log("Backup organization vault done: " + FILENAME)
        RemoveOldBackups("ORG_" + ORGANIZATION)

    } else {
        console.log("No set ORGANIZATION_IDS, skip organization vault backup...")
    }
}

//Main
function Main(){
    //CheckVariables
    //Backup
    return console.log("nothing")
    
}


//while(true){
    CheckVariables()
    Backup()
    console.log("Next execution " + process.env.INTERVAL)
    setTimeout(Main, Interval(process.env.INTERVAL))
//}

