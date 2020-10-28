
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
For this command we are using to add an entry to the login keychain.

```bash
security add-generic-password [-s service] [-a account] [-w password]

Usage: 
-s service      Specify service name (required)
-a account      Specify account name (required)
-w password     Specify password to be added. Put at end of command to be prompted (recommended)
```

**Example:**
```bash
security add-generic-password -s hueAPIHash -a HUEAPI -w FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV
```

Now we securely store the Hue API Hash into the macOS Keychain. 
we can use this command to fetch the Hue API Hash.

```bash
security find-generic-password [-s service] -w 
Usage:
-s service      Match service string
-w              Display the password(only) for the item found
```

**Example:**
```bash
security find-generic-password -s "hueAPIHash" -w
#RESULT
FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV
```

See the man page security in terminal for more options.


we have all the Global variables we need to fill in in the script

```bash
# Global variables
hueBridge='10.0.1.111'
hueApiHash=$(security find-generic-password -s "hueAPIHash" -w) 
hueBaseUrl="http://${hueBridge}/api/${hueApiHash}"
hueLight="1"
```

## Scan for running meetings

