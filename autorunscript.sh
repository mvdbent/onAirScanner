#!/bin/zsh

# Add hueAPIHash in your macOS Keychain, and add the security binary to "Always allow access by these applications:" list in this entry
# security add-generic-password -s hueAPIHash -U -w ###################### -T /usr/bin/security

# Global variables
# Scan your network for your hueBridge ipaddress
hueBridge=$(curl --silent --fail "https://discovery.meethue.com/" | awk -F '"' "{ print \$8 }")
hueApiHash=$(security find-generic-password -s "hueAPIHash" -w) #use your service name by [-s "hueAPIHash"]
hueBaseUrl="http://${hueBridge}/api/${hueApiHash}"
hueLight="1" #use your light ID that you wanna use
localIP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -1)


# Running Meetings
zoomMeeting=$(lsof -anP -i4 -sTCP:LISTEN | grep zoom.us | grep ${localIP}:'*')
microsoftTeams=$(lsof -anP -i4 -sTCP:LISTEN | grep Microsoft | grep ${localIP}:'*')
ciscoWebEX=$(lsof -anP -i4 -sTCP:LISTEN | grep Meeting)
slack=$(lsof -anP -i4 -sTCP:LISTEN | grep 'Slack*' | grep 'UDP \*')
faceTime=$(lsof -anP -i4 -sTCP:LISTEN | grep avconfere | grep ${localIP}:'*')
discordMeeting=$(lsof -anP -i4 -sTCP:LISTEN | grep Discord | grep 'UDP \*')

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

if [[ -n "$zoomMeeting" || -n "$microsoftTeams" || -n "$ciscoWebEX"  || -n "$slack" || -n "$faceTime" || -n "$discordMeeting"]];then
	echo "Meeting running"
	TurnOnRed
	else
	echo "There is no meeting running"
#	turnOff
	TurnOnGreen
fi

sleep 10
