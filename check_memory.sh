#!/bin/bash

minecraft_admins=( kpkody RoughKnight )

function trackValue {
	curl -s -d "stat=$1&ezkey=kodypeterson91@gmail.com&value=$2" http://api.stathat.com/ez > /dev/null
}

function runCommand {
	screen -S minecraftsvr -p 0 -X stuff "$1 `echo -ne '\015'`"
}

function tellAdmins {
	for i in "${minecraft_admins[@]}"
	do
		runCommand "tell $i $1"
	done
}

function tellServer {
	runCommand "say $1"
}

function tell {
	runCommand "tell $1 $2"
}

function fancyTell {
	runCommand "title $1 title {\"text\":\"$2\", \"bold\":true}"
	if [ ! -z "$3" ]; then
		runCommand "title $1 subtitle {\"text\":\"$3\", \"color\":\"gray\", \"italic\":true}"
	fi
}

function fancyTellServer {
	fancyTell "@a" $1 $2
}

mem=$(free -m | awk '/Mem:/{print $4}')

#tellAdmins "Memory at $mem"

if [ $mem -lt 21 ]; then
    tellAdmins "Memory at $mem - Below 21 - 2nd Time - Restarting"
    last_mem=9999
    fancyTellServer "Server Restarting" "You have 60 seconds..."
    sleep 60
    fancyTellServer "Restarting Now!"
    sleep 5
    runCommand "stop"
    sleep 15
    /srv/mc_scripts/start.sh
fi

if ! screen -list | grep -q "minecraftsvr"; then
	/srv/mc_scripts/start.sh
fi

trackValue "freeMemory" $mem
