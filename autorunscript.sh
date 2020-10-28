#!/bin/bash

# Add hueAPIHash in macOS Keychain
# security add-generic-password -s hueAPIHash -U -w #######################

# Global variables
hueBridge='10.0.1.111'
hueApiHash=$(security find-generic-password -s "hueAPIHash" -w) 
hueBaseUrl="http://${hueBridge}/api/${hueApiHash}"
hueLight="1" ##ID 1, 2, 3
localIP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

# Running Meetings
zoomMeeting=$(lsof -anP -i4 -sTCP:LISTEN | grep zoom.us)
microsoftTeams=$(lsof -anP -i4 -sTCP:LISTEN | grep Microsoft | grep ${localIP}:'*')
ciscoWebEX=$(lsof -anP -i4 -sTCP:LISTEN | grep Meeting)
slack=$(lsof -anP -i4 -sTCP:LISTEN | grep 'Slack*')
faceTime=$(lsof -anP -i4 -sTCP:LISTEN | grep avconfere)

# API Functions
function turnOff {
	# Turn Off
	curl -s -X PUT -H "Content-Type: application/json" -d '{"on":false}' "${hueBaseUrl}/lights/${hueLight}/state"
}

function TurnOnRed {
	# Turn on with color Red
	curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'254',"xy":['0.6984','0.2983']}' "${hueBaseUrl}/lights/${hueLight}/state"
}

function TurnOnGreen {
	# Turn on with color Green
	curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'254',"xy":['0.2151','0.7106']}' "${hueBaseUrl}/lights/${hueLight}/state"
}

#########################################################################################
#########################################################################################
# Core Script Logic
#########################################################################################
#########################################################################################

if [[ -n "$zoomMeeting" || -n "$microsoftTeams" || -n "$ciscoWebEX"  || -n "$slack" || -n "$faceTime" ]];then
	echo "Meeting running"
	TurnOnRed
	else
	echo "There is no meeting running"
#	turnOff
	TurnOnGreen
fi

sleep 10
