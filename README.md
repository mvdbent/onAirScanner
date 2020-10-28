
# onAirScanner
<img src="https://github.com/mvdbent/onAirScanner/blob/main/OnAir.png" width="250">

![GitHub](https://img.shields.io/github/license/mvdbent/onAirScanner?color=red&style=flat-square)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/mvdbent/onAirScanner?style=flat-square)

_**Current state of this scripts is:** "Working for me, but let's make this better" stage._

While working from home, we all have a lot of meetings, and sometimes a family member or a roommate has no idea that you are in a meeting and they walk into the room without even a knock.
Setting up a light to show when you are "ON AIR" or in a meeting is a great solution.
There are several solutions out on the internet that can do this. Still, a lot of these solutions connect to your calendar via [IFTTT](https://ifttt.com) or [Zapier](https://zapier.com/) and then you need to create an action with homekit or homebridge to turn on a light with the colour red when in a meeting and green when it is safe to enter.
Another straightforward way is to buy a button that turns a light on or off. (The trick is to try not to forget to push the button, I always forget)

In this case, I couldn't connect my work calendar these 3rd party services or send a webhook event from an API, when a meeting has started or ended.

Also, another challenge is that I am using multiple meeting applications (Zoom, WebEx, Microsoft Teams, Slack, etc.), and each application has its way of doing things.

Then when discussing with my manager and colleagues,  I came up with an idea to have a script that monitors your mac for an active online meeting.

(**When the camera and mic are on!! As in full active participation, not just listing in**) 

Once a meeting found, it can then control the HueLights via API.

## Set up

**What i used for this setup:**
- Philips Hue Bridge v2
- Hue Bloom - Model: LLC011
- Web Browser _(Safari, Google Chrome)_
- Text Editor _(BBEdit, Coderunner)_
- macOS Automator.app _(located in /Applications)_

**Create a API user in Bridge** [link to source](https://developers.meethue.com/develop/get-started-2/)

First we need to search for the Hue Bridge on your network. To lookup on your network use the following link: https://discovery.meethue.com/

**Result example:**
```html
[{"id":"001234ddse27c6be","internalipaddress":"10.0.1.111"}]
```

Use the internal API Debugger to create an API User, go to https://10.0.1.111/debug/clip.html
Change #internalipaddress into the internalipaddress you just found.

We the following command in the API Debugger tool, we are generating a API user. 
Fill in the info like below (you can use your own name) in the API Debugger and press the `POST` button.

```html
URL: /api
Message Body:
{"devicetype":"my_hue_app#username"}
```

When you press the `POST` button you should get back an error message letting you know that you have to press the link button

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
Now press the button on the bridge and then press the `POST` button again and you should get a success response like below.

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

We now have enabled an API user and now we can authenticate with the Hue Bridge for communication.
Please write down the Hue API hash that you got.

Now we can test with the following command:

```html
URL: https://10.0.1.111/api/FIAqb-53KaLBVzXKscihomProgvhUkRko59TAuV
Message Body:
```

When you press the `GET` button you should get back a list of devices that are connected to the bridge

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

For testing we are going to use the light with the **ID** `1`

## Securely store Passwords into the macOS Keychain

Why put cleartext passwords in scripts, when we can use the macOS Keychain to securely store this information for us.

I added this easy way to the script, so we can have a placeholder for the password rather then leaking this password within the script.

**How to**

After creating the API user with the API Debugger tool, we received the Hue API Hash. 
We are going to add the Hue API Hash into the macOS Keychain with the `security` command.
For this command we are using `-T` to add an entry to the login keychain and add the `security` binary to "Always allow access by these applications:" list in the Access Control preferences.

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

Now we securely store the Hue API Hash into the macOS Keychain, and allowing the `security` binary to access this entry. 
We can use the `security` command to fetch the Hue API Hash.

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

See the man page security in terminal for more options. `man security`


Now we have all the info we need to fill in the Global variables in the script

```bash
# Global variables
hueBridge='10.0.1.111' #use your internal ipaddress
hueApiHash=$(security find-generic-password -s "hueAPIHash" -w) #use your service name by [-s "hueAPIHash"]
hueLight="1" #use your light ID that you wanna use
```

## Scan for any Running Meetings
### The Challenge

_"How do we know when we are in a meeting"_ (even when we have turned off the Camera and/or mic)

Our options are:
- We could look for running process, but this doesn't mean you are in a meeting.
- Hook our calendar up to a 3rd party service (can't do that)

The only thing that seems to be content and reliable is if there is an open connection.

Running `lsof` (List open files) command without any options will list all open files of your system that belongs to all active process.
This process takes a while and you will get a full list of everything, but we don't need all this information.

We are going to narrow this down to only internet related connections by adding `-i` to the command.

**Example**
```bash
lsof -i | grep zoom
zoom.us   53231 mvdbent   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->ec2-3-235-72-248.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mvdbent   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->ec2-52-202-62-196.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mvdbent   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->ec2-3-235-96-204.compute-1.amazonaws.com:https (ESTABLISHED)
zoom.us   53231 mvdbent   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
```
We now add the following options to the `lsof` command:
- **-a** option ( can be used to ANDed the selections)
- **-n** (inhibits the conversion of network numbers to host names for network files)
- **-P** (inhibits the conversion of port numbers to port names for network files)
We want to inhibit the output so `lsof` can give us results **faster**.

**Example**
```bash
lsof -anP -i | grep zoom
zoom.us   53231 mvdbent   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->3.235.72.248:https (ESTABLISHED)
zoom.us   53231 mvdbent   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->52.202.62.196:https (ESTABLISHED)
zoom.us   53231 mvdbent   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->3.235.96.204:https (ESTABLISHED)
zoom.us   53231 mvdbent   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
```

Now we found the active process that have a internet related connection, this still doesn't mean that we are in a meeting.
This means that the Zoom.us app is opend and logged in with your account.
After starting a meeting in zoom, we got extra connections based on UDP added.

**Example**
```bash
lsof -anP -i | grep zoom
zoom.us   53231 mvdbent   26u  IPv4 0x64763030ad598a1d      0t0  TCP 10.0.1.116:60144->3.235.72.248:https (ESTABLISHED)
zoom.us   53231 mvdbent   48u  IPv4 0x64763030acb3165d      0t0  TCP 10.0.1.116:63973->52.202.62.196:https (ESTABLISHED)
zoom.us   53231 mvdbent   51u  IPv4 0x64763030adc2b03d      0t0  TCP 10.0.1.116:55830->3.235.96.204:https (ESTABLISHED)
zoom.us   53231 mvdbent   56u  IPv4 0x64763030a88c4c7d      0t0  TCP 10.0.1.116:63978->149.137.8.183:https (ESTABLISHED)
zoom.us   53231 mvdbent   60u  IPv4 0x64763030846e819d      0t0  UDP 10.0.1.116:63026
zoom.us   53231 mvdbent   61u  IPv4 0x64763030846e8d3d      0t0  UDP 10.0.1.116:58615
zoom.us   53231 mvdbent   65u  IPv4 0x64763030846e98dd      0t0  UDP *:53327
zoom.us   53231 mvdbent   67u  IPv4 0x6476303084763a55      0t0  UDP *:55248
zoom.us   53231 mvdbent   68u  IPv4 0x647630307bd37d3d      0t0  UDP *:53574
```

So i did a couple of test, ended the meeting, UDP connections where gone, started a new meeting, UDP connections are back turned. 
Turned off my Camera, then turned on, turned off the Microphone, and turned both off, the UDP connections where still there. **Awesome**
No we now where to look for when it comes to Zoom.us. 

We only need to list the network files with TCP state LISTEN, with the `-sTCP:LISTEN` option

Optional: We can specifies the IP version, IPv4 or IPv6 by adding `4` or `6`, in the script we specify IPv4.

**Example**
```bash
lsof -anP -i4 -sTCP:LISTEN | grep zoom
zoom.us   53231 mvdbent   60u  IPv4 0x64763030846e819d      0t0  UDP 10.0.1.116:63026
zoom.us   53231 mvdbent   61u  IPv4 0x64763030846e8d3d      0t0  UDP 10.0.1.116:58615
zoom.us   53231 mvdbent   65u  IPv4 0x64763030846e98dd      0t0  UDP *:53327
zoom.us   53231 mvdbent   67u  IPv4 0x6476303084763a55      0t0  UDP *:55248
zoom.us   53231 mvdbent   68u  IPv4 0x647630307bd37d3d      0t0  UDP *:53574

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

Fun fact is that beside of zoom.us, Microsoft Teams, Cisco WebEx, Slack and FaceTime is also using TCP state LISTEN.
Only Microsoft Teams connected this to your localIP

**Example**
```bash
lsof -anP -i4 -sTCP:LISTEN | grep Microsoft | grep 10.0.1.116:'*'
Microsoft 67439 mvdbent   45u  IPv4 0x647644287bdb076d      0t0  UDP 10.0.1.116:50023
```
This script will look for zoom.us, Microsoft Teams, Cisco WebEx, Slack and FaceTime online sessions.
Want to have

## Create an Automator app that loops this script.

Now we have a script that scan's for running meetings, calls, we want to loop this.
