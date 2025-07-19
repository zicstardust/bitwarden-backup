#!/usr/bin/env node
import fs from "fs";
import child_process from "child_process";
import { styleText } from 'node:util';

function bw (args){
    const result = child_process.execSync(`/app/node_modules/@bitwarden/cli/build/bw.js ${args}`);
    return result.toString("utf8");
}

function DateTimeNow(){
    let date_ob = new Date();
    let date = ("0" + date_ob.getDate()).toString().slice(-2);
    let month = ("0" + (date_ob.getMonth() + 1)).toString().slice(-2);
    let year = date_ob.getFullYear();
    let hours = ("0" + date_ob.getHours()).toString().toString().slice(-2);
    let minutes = ("0" + date_ob.getMinutes()).toString().slice(-2);
    let seconds = ("0" + date_ob.getSeconds()).toString().slice(-2);

    return `${year}.${month}.${date}-${hours}:${minutes}:${seconds}`
}


function Interval(interval) {
    let lastChar = interval.substr(interval.length - 1);
    let time = interval.slice(0, -1);
    let mm;

    let regex = new RegExp('^[0-9]+$')
    if (!regex.test(time)){
        console.log(styleText('red', "Invalid INTERVAL"))
        exit(1)
    }

    if(lastChar == "s") { 
        mm = time*1000
    } 
    else if(lastChar == "m") { 
        mm = time*60000
    }
    else if(lastChar == "h") { 
        mm = time*3600000
    }
    else if(lastChar == "d") { 
        mm = time*86400000
    }
    else if(lastChar == "w") { 
        mm = time*604800000
    }
    else { 
        console.log(styleText('red', "Invalid INTERVAL"))
        exit(1)
    }
    return mm
}

function CheckVariables (){
    if (!process.env.BW_CLIENTID){
        console.log(styleText('red', "BW_CLIENTID not set"))
        exit(1)
    }

    if (!process.env.BW_CLIENTSECRET){
        console.log(styleText('red', "BW_CLIENTSECRET not set"))
        exit(1)
    }

    if (!process.env.BW_PASSWORD){
        console.log(styleText('red', "BW_PASSWORD not set"))
        exit(1)
    }

    if ((!process.env.ENCRYPTION_KEY) && (process.env.BACKUP_FORMAT == "encrypted_json")){
        console.log(styleText('red', "ENCRYPTION_KEY not set"))
        exit(1)
    }

    if (
        process.env.BACKUP_FORMAT !== 'encrypted_json' &&
        process.env.BACKUP_FORMAT !== 'json' &&
        process.env.BACKUP_FORMAT !== 'csv'
        ) {
            console.log(styleText('red', "Invalid BACKUP_FORMAT"))
            exit(1)
    }

    let regex = new RegExp('^[0-9]+$')
    if (!regex.test(process.env.KEEP_LAST)){
        console.log(styleText('red', "Invalid KEEP_LAST"))
        exit(1)
    }

}

function RemoveOldBackups(include){

    if (process.env.KEEP_LAST == 0){
        return console.log(styleText('white', "KEEP_LAST=0, keeping all backups"))
    }

    let dirContents = fs.readdirSync('/data/');
    let files_list = dirContents.filter((dirContents) => dirContents.match(`${include}`));

    if (files_list.length >= process.env.KEEP_LAST){
        for (let i = 0; i < (files_list.length - process.env.KEEP_LAST); i++) {
            fs.unlinkSync(`/data/${files_list[i]}`);
            console.log(styleText('redBright', `Delete old backup: ${files_list[i]}`))
          }
    } else {
        console.log(styleText('white', "No delete old backup, number of backups less than KEEP_LAST"))

    }
}

function SetURLServer(){
    let BW_SERVER = process.env.BW_SERVER_BASE

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
    var date = DateTimeNow()

    let check_status = bw("status")

    if ((process.env.BW_SERVER_BASE) && (check_status.search(`${process.env.BW_SERVER_BASE}`) < 0)) {
        SetURLServer()
    }
    
    //login
    if(check_status.search(`${process.env.BW_CLIENTID.slice(5)}`) < 0){
        bw("login --apikey")
    }

    //get session
    let BW_SESSION = bw(`unlock ${process.env.BW_PASSWORD} --raw`)


    //backup
    if (process.env.BACKUP_ORGANIZATION_ONLY == true) {
        console.log(styleText('white', "BACKUP_ORGANIZATION_ONLY is True, skip individual vault backup..."));
    } else {
        let FILENAME = `${date}_bitwarden-backup.${process.env.BACKUP_FORMAT.replace("encrypted_","")}`
        
         if(process.env.BACKUP_FORMAT == "encrypted_json"){
            var backup = bw(`--raw --session ${BW_SESSION} export --format encrypted_json --password ${process.env.ENCRYPTION_KEY}`) 
         } else {
            var backup = bw(`--raw --session ${BW_SESSION} export --format ${process.env.BACKUP_FORMAT}`) 
         }
        
        
        fs.writeFile("/data/" + FILENAME, backup, (err) => {
            if (err) throw err;
        })
        console.log(styleText('green', `Backup individual vault done: ${FILENAME}`));
        RemoveOldBackups("bitwarden-backup")
    }

    //backup organizations
    if(process.env.ORGANIZATION_IDS) {
        let ORGANIZATIONS = process.env.ORGANIZATION_IDS.split(',')

        ORGANIZATIONS.forEach(element => {
            let FILENAME = `${date}_ORG_${element}.${process.env.BACKUP_FORMAT.replace("encrypted_","")}`
            
            if(process.env.BACKUP_FORMAT == "encrypted_json"){
                var backup = bw(`--raw --session ${BW_SESSION} export --organizationid ${element} --format encrypted_json --password ${process.env.ENCRYPTION_KEY}`) 
            }else {
                var backup = bw(`--raw --session ${BW_SESSION} export --organizationid ${element} --format ${process.env.BACKUP_FORMAT}`) 
            }
            
            fs.writeFile(`/data/${FILENAME}`, backup, (err) => {
                if (err) throw err;
            })
            console.log(styleText('green', `Backup organization vault done: ${FILENAME}`));
            RemoveOldBackups(`ORG_${element}`)
        })
    } else {
        console.log(styleText('white', "No set ORGANIZATION_IDS, skip organization vault backup..."));
    }
}


while(true){
    CheckVariables()
    Backup()
    console.log(styleText('white', `Next execution ${process.env.INTERVAL}`));
    const delay = ms => new Promise(resolve => setTimeout(resolve, ms))
    await delay(Interval(process.env.INTERVAL))
}
