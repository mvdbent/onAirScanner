#!/bin/bash

# Global variables
hueBridge='10.0.1.111'
hueApiHash='nCNqHs1PP780pE-UsoYPR-CoPw85knTqvvNmvXB6'
hueBaseUrl="http://${hueBridge}/api/${hueApiHash}"
hueLight="1"
localIP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

zoomMeeting=$(lsof -anP -i4 -sTCP:LISTEN | grep zoom.us)
microsoftTeams=$(lsof -anP -i4 -sTCP:LISTEN | grep Microsoft | grep ${localIP}:'*')
ciscoWebEX=$(lsof -anP -i4 -sTCP:LISTEN | grep Meeting)
slack=$(lsof -anP -i4 -sTCP:LISTEN | grep 'Slack*')

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


if [[ -n "$zoomMeeting" || -n "$microsoftTeams" || -n "$ciscoWebEX"  || -n "$slack" ]];then
	echo "Meeting running"
	TurnOnRed
	else
	echo "There is no meeting running"
#	turnOff
	TurnOnGreen
fi


### Loop through
#for i in "${onlineMeetings[@]}"
#do
#	: 
#	if [ -z "$i" ]; then
#		echo "There is no meeting running"
#		turnOff
#	else 
#		echo "There is an meeting running"
#		TurnOnRed
#	fi
#done

#if [ -n "$zoomMeeting" ];then
#	echo "There is an meeting 1 running"
#	TurnOnRed
#elif [ -n "$microsoftTeams" ];then
#	echo "There is an meeting 2 running"
#	TurnOnRed
#elif [ -n "$ciscoWebEX"];then
#	echo "There is an meeting 3 running"
#	TurnOnRed
#else
#	echo "There is no Zoom meeting running"
#	turnOff
#fi


#if [ -z "$zoomMeeting" ];then
#	echo "There is no Zoom meeting running"
#	turnOff
#	else
#		echo "There is an Zoom meeting running"
#		TurnOnRed
#fi
#
#if [ -z "$microsoftTeams" ];then
#	echo "There is no Teams meeting running"
#	turnOff
#	else
#		echo "There is an Teams meeting running"
#		TurnOnRed
#fi
#
#if [ -z "$ciscoWebEX" ];then
#	echo "There is no Cisco WebEX meeting running"
#	turnOff
#	else
#		echo "There is an Cisco WebEX meeting running"
#		TurnOnRed
#fi
#
#if [ -z "$slack" ];then
#	echo "There is no slack meeting running"
#	turnOff
#	else
#		echo "There is an slack meeting running"
#		TurnOnRed
#fi
