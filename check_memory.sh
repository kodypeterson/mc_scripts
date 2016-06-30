#!/bin/bash

minecraft_admins=( kpkody RoughKnight )
players_online=( )

function clearLog {
	echo "" > /home/dhc-user/minecraft/server.out
}

clearLog

function trackValue {
	curl -s -d "stat=$1&ezkey=kodypeterson91@gmail.com&value=$2" http://api.stathat.com/ez > /dev/null
}

function runCommand {
	clearLog
	screen -S minecraftsvr -p 0 -X stuff "$1 `echo -ne '\015'`"
	sleep 1
	local command_output=`cat /home/dhc-user/minecraft/server.out | sed "1 d"`
	if [[ $command_output == *"CONSOLE"* ]]; then
		command_output=`echo "$command_output" | sed "1 d"`
	fi
	command_output=`echo "$command_output" | rev | cut -d: -f1 | rev`
	echo "$command_output"
	clearLog
}

function onlinePlayerCount {
	local resp=$(runCommand "list")
	echo "$resp"
	local count=`echo "$resp" | cut -d " " -f4`
	echo "$count"
}

function updateOnlinePlayerArray {
	local list=$(runCommand "list")
	local resp=`echo "$list" | sed "1 d" | tr '\r\n' ' '`
	IFS=', ' read -r -a players_online <<< "$resp"
	local count=0
	for player in "${players_online}"
	do
		if [[ $player == *"[AFK]"* ]]; then
			players_online[$count]="kpkody"
		fi
		count=$(($count+1))
	done
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

function waitForAllGrounded {
	if [ "${#players_online[@]}" -eq 0 ]; then
		updateOnlinePlayerArray
		if [ "${#players_online[@]}" -gt 0 ]; then
			local notify_count=$(notifyNeedToGround)
		fi
	else
		local notify_count=$(notifyNeedToGround)
	fi

	if [ ! -z "$notify_count" && "$notify_count" -gt 0 ]; then
		tellAdmins "Waiting for $notify_count people to stop flying"
		sleep 5
		waitForAllGrounded
	fi
}

function notifyNeedToGround {
	local count=0
	for player in "${players_online[@]}"
	do
		local cmd=$(runCommand "testfor $player {OnGround:1b}")
		if [[ $cmd == *"did not match"* ]]; then
			fancyTell "$player" "STOP FLYING" "You need to land so the server can restart"
			count=$((counter+1))
		fi
	done
	echo "$count"
}

if [ ! -f /home/dhc-user/minecraft/last_mem.txt ]; then
	#last_mem is no set - define default
	last_mem=9999
else
	last_mem=`cat /home/dhc-user/minecraft/last_mem.txt`
fi

mem=$(free -m | awk '/Mem:/{print $4}')

#tellAdmins "Memory at $mem"

#if [ $last_mem -lt 31 ]; then
	if [ $mem -lt 21 ]; then
		tellAdmins "Memory at $mem - Below 21 - 2nd Time - Restarting"
		last_mem=9999
		fancyTellServer "Server Restarting" "You have 60 seconds..."
		sleep 60s
		waitForAllGrounded
		fancyTellServer "Restarting Now!"
		runCommand "stop"
		sleep 15
		/home/dhc-user/minecraft/start.sh
	#else
	#	tellAdmins "Memory Recovered"
	fi
#else
#	if [ $mem -lt 31 ]; then
#		tellAdmins "Memory at $mem - Below 31 - 1st Time - Check Again 1 Min"
#	fi
#	last_mem=$mem
#fi

if ! screen -list | grep -q "minecraftsvr"; then
#	/home/dhc-user/minecraft/start.sh
fi

#trackValue "playerCount" $(onlinePlayerCount)
trackValue "freeMemory" $mem

echo "$last_mem" > /home/dhc-user/minecraft/last_mem.txt
