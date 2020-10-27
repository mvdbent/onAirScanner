
# onAirScanner
<img src="https://github.com/mvdbent/onAirScanner/blob/main/OnAir.png" width="250">

_This script is in the "It's working for me, but want to make it better" stage._

While WFH, we are in a lot of meetings, and sometimes your roommates or family doens't know this and just walk into your room, because they forget to knock on the door or just walk into your room.
So setting up a light to show them that you are busy, in a meeting is a great sollution.
There are several solution out there that can do this. for example: Connect your agenda to IFTTT kind of services, create an action with homekit or homebridge to  turn light on with color red when you are in a meeting, and green when you're avalable.
Or just buy a button that turns the light on or off. (and try not to forget to push the button, and i always forget)

In my case i couldn't connect my agenda to services like IFTTT, our send an webhook event from my meeting application, when a meeting has started or ended.
And i'm using multiple meeting applications for online meetings with customers.

Had an discusion with my manager and collegeas, and we came to a result, would it be nice that we have a script that search on your device for an active online meeting (Zoom, WebEx, Microsoft Teams & Slack to start with), and control HueLights via API base on my result.

## Set it up
All you need is an Hue Bridge and a Hue Light.

## Create a API user in Bridge 
_(source https://developers.meethue.com/develop/get-started-2/)_

first we are going to search for the Hue Bridge in your network
First lookup in your network your Hue Bridge
https://discovery.meethue.com/
 Result example: [{"id":"001234ddse28c6be","internalipaddress":"10.0.0.12"}]
 
 Use the internal API Debugger to create an API User
 Go to https://internal-ipaddress/debug/clip.html

 We need to use the randomly generated username that the bridge creates for you. 
 Fill in the info like below (you can use your own name) in the API Debugger and press the POST button.

 URL: /api
 Message Body:
 {"devicetype":"my_hue_app#Mischa"}
 
 When you press the POST button you should get back an error message letting you know that you have to press the link button

 [
	{
		"error": {
			"type": 101,
			"address": "/",
			"description": "link button not pressed"
		}
	}
]
 
 Now press the button on the bridge and then press the POST button again and you should get a success response like below.

[
	{
		"success": {
			"username": "FIAqb-45tKaLBVzXKscihomProgvhUkRko59TAuV"
		}
	}
]

 Now we enabled a API user where we can authenticate with the Hue Bridge to communicate

 We can test doing the following

 URL: https://10.0.1.111/api/FIAqb-45tKaLBVzXKscihomProgvhUkRko59TAuV

 When you press the POST button you should get back a list of devices that are connected to the bridge

 in this script i'm testing on 1 light in my case ID "1"

