#!/bin/bash

# Global variables
hueBridge='ipaddress'
hueApiHash='###############' 
hueBaseUrl="http://${hueBridge}/api/${hueApiHash}"
hueLight="##" ##ID 1, 2, 3

# Basic API examples

# Turn On 
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn Off
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":false}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn On 100 procent brightness
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'254'}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn On 50 procent brightness
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'127'}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn on with color Green 20% brightness
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'50',"xy":['0.2151','0.7106']}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn on with color Red 100% brightness
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'254',"xy":['0.6984','0.2983']}' "${hueBaseUrl}/lights/${hueLight}/state"

# Turn on with color Green 100% brightness
curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true,"bri":'254',"xy":['0.2151','0.7106']}' "${hueBaseUrl}/lights/${hueLight}/state"
