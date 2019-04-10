#include <sourcemod>
#include <ccsplayer>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_AUTHOR "Jadow"
#define PLUGIN_VERSION "1.0"

#define XG_PREFIX_CHAT " \x0A[\x0Bx\x08G\x0A]\x01 "
#define XG_PREFIX_CHAT_ALERT " \x04[\x0Bx\x08G\x04]\x01 "
#define XG_PREFIX_CHAT_WARN " \x07[\x0Bx\x08G\x07]\x01 "

public Plugin myinfo = {
	name = " [xG] Rats",
	author = PLUGIN_AUTHOR,
	description = "rats rats rats",
	version = PLUGIN_VERSION,
	url = "https://github.com/Jadowo/Rats-"
};

Handle snowballtimerct;
Handle snowballtimert;
Handle playtaunt;
Handle hetimer;
Handle tacttimer;
Handle unfreezect;
Handle respawnhider;
Handle infiniter8;
Handle lasthider;
ConVar autobalance;
ConVar taserrecharge;
ConVar roundtime;
ConVar defuseroundtime;
ConVar hostageroundtime;
ConVar freezetime;
ConVar NormalChance;
ConVar snowballlimit;
ConVar grenadelimit;
int specialday;
int ratday;
bool firstround;
bool forceday;
char dayname[64], display[64];

public void OnPluginStart(){
	RegAdminCmd("sm_forceday", Command_ForceDay, ADMFLAG_CHANGEMAP);
	RegAdminCmd("sm_fd", Command_ForceDay, ADMFLAG_CHANGEMAP);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	NormalChance = CreateConVar("sm_normal_chance", "70", "Percentage out of 100 for normal day");
	AddFileToDownloadsTable("sound/rats/bumpybumpy.mp3");
	AddFileToDownloadsTable("sound/rats/bb2.mp3");
	AddFileToDownloadsTable("sound/rats/bb3.mp3");
	AddFileToDownloadsTable("sound/rats/bb4.mp3");
	AddFileToDownloadsTable("sound/rats/bb5.mp3");
	AddFileToDownloadsTable("sound/rats/bb6.mp3");
	AddFileToDownloadsTable("sound/rats/bb7.mp3");
	AddFileToDownloadsTable("sound/rats/bb8.mp3");
	AddFileToDownloadsTable("sound/rats/bb9.mp3");
	AddFileToDownloadsTable("sound/rats/bb10.mp3");
	AddFileToDownloadsTable("sound/rats/bb11.mp3");
	AddFileToDownloadsTable("sound/rats/bb12.mp3");
	AddFileToDownloadsTable("sound/rats/bb13.mp3");
	autobalance = FindConVar("mp_autoteambalance");
	taserrecharge = FindConVar("mp_taser_recharge_time");
	roundtime = FindConVar("mp_roundtime");
	defuseroundtime = FindConVar("mp_roundtime_defuse");
	hostageroundtime = FindConVar("mp_roundtime_hostage");
	freezetime = FindConVar("mp_freezetime");
	snowballlimit = FindConVar("ammo_grenade_limit_snowballs");
	grenadelimit = FindConVar("ammo_grenade_limit_total");
}

public void OnMapStart(){
	PrecacheModel("models/player/custom_player/legacy/ctm_heavy.mdl");
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl");
	PrecacheSound("rats/bumpybumpy.mp3", true);
	PrecacheSound("rats/bb2.mp3", true);
	PrecacheSound("rats/bb3.mp3", true);
	PrecacheSound("rats/bb4.mp3", true);
	PrecacheSound("rats/bb5.mp3", true);
	PrecacheSound("rats/bb6.mp3", true);
	PrecacheSound("rats/bb7.mp3", true);
	PrecacheSound("rats/bb8.mp3", true);
	PrecacheSound("rats/bb9.mp3", true);
	PrecacheSound("rats/bb10.mp3", true);
	PrecacheSound("rats/bb11.mp3", true);
	PrecacheSound("rats/bb12.mp3", true);
	PrecacheSound("rats/bb13.mp3", true);
	firstround = true;
	taserrecharge.IntValue = 2;
	roundtime.IntValue = 10;
	defuseroundtime.IntValue = 10;
	hostageroundtime.IntValue = 10;
	freezetime.IntValue = 10;
	autobalance.IntValue = 1;
	snowballlimit.IntValue = 1;
	grenadelimit.IntValue = 4;
}

public int Menu_ForceDay(Menu menu, MenuAction action, int client, int itemNum){
	if (action == MenuAction_Select){
		menu.GetItem(itemNum, dayname, sizeof(dayname), _, display, sizeof(display));
		if (StrEqual(dayname, "normal")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Normal Day\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "bigjug")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Fat Day\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "snowball")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Snowball Fight\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "hide")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Hide N Seek\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "he")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06He Throw\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "sanic")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Sanic Day\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "lowgrav")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Low Gravity Day\x01.");
			forceday = true;
		}
		else if (StrEqual(dayname, "bumpy")){
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Bumpy Day\x01.");
			forceday = true;
		}
	}
	else if (action == MenuAction_End){
		delete menu;
	}
}

public Action Command_ForceDay(int client, int args){
	Menu menu = new Menu(Menu_ForceDay);
	menu.SetTitle("Force Day");
	menu.AddItem("normal", "Normal");
	menu.AddItem("bigjug", "Fat");
	menu.AddItem("snowball", "SnowballFight");
	menu.AddItem("hide", "HideNSeek");
	menu.AddItem("he", "HE Throw");
	menu.AddItem("sanic", "Sanic Speed");
	menu.AddItem("lowgrav", "Low Gravity");
	menu.AddItem("bumpy", "R8 8/8");
	menu.Display(client, MENU_TIME_FOREVER);
}

public void OnClientPutInServer(int client){
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse); 
}

public Action OnWeaponCanUse(int client, int weapon){
	CCSPlayer p = CCSPlayer(client);
	CWeapon wep = CWeapon.FromIndex(weapon);
	char nweapon[32];
	wep.GetClassname(nweapon, sizeof(nweapon));
	//PrintToChatAll(nweapon);
	if (StrEqual(dayname, "snowball")){
		if(!StrEqual(nweapon, "weapon_snowball")){
			return Plugin_Stop;
		}
	}
	if (StrEqual(dayname, "he")){
		if(!StrEqual(nweapon, "weapon_hegrenade")){
			return Plugin_Stop;
		}
	}
	if (StrEqual(dayname, "bumpy")){
		if(!StrEqual(nweapon, "weapon_deagle")){
			return Plugin_Stop;
		}
	}
	if (StrEqual(dayname, "hide")){
		if(GetTeamClientCount(CS_TEAM_T) >= 1 ){
			if(CS_TEAM_CT == p.Team){
				if(!StrEqual(nweapon, "weapon_taser") && !StrEqual(nweapon, "weapon_tagrenade")){
					return Plugin_Stop;
				}
			}
			else if(CS_TEAM_T == p.Team){
				if(!StrEqual(nweapon, "weapon_snowball")){
					return Plugin_Stop;
				}
			}
		}
		else if(GetTeamClientCount(CS_TEAM_T) == 1 ){
			if(CS_TEAM_CT == p.Team){
				if(!StrEqual(nweapon, "weapon_taser") && !StrEqual(nweapon, "weapon_tagrenade")  && !StrEqual(nweapon, "weapon_glock")){
					return Plugin_Stop;
				}
			}
			else if(CS_TEAM_T == p.Team){
				if(!StrEqual(nweapon, "weapon_snowball") && !StrEqual(nweapon, "weapon_usp_silencer") && !StrEqual(nweapon, "weapon_mp5sd")){
					return Plugin_Stop;
				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnClientDisconnect(int client){
	SDKUnhook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void Event_RoundStart(Event event, const char[] name, bool dontbroadcast){
	if(firstround){
		dayname = "normal";
		RatDay_Normal();
		firstround = false;
	}
	else if(!firstround){
		if(forceday){
			forceday = false;
			if(StrEqual(dayname, "normal")){
				RatDay_Normal();
			}
			else if(StrEqual(dayname, "bigjug")){
				RatDay_BigJug();
			}
			else if(StrEqual(dayname, "snowball")){
				RatDay_SnowballFight();
			}
			else if(StrEqual(dayname, "hide")){
				RatDay_HideNSeek();
			}
			else if(StrEqual(dayname, "he")){
				RatDay_HeThrow();
			}
			else if(StrEqual(dayname, "sanic")){
				RatDay_SanicSpeed();
			}
			else if(StrEqual(dayname, "lowgrav")){
				RatDay_LowGravity();
			}
			else if(StrEqual(dayname, "bumpy")){
				RatDay_Bumpy();
			}
		}
		else if(!forceday){
			if(ratday <= NormalChance.IntValue){
				PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", ratday);
				PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
				PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
			}
			if(ratday > NormalChance.IntValue){
				PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", ratday);
				PrintToChatAll(XG_PREFIX_CHAT..."Special Day Number: \x06%d", specialday);
				PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
				PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
			}
			if(ratday <= NormalChance.IntValue){
				dayname = "normal";
				RatDay_Normal();
			}
			else if(ratday > NormalChance.IntValue){
				switch(specialday){
				//1 BigJug 
					case 1:{
						dayname = "bigjug";
						RatDay_BigJug();
					}
				//2 Snowball Fight
					case 2:{
						dayname = "snowball";
						RatDay_SnowballFight();
					}
				//3 HideNSeek
					case 3:{
						if(GetClientCount(true)>=4){
							dayname = "hide";
							RatDay_HideNSeek();
						}
						else{
							PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Not enough \x02players \x01for \x06Hide N Seek\x01!");
							dayname = "normal";
							RatDay_Normal();
						}
					}
				//4 HEThrow
					case 4:{
						dayname = "he";
						RatDay_HeThrow();
					}
				//5 SanicSpeed
					case 5:{
						dayname = "sanic";
						RatDay_SanicSpeed();
					}
				//6 LowGrav
					case 6:{
						dayname = "lowgrav";
						RatDay_LowGravity();
					}
				//7 Bumpy
					case 7:{
						dayname = "bumpy";
						RatDay_Bumpy();
					}
				}
			}
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontbroadcast){
	Stop_Timers();
	if(!forceday){
		//Get Random Day
		ratday = GetRandomInt(1,100);
		//Check for days that don't need to use buymenu
		if(ratday > NormalChance.IntValue){
			specialday = GetRandomInt(1, 7);
			if((specialday >= 2 && specialday <= 4) || specialday == 7){
				freezetime.IntValue = 0;
				if(specialday == 2){
					autobalance.IntValue = 0;
				}
				else{
					autobalance.IntValue = 1;
				}
			}
			else{
				autobalance.IntValue = 1;
				freezetime.IntValue = 10;
			}
		}
		else{
			autobalance.IntValue = 1;
			freezetime.IntValue = 10;
		}
	}
	else if(forceday){
		if(StrEqual(dayname, "snowball") || StrEqual(dayname, "hide") || StrEqual(dayname, "he") || StrEqual(dayname, "bumpy")){
			freezetime.IntValue = 0;
			if(StrEqual(dayname, "hide")){
				autobalance.IntValue = 0;
			}
			else{
				autobalance.IntValue = 1;
			}
		}
		else{
			freezetime.IntValue = 10;
		}
	}
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient){
			p.HeavyArmor = false;
		}
	}
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontbroadcast){
	if(StrEqual(dayname, "hide", false)){
		CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
		CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
		int hpdamage;
		char weaponused[64];
		GetEventString(event, "weapon", weaponused, sizeof(weaponused));
		GetEventInt(event, "dmg_health", hpdamage);
		if(StrEqual(weaponused, "taser", false)){
			attacker.Health += 10;
			victim.Speed = 0.5;
		}
		else{
			victim.Health += hpdamage;
		}
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontbroadcast){
	CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
	CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
	char weaponused[60];
	GetEventString(event, "weapon", weaponused, sizeof(weaponused));
	if(StrEqual(dayname, "hide", false)){
		if(StrEqual(weaponused, "taser", false)){
			if(GetTeamClientCount(CS_TEAM_T) > 1){
				victim.SwitchTeam(CS_TEAM_CT);
				attacker.Speed += 0.05;
				respawnhider = CreateTimer(1.0, Timer_RespawnAsSeeker, victim.Index);
			}
		}
	}
	if(StrEqual(dayname, "bumpy", false)){
		if(StrEqual(weaponused, "revolver", false)){
			EmitSoundToAll("rats/bumpybumpy.mp3");
		}
	}
}

public void RatDay_Normal(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Normal Day\x01!");
}

public void RatDay_BigJug(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Fat Day\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_PRIMARY);
			p.RemoveItem(wep);
			wep.Kill();
			p.HeavyArmor = true;
			p.Health = 200;
			p.Armor = 200;
			p.Speed = 0.7;
		}
	}
}

public void RatDay_SnowballFight(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Snowball Fight\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	snowballtimert = CreateTimer(1.0, Timer_GiveSnowballT, _, TIMER_REPEAT);
	snowballtimerct = CreateTimer(1.0, Timer_GiveSnowballCT, _, TIMER_REPEAT);
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			for(int i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			p.Armor = false;
			if(GetClientCount(true) <= 6){
				p.Health = 10;
			}
			else if(GetClientCount(true) <= 8){
				p.Health = 15;
			}
			else if(GetClientCount(true) <= 12){
				p.Health = 20;
			}
			else if(GetClientCount(true) <= 16){
				p.Health = 25;
			}
		}
	}
}

public void RatDay_HideNSeek(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Hide N Seek\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	tacttimer = CreateTimer(90.0, Timer_GiveTactAware, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	snowballtimert = CreateTimer(60.0, Timer_GiveSnowballT,_, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	unfreezect = CreateTimer(60.0, Timer_SeekerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	playtaunt = CreateTimer(60.0, Timer_Taunt, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	lasthider = CreateTimer(10.0, Timer_LastHider, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll(XG_PREFIX_CHAT_ALERT..."You have \x0C60 seconds \x01to hide!");
	CCSPlayer ranplayers[64];
	CCSPlayer realplayers[64];
	int i, k, chosen, count = 1;
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(count != GetClientCount(true)){
			if(p.InGame && !p.FakeClient){
				realplayers[count-1] = CCSPlayer(count);
			}
			else if(p.FakeClient){ 
				count--;
			}
			count++;
		}
	}
	//Random Players
	for (i = 1; i <= GetClientCount(true)/4; i++){
		for (k = 1; k <= sizeof(ranplayers); k++){
			ranplayers[k-1] = realplayers[GetRandomInt(0, sizeof(realplayers)-1)];
			for(chosen = k; chosen > sizeof(ranplayers); chosen--){
				while(ranplayers[chosen] == ranplayers[k]){
					ranplayers[k] = realplayers[GetRandomInt(0, sizeof(realplayers)-1)];
				}
			}
			char buf[50];
			GetClientName(ranplayers[k].Index, buf, sizeof(buf));
			PrintToChatAll(XG_PREFIX_CHAT..."Seekers: %s", buf);
			SetEntPropFloat(ranplayers[k].Index, Prop_Data, "m_flLaggedMovementValue", 0.0);
			Handle hMsg = StartMessageOne("Fade", ranplayers[k].Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
			PbSetInt(hMsg, "duration", 5000);
			PbSetInt(hMsg, "hold_time", 1500);
			PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
			PbSetColor(hMsg, "clr", {0, 0, 0, 255});
			EndMessage();
			ranplayers[k].SwitchTeam(CS_TEAM_CT);
		}
	}
	p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			SetEntProp(p.Index, Prop_Data, "m_takedamage", 0, 1);
			for(i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			p.Armor = false;
			for (i = 1; i <= sizeof(ranplayers); i++){
				if(p != ranplayers[i]){
					p.SwitchTeam(CS_TEAM_T);
					p.Speed = 0.9;
				}
			}
		}
	}
}

public void RatDay_HeThrow(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06HE Throw\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true); 
	hetimer = CreateTimer(1.0, Timer_GiveHEGrenade, _, TIMER_REPEAT);
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			for(int i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
}

public void RatDay_SanicSpeed(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Sanic Day\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Speed = 3.0;
		}
	}
}

public void RatDay_LowGravity(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Low Gravity\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Gravity = 0.2;
		}
	}
}

public void RatDay_Bumpy(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06R8 8/8 M8\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	EmitSoundToAll("rats/bumpybumpy.mp3");
	infiniter8 = CreateTimer(0.3, Timer_InfiniteR8, _, TIMER_REPEAT);
	CCSPlayer p;
	CWeapon wep;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			for(int i = 0; i <= CS_SLOT_C4;i++){ 
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			wep = GivePlayerWeapon(p, "weapon_revolver");
			wep.Ammo = 8;
			wep.ReserveAmmo = 0;
		}
	}
}

public Action Timer_GiveSnowballCT(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action Timer_GiveSnowballT(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_T == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action Timer_GiveTactAware(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_tagrenade");
			}
		}
	}
}

public Action Timer_GiveHEGrenade(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_hegrenade");
			}
		}
	}
}

public Action Timer_SeekerStart(Handle timer){
	PrintToChatAll(XG_PREFIX_CHAT..."\x02Ready or not here they come!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			SetEntProp(p.Index, Prop_Data, "m_takedamage", 2, 1);
			if(CS_TEAM_CT == p.Team){
				SetEntPropFloat(p.Index, Prop_Data, "m_flLaggedMovementValue", 1.0);
				Handle hMsg = StartMessageOne("Fade", p.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
				PbSetInt(hMsg, "duration", 5000);
				PbSetInt(hMsg, "hold_time", 1500);
				PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
				PbSetColor(hMsg, "clr", {0, 0, 0, 0});
				EndMessage();
				GivePlayerWeapon(p, "weapon_taser");
			}
		}
	}
}

public Action Timer_Taunt(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_T == p.Team){
			float vec[3];
			GetClientAbsOrigin(p.Index, vec);
			vec[2] += 10;
			GetClientEyePosition(p.Index, vec);
			int taunt = GetRandomInt(1, 13);
			if(taunt == 1){
				EmitAmbientSound("rats/bumpybumpy.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 2){
				EmitAmbientSound("rats/bb2.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 3){
				EmitAmbientSound("rats/bb3.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 4){
				EmitAmbientSound("rats/bb4.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 5){
				EmitAmbientSound("rats/bb5.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 6){
				EmitAmbientSound("rats/bb6.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 7){
				EmitAmbientSound("rats/bb7.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 8){
				EmitAmbientSound("rats/bb8.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 9){
				EmitAmbientSound("rats/bb9.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 10){
				EmitAmbientSound("rats/bb10.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 11){
				EmitAmbientSound("rats/bb11.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 12){
				EmitAmbientSound("rats/bb12.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
			else if(taunt == 13){
				EmitAmbientSound("rats/bb13.mp3", vec, p.Index, SNDLEVEL_GUNFIRE);
			}
		}
	}
}

public Action Timer_RespawnAsSeeker(Handle timer, any client){
	CCSPlayer p = CCSPlayer(client);
	p.Respawn();
	p.Speed = 1.0;
	for(int i = 0; i <= CS_SLOT_C4;i++){
		CWeapon wep;
		while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
			p.RemoveItem(wep);
			wep.Kill();
		}
	}
	GivePlayerWeapon(p, "weapon_taser");
}

public Action Timer_LastHider(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && GetTeamClientCount(CS_TEAM_T) == 1){
			if(CS_TEAM_T == p.Team){
				GivePlayerWeapon(p, "weapon_mp5sd");
				GivePlayerWeapon(p, "weapon_usp_silencer");
				p.Armor = true;
				p.Armor = 200;
				p.Speed = 2.5;
				p.Health = 200;
			}
			else if(CS_TEAM_CT == p.Team){
				GivePlayerWeapon(p, "weapon_glock");
				p.Speed = 1.0;
			}
			delete lasthider;
		}
	}
}

public Action Timer_InfiniteR8(Handle timer){
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_SECONDARY);
			wep.Ammo = 8;
		}
	}
}

public Action Stop_Timers(){
	if(snowballtimerct != null){
		delete snowballtimerct;
	}
	if(snowballtimert != null){
		delete snowballtimert;
	}
	if(unfreezect != null){
		delete unfreezect;
	}
	if(tacttimer != null){
		delete tacttimer;
	}
	if(hetimer != null){
		delete hetimer;
	}
	if(playtaunt != null){
		delete playtaunt;
	}
	if(infiniter8 != null){
		delete infiniter8;
	}
	if(respawnhider != null){
		delete respawnhider;
	}
	if(lasthider != null){
		delete lasthider;
	}
}