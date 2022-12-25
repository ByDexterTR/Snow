#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

int iSnowFlakes[4];
Cookie SnowCookie = null;
bool bDisabled[65] = { false, ... };

#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1))

public Plugin myinfo = 
{
	name = "Kar Yağdırma", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_snowfall", cmdSnowFall);
	RegConsoleCmd("sm_snow", cmdSnowFall);
	RegConsoleCmd("sm_kar", cmdSnowFall);
	SnowCookie = new Cookie("ex-karyagisi", "", CookieAccess_Protected);
	LoopClients(i)
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnMapStart()
{
	ServerCommand("sv_holiday_mode 2");
	char buffer[64];
	for (int i = 0; i < 4; i++)
	{
		Format(buffer, 64, "materials/snowflake%i.vtf", i + 1);
		AddFileToDownloadsTable(buffer);
		Format(buffer, 64, "materials/snowflake%i.vmt", i + 1);
		AddFileToDownloadsTable(buffer);
		iSnowFlakes[i] = PrecacheModel(buffer);
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_WeaponDrop, OnClientWeaponDrop);
	char buffer[2];
	SnowCookie.Get(client, buffer, 2);
	bDisabled[client] = view_as<bool>(StringToInt(buffer));
}

public Action OnClientWeaponDrop(int client, int weapon)
{
	if (IsValidEntity(weapon))
	{
		char weaponname[64];
		GetEntityClassname(weapon, weaponname, 64);
		if (strcmp(weaponname, "weapon_snowball") == 0)
		{
			RemoveEntity(weapon);
		}
	}
}

public Action cmdSnowFall(int client, int args)
{
	if (IsClientInGame(client))
	{
		bDisabled[client] = !bDisabled[client];
		PrintToChat(client, "[SM] Kar yağışı: %s", bDisabled[client] ? "\x07kapandı" : "\x06açıldı");
		SnowCookie.Set(client, bDisabled[client] ? "1" : "0");
	}
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (IsClientInGame(client) && !IsFakeClient(client) && !bDisabled[client])
	{
		float pos[3], vel[3], rand[2];
		GetClientAbsOrigin(client, pos);
		
		pos[2] += 350.0;
		pos[0] += 1000.0;
		pos[1] += 1000.0;
		
		rand[0] = GetRandomFloat(0.0, 2000.0);
		rand[1] = GetRandomFloat(0.0, 2000.0);
		pos[0] = (pos[0] - 2000) + rand[0];
		pos[1] = (pos[1] - 2000) + rand[1];
		vel[0] = GetRandomFloat(-50.0, 50.0);
		vel[1] = GetRandomFloat(-50.0, 50.0);
		vel[2] = GetRandomFloat(-50.0, -100.0);
		
		TE_Start("Client Projectile");
		
		TE_WriteVector("m_vecOrigin", pos);
		TE_WriteVector("m_vecVelocity", vel);
		TE_WriteNum("m_nModelIndex", iSnowFlakes[GetRandomInt(0, 3)]);
		TE_WriteNum("m_hOwner", 0);
		TE_WriteNum("m_nLifeTime", 7);
		
		TE_SendToClient(client);
	}
}
