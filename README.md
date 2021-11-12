# Only My Steam Group
A plugin that basically only allows a certain groups to join your server.

## Installation
1. Install the [Steamworks extension](https://github.com/hexa-core-eu/SteamWorks/releases)
2. Put `onlymysteamgroup.smx` in the `sourcemods/plugins` folder
3. Load the plugin

## ConVars
This plugin automatically generate a file called `onlymysteamgroup.cfg` in the `cfg/sourcemods` folder,
you can configure the variable inside this and reload it.

### sm_onlymysteamgroup_groupids (default "")
List of group ids separated by a comma. Spaces between the value and the comma are trimmed off so feel free to use them for better visibility.

The expected input is the result of `groupID64 % (1 << 32)`
You can get a group's groupID64 by visiting
`https://steamcommunity.com/groups/ADDYOURGROUPSNAMEHERE/memberslistxml/?xml=1`
To convert the groupID64 you can use the python console.

### sm_onlymysteamgroup_reason (default: "You must join a certain Steam Group to join this server!")
Kick reason to be displayed to the client.

## Acknowledgements
This plugin takes inspiration heavily from [SteamGroupRestrict](https://github.com/Impact123/SteamGroupRestrict)
