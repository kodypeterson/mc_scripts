#!/bin/bash
clear
echo -e "Starting Minecraft.."
sleep 5
cd /srv/minecraft/

screen -A -m -d -S minecraftsvr bash -c "java -Xms6G -Xmx6G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AggressiveOpts -Dcom.mojang.eula.agree=true -jar /srv/minecraft/spigot-1.10.2.jar"
