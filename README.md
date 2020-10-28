
# onAirScanner
<img src="https://github.com/mvdbent/onAirScanner/blob/main/OnAir.png" width="250">

![GitHub Releases](https://img.shields.io/github/downloads/mvdbent/onAirScanner/latest/total?color=blue&style=flat-square)
![GitHub](https://img.shields.io/github/license/mvdbent/onAirScanner?color=red&style=flat-square)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/mvdbent/onAirScanner?style=flat-square)

_This script is in the "It's working for me, but want to make it better" stage._

While WFH, we are in a lot of meetings, and sometimes your roommates or family doens't know this and just walk into your room, because they forget to knock on the door or just walk into your room.
So setting up a light to show them that you are busy, in a meeting is a great sollution.
There are several solution out there that can do this. for example: Connect your agenda to IFTTT kind of services, create an action with homekit or homebridge to  turn light on with color red when you are in a meeting, and green when you're avalable.
Or just buy a button that turns the light on or off. (and try not to forget to push the button, and i always forget)

In my case i couldn't connect my agenda to services like IFTTT, our send an webhook event from my meeting application, when a meeting has started or ended.
And i'm using multiple meeting applications for online meetings with customers.

Had an discusion with my manager and collegeas, and we came to a result, would it be nice that we have a script that search on your device for an active online meeting (Zoom, WebEx, Microsoft Teams & Slack to start with), and control HueLights via API base on my result.

## Set up
All we need for this setup is an Hue Bridge and a Hue Light.
An Browser, text editor and Apple Automator.app

**Create a API user in Bridge** [link to source](https://developers.meethue.com/develop/get-started-2/)

First we are going to search for the Hue Bridge in your network
for the lookup in your network op this link in your browser https://discovery.meethue.com/

**Result example:**
```html
[{"id":"001234ddse27c6be","internalipaddress":"10.0.1.111"}]
```

Use the internal API Debugger to create an API User, go to https://10.0.1.111/debug/clip.html
Change #internalipaddress into the internalipaddress you just found.

We the following command in the API Debugger tool, we are generating a API user . 
Fill in the info like below (you can use your own name) in the API Debugger and press the POST button.

```html
URL: /api
Message Body:
{"devicetype":"my_hue_app#username"}
```

When you press the POST button you should get back an error message letting you know that you have to press the link button

**Result example:**
```html
[
	{
		"error": {
			"type": 101,
			"address": "/",
			"description": "link button not pressed"
		}
	}
]
``` 
Now press the button on the bridge and then press the POST button again and you should get a success response like below.

**Result example:**
```html
[
	{
		"success": {
			"username": "FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV"
		}
	}
]
```

We enabled a API user where we can authenticate with the Hue Bridge for communication.
Please write down the Hue API Hash.

We can test doing the following

```html
URL: https://10.0.1.111/api/FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV
Message Body:
```

When you press the GET button you should get back a list of devices that are connected to the bridge

**Result example:**
```html
{
	"lights": {
		"1": {
			"state": {
				"on": true,
				"bri": 254,
				"hue": 25600,
				"sat": 254,
				"effect": "none",
				"xy": [
					0.2151,
					0.7106
				],
				"alert": "lselect",
				"colormode": "xy",
				"mode": "homeautomation",
				"reachable": true
			},
			"swupdate": {
				"state": "noupdates",
				"lastinstall": "2018-12-12T19:06:42"
			},
			"type": "Color light",
			"name": "Hue bloom 1",
			"modelid": "LLC011",
			"manufacturername": "Signify Netherlands B.V.",
			"productname": "Hue bloom",
			"capabilities": {
				"certified": true,
				"control": {
					"mindimlevel": 10000,
					"maxlumen": 120,
					"colorgamuttype": "A",
					"colorgamut": [
						[
							0.704,
							0.296
						],
						[
							0.2151,
							0.7106
						],
						[
							0.138,
							0.08
						]
					]
				},
				"streaming": {
					"renderer": true,
					"proxy": false
				}
			},
			"config": {
				"archetype": "huebloom",
				"function": "decorative",
				"direction": "upwards",
				"startup": {
					"mode": "safety",
					"configured": true
				}
			},
			"uniqueid": "00:11:22:01:00:1c:4e:ec-0b",
			"swversion": "5.127.1.26581"
		},
	}
}
```

For testing we are going to use light ID "1"

## Securely store Passwords into the macOS Keychain

Why putting Passwords in cleartext in scripts, when we can use the macOS Keychain for securely store this for us.
I added this to the script for (easy) adding a password into the macOS keychain, so that we can place a password into the shell environment without leaking it into a file.

**How to**

After creating the API user with the API Debugger tool, we received the Hue API Hash. 
We are going to add the Hue API Hash into the macOS Keychain with the security command.
For this command we are using to add an entry to the login keychain and add the security binary to "Always allow access by these applications:" list in the Access Control preferences.

```bash
security add-generic-password [-s service] [-a account] [-w password] -T [appPath]

Usage: 
-s service      Specify service name (required)
-a account      Specify account name (required)
-w password     Specify password to be added. Put at end of command to be prompted (recommended)
-T appPath      Specify an application which may access this item (multiple -T options are allowed)
```

**Example:**
```bash
security add-generic-password -s hueAPIHash -a HUEAPI -w FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV -T /usr/bin/security
```

Now we securely store the Hue API Hash into the macOS Keychain, and allowing the security binary to access this entry. 
We can use the security command to fetch the Hue API Hash.

```bash
security find-generic-password [-s service] -w 
Usage:
-s service      Match service string
-w              Display the password(only) for the item found
```

We only need to provide the service name and ask for the password

**Example:**
```bash
security find-generic-password -s "hueAPIHash" -w
#RESULT
FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV
```

See the man page security in terminal for more options.


we have all the info we need to fill in the Global variables in the script

```bash
# Global variables
hueBridge='10.0.1.111' #use your internal ipaddress
hueApiHash=$(security find-generic-password -s "hueAPIHash" -w) #use your service name by [-s "hueAPIHash"]
hueLight="1" #use your light ID that you wanna use
```

## Scan for running meetings
The challenge here is "How do we know when we are in a meeting, (even when we have turned off the Camera and/or microfone)
We could look for running process, but this doesn't mean you are in a meeting.
The only thing that is always the case, is a open connection.

Running lsof (List open files) command without any options will list all open files of your system that belongs to all active process.
This process takes a while and you will get a full list, we don't need all this information. 
We are going to narrow this down to internet related connections by adding -i to the command.

**Example**
```bash
lsof -i | grep zoom
zoom.us   53231 mischa   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->ec2-3-235-72-248.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mischa   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->ec2-52-202-62-196.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mischa   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->ec2-3-235-96-204.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mischa   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
```

We add the `<-a>`-a option may be used to AND the selections, the `<-n>`-n to inhibits the conversion of network numbers to host names for network files and the `<-P>`-P inhibits the conversion of port numbers to port names for network files
Inhibiting conversion may make lsof run faster.

**Example**
```bash
lsof -anP -i | grep zoom
zoom.us   53231 mischa   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->3.235.72.248:https (ESTABLISHED)
zoom.us   53231 mischa   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->52.202.62.196:https (ESTABLISHED)
zoom.us   53231 mischa   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->3.235.96.204:https (ESTABLISHED)
zoom.us   53231 mischa   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
```

Now we found the active process that have a internet related connection, this still doesn't mean that we are in a meeting.
This means that the Zoom.us app is opend and logged in with your account.

**Example**
```bash
lsof -anP -i | grep zoom
zoom.us   53231 mischa   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->3.235.72.248:https (ESTABLISHED)
zoom.us   53231 mischa   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->52.202.62.196:https (ESTABLISHED)
zoom.us   53231 mischa   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->3.235.96.204:https (ESTABLISHED)
zoom.us   53231 mischa   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
zoom.us   53231 mischa   60u  IPv4 0x64763030846e819d      0t0  UDP 10.0.1.116:63026
zoom.us   53231 mischa   61u  IPv4 0x64763030846e8d3d      0t0  UDP 10.0.1.116:58615
zoom.us   53231 mischa   65u  IPv4 0x64763030846e98dd      0t0  UDP *:53327
zoom.us   53231 mischa   67u  IPv4 0x6476303084763a55      0t0  UDP *:55248
zoom.us   53231 mischa   68u  IPv4 0x647630307bd37d3d      0t0  UDP *:53574
```

After starting a meeting in zoom, we got extra connections based on UDP added.
So i did a couple of test, ended the meeting, UDP connections where gone, started a new meeting, UDP connections are back turned. 
Turned of my Camera and Microphone, and the UDP connections where still there.
No we now where to look for when it comes to Zoom.us. We only need to list the network files with TCP state LISTEN, with the -sTCP:LISTEN option

Optional: 	We can specifies the IP version, IPv4 or IPv6 by adding '4' or '6'. 
			In the script we specify IPv4.

Fun fact is that 
**Example**
```bash
lsof -anP -i4 -sTCP:LISTEN | grep zoom
zoom.us   53231 mischa   60u  IPv4 0x64763030846e819d      0t0  UDP 10.0.1.116:63026
zoom.us   53231 mischa   61u  IPv4 0x64763030846e8d3d      0t0  UDP 10.0.1.116:58615
zoom.us   53231 mischa   65u  IPv4 0x64763030846e98dd      0t0  UDP *:53327
zoom.us   53231 mischa   67u  IPv4 0x6476303084763a55      0t0  UDP *:55248
zoom.us   53231 mischa   68u  IPv4 0x647630307bd37d3d      0t0  UDP *:53574

Usage:
		-a		causes list selection options to be ANDed, as described above.
		
		-n		inhibits the conversion of network numbers to host  names  for
				network  files.   Inhibiting  conversion  may  make  lsof  run
				faster.  It is also useful when host name lookup is not  working properly.
				
		-P		inhibits the conversion of port numbers to port names for network files.
				Inhibiting  the  conversion may make lsof run a little faster. 
				It is also useful when port name lookup is not working properly.

		-i 		selects  the  listing  of  files any of whose Internet address 
				matches the address specified in i.  If no address  is  specified, 
				this option selects the listing of all Internet and x.25
				(HP-UX) network files
				
		46 		specifies the IP version, IPv4 or IPv6 that applies to the following address.
				'6' may be be specified only if the UNIX dialect supports IPv6.
				If neither '4' nor '6' is specified, the following address applies to all IP versions.
				
		sTCP	To list only network files with TCP state LISTEN, use: -sTCP:LISTEN
```		
				
## Create an Automator app that loops this script.

no we have a script that scan's for running meetings, calls, we want to loop this.


