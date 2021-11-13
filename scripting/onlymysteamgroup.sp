#define PLUGIN_VERSION "0.1.1"

#pragma semicolon 1

#include <sourcemod>

#include "include/SteamWorks"

public Plugin myinfo = 
{
    name = "OnlyMySteamGroup",
    author = "NoAiOne",
    description = "Restrict your server for your steam group only.",
    version = PLUGIN_VERSION,
    url = "https://n4o.xyz/"
}

ConVar g_hGroupIds;
ConVar g_hKickReason;

int g_iGroupIds[100];
int g_iNumGroups;
char g_sKickReason[256];

public void OnPluginStart()
{
	g_hGroupIds = CreateConVar(
		"onlymysteamgroup_groupids",
		"",
		"List of group ids separated by a comma. Use (groupId64 % 4294967296) to convert to expected input",
		FCVAR_NOTIFY
	);
	g_hKickReason = CreateConVar(
		"onlymysteamgroup_reason",
		"You must join a certain Steam Group to join this server!",
		"Kick reason displayed to client",
		FCVAR_NOTIFY
	);
	CreateConVar("onlymysteamgroup_version", PLUGIN_VERSION, "Only My Steam Group plugin verison.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true, "onlymysteamgroup");

	g_hGroupIds.AddChangeHook(OnCvarChanged);
	g_hKickReason.AddChangeHook(OnCvarChanged);
}

public void OnCvarChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
    if (cvar == g_hGroupIds)
    {
        OnConfigsExecuted();
    }
    else if (cvar == g_hKickReason)
    {
        g_hKickReason.GetString(g_sKickReason, sizeof(g_sKickReason));
    }
}

public void OnConfigsExecuted()
{
	g_hKickReason.GetString(g_sKickReason, sizeof(g_sKickReason));
	RefreshGroupIds();
	CheckAll();
}

void CheckAll()
{
	for (int i=1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			int accountId = GetSteamAccountID(i);
			SteamWorks_OnValidateClient(accountId, accountId);
		}
	}
}

void RefreshGroupIds()
{
	char sGroupIds[1024];
	g_hGroupIds.GetString(sGroupIds, sizeof(sGroupIds));

	char sGroupBuf[sizeof(g_iGroupIds)][12];
	int count = 0;
	int explodes = ExplodeString(sGroupIds, ",",  sGroupBuf, sizeof(sGroupBuf), sizeof(sGroupBuf[]));

	for (int i=0; i <= explodes; i++)
	{
		TrimString(sGroupBuf[i]);

		if (explodes >= sizeof(g_iGroupIds))
		{
			SetFailState("Group Limit of %d reached", sizeof(g_iGroupIds));
			break;
		}
		
		int tmp = StringToInt(sGroupBuf[i]);
		
		if (tmp > 0)
		{
			g_iGroupIds[count] = tmp;
			count++;
		}
	}

	g_iNumGroups = count;
}

public int SteamWorks_OnValidateClient(int ownerauthid, int authid)
{
	for (int i = 0; i < g_iNumGroups; i++)
	{
		SteamWorks_GetUserGroupStatusAuthID(authid, g_iGroupIds[i]);
	}
}


public int SteamWorks_OnClientGroupStatus(int accountId, int groupId, bool isMember, bool isOfficer)
{
	LogMessage("GroupStatus: %d is in %d? %d (Admin? %d)", accountId, groupId, isMember, isOfficer);
	// Check if the client is in the group
	if (!isMember)
	{
		LogMessage("Account %d is not in group %d, trying to fetch client", accountId, groupId);
		int client = GetClientOfAccountId(accountId);
		if (client != -1)
		{
			LogMessage(
				"Account %d is not in group %d (client %d), kicking client",
				accountId, groupId, client
			);
			KickClient(client, g_sKickReason);
			PrintNotifyMessageToAdmins(client);
		}
	}
}

void PrintNotifyMessageToAdmins(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && CheckCommandAccess(i, "onlymysteamgroup_admin", ADMFLAG_BAN)) 
		{
			PrintToChat(i, "\x04[SGR]\x01 %N was kicked because the person is not a member of defined group.", client);
		}
	}	
}

int GetClientOfAccountId(int accountId)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		bool isInGame = IsClientConnected(i);
		int clientAccountId = GetSteamAccountID(i);
		LogMessage("Checking client no %d for account %d (InGame %d)", i, accountId, isInGame, clientAccountId);
		if (isInGame && clientAccountId == accountId)
		{
			return i;
		}
	}
	
	return -1;
}
