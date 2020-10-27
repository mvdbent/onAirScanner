# onAirScanner

<img src="https://github.com/mvdbent/onAirScanner/blob/main/OnAir.png" width="250">

_This script is in the "It's working for me, but want to make it better" stage._

#
while WFH, we are in a lot of meetings, and sometimes your roommates or family doens't know this and just walk into your room, because they forget to knock on the door or just walk into your room.
So setting up a light to show them that you are busy, in a meeting is a great sollution.
There are several solution out there that can do this. for example: Connect your agenda to IFTTT kind of services, create an action with homekit or homebridge to  turn light on with color red when you are in a meeting, and green when you're avalable.
Or just buy a button that turns the light on or off.

In my case i couldn't connect my agenda to services like IFTTT, our send an webhook event from my meeting application, when a meeting has started or ended.


Look for an online meeting, and control via API HueLights

# how to
how to create a API user in Bridge (source https://developers.meethue.com/develop/get-started-2/)

 
 First lookup in your net work your Hue Bridge
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

