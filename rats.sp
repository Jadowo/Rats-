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

public Plugin myinfo = {
	name = " [xG] Rats",
	author = PLUGIN_AUTHOR,
	description = "rats rats rats",
	version = PLUGIN_VERSION,
	url = "https://github.com/Jadowo/Rats-"
};

Handle TimerGiveSnowballCT;
Handle TimerGiveSnowballT;
Handle TimerPlayTaunt;
Handle TimerGiveHENade;
Handle TimerGiveTactNade;
Handle TimerSeekerStart;
Handle TimerRespawnHider;
Handle TimerInfiniteR8;
ConVar AutoBalance;
ConVar TaserRecharge;
ConVar RoundTime;
ConVar DefuseRoundTime;
ConVar HostageRoundTime;
ConVar FreezeTime;
ConVar NormalChance;
ConVar SnowballLimit;
ConVar GrenadeLimit;
ConVar BhopEnable;
ConVar ExoForward;
ConVar PlayersForDays;
int SpecialDay;
int RatDay;
int totalplayers;
bool FirstRound;
bool ForceDay;
enum DayType{
	Day_Normal = 0,
	Day_BigJug,
	Day_Snowball,
	Day_HideNSeek,
	Day_HEThrow,
	Day_Sanic,
	Day_LowGravity,
	Day_Bumpy,
	Day_OneInTheChamber,
	Day_ExoBump
};
DayType CurrentDay;


public void OnPluginStart(){
	RegAdminCmd("sm_forceday", Command_ForceDay, ADMFLAG_ROOT);
	RegAdminCmd("sm_fd", Command_ForceDay, ADMFLAG_ROOT);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	NormalChance = CreateConVar("sm_normal_chance", "70", "Percentage out of 100 for normal day");
	AutoBalance = FindConVar("mp_autoteambalance");
	TaserRecharge = FindConVar("mp_taser_recharge_time");
	RoundTime = FindConVar("mp_roundtime");
	DefuseRoundTime = FindConVar("mp_roundtime_defuse");
	HostageRoundTime = FindConVar("mp_roundtime_hostage");
	FreezeTime = FindConVar("mp_freezetime");
	SnowballLimit = FindConVar("ammo_grenade_limit_snowballs");
	GrenadeLimit = FindConVar("ammo_grenade_limit_total");
	BhopEnable = FindConVar("sv_enablebunnyhopping");
	ExoForward = FindConVar("sv_exojump_jumpbonus_forward");
	PlayersForDays = CreateConVar("sm_specialdays_players", "4", "Number of player required for special day to be active");
	AutoExecConfig(true, "plugin.rats");
}

public void OnMapStart(){
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
	FirstRound = true;
	TaserRecharge.IntValue = 2;
	RoundTime.IntValue = 10;
	DefuseRoundTime.IntValue = 10;
	HostageRoundTime.IntValue = 10;
	FreezeTime.IntValue = 10;
	AutoBalance.IntValue = 1;
	SnowballLimit.IntValue = 1;
	GrenadeLimit.IntValue = 4;
	BhopEnable.IntValue = 1;
	ExoForward.IntValue = 2;
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
	menu.AddItem("bumpy", "Bumpy Bumpy");
	menu.AddItem("onechamber", "One In The Chamber");
	menu.AddItem("exobump", "ExoBump Day");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_ForceDay(Menu menu, MenuAction action, int client, int itemNum){
	char display[64], dayName[64];
	if (action == MenuAction_Select){
		menu.GetItem(itemNum, dayName, sizeof(dayName), _, display, sizeof(display));
		if (StrEqual(dayName, "normal")){
			RatDay = NormalChance.IntValue;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Normal Day\x01.");
		}
		else if (StrEqual(dayName, "bigjug")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 1;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Fat Day\x01.");
		}
		else if (StrEqual(dayName, "snowball")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 2;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Snowball Fight\x01.");
		}
		else if (StrEqual(dayName, "hide")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 3;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Hide N Seek\x01.");
		}
		else if (StrEqual(dayName, "he")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 4;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06He Throw\x01.");
		}
		else if (StrEqual(dayName, "sanic")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 5;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Sanic Day\x01.");
		}
		else if (StrEqual(dayName, "lowgrav")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 6;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Low Gravity Day\x01.");
		}
		else if (StrEqual(dayName, "bumpy")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 7;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Bumpy Day\x01.");
		}
		else if (StrEqual(dayName, "onechamber")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 8;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06One In The Chamber\x01.");
		}
		else if (StrEqual(dayName, "exobump")){
			RatDay = NormalChance.IntValue+1;
			SpecialDay = 9;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06ExoBump Day\x01.");
		}
		ForceDay = true;
	}
	else if (action == MenuAction_End){
		delete menu;
	}
}

public void OnClientPutInServer(int client){
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	CCSPlayer p = CCSPlayer(client);
	if(!p.FakeClient){
		totalplayers++;
	}
}

public void OnClientDisconnect(int client){
	SDKUnhook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	CCSPlayer p = CCSPlayer(client);
	if(!p.FakeClient){
		totalplayers--;
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontbroadcast){
	bool daysAlert;
	if(FirstRound){
		CurrentDay = Day_Normal;
		SpecialDay_Normal();
		FirstRound = false;
	}
	else{
		/*
		if(RatDay <= NormalChance.IntValue){
			PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", RatDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
		}
		if(RatDay > NormalChance.IntValue){
			PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", RatDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Number: \x06%d", SpecialDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
		}
		*/
		ForceDay = false;
		if(RatDay <= NormalChance.IntValue){
			CurrentDay = Day_Normal;
			SpecialDay_Normal();
			if(totalplayers < PlayersForDays.IntValue){
				if(daysAlert){
					PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Need at least \x07%d players \x01to enable \x06Special Days!", PlayersForDays.IntValue);
					daysAlert = false;
				}
				else{
					daysAlert = true;
				}
			}
		}
		else{
			switch(SpecialDay){
			//1 BigJug 
				case 1:{
					CurrentDay = Day_BigJug;
					SpecialDay_BigJug();
				}
			//2 Snowball Fight
				case 2:{
					CurrentDay = Day_Snowball;
					SpecialDay_SnowballFight();
				}
			//3 HideNSeek
				case 3:{
					CurrentDay = Day_HideNSeek;
					SpecialDay_HideNSeek();
				}
			//4 HEThrow
				case 4:{
					CurrentDay = Day_HEThrow;
					SpecialDay_HeThrow();
				}
			//5 SanicSpeed
				case 5:{
					CurrentDay = Day_Sanic;
					SpecialDay_SanicSpeed();
				}
			//6 LowGrav
				case 6:{
					CurrentDay = Day_LowGravity;
					SpecialDay_LowGravity();
				}
			//7 Bumpy
				case 7:{
					CurrentDay = Day_Bumpy;
					SpecialDay_Bumpy();
				}
			//8 OneInTheChamber
				case 8:{
					CurrentDay = Day_OneInTheChamber;
					SpecialDay_OneInTheChamber();
				}
			//9 BumpMine
				case 9:{
					CurrentDay = Day_ExoBump;
					SpecialDay_ExoBump();
				}
			}
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
	Stop_Timers();
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.HeavyArmor = false;
			SetEntProp(p.Index, Prop_Send, "m_passiveItems", 0, 1, 1);
		}
	}
	if(!ForceDay){
		RatDay = GetRandomInt(1,100);
	}
	//Get Random Day
	if(RatDay > NormalChance.IntValue){
		if(totalplayers >= PlayersForDays.IntValue){
			if(!ForceDay){
				SpecialDay = GetRandomInt(1, 9);
			}
			if(totalplayers < 4 && SpecialDay == 3){
				SpecialDay = 2;
			}
			//Check for days that don't need to use buymenu
			if((SpecialDay >= 2 && SpecialDay <= 4) || (SpecialDay >= 7 && SpecialDay <= 9)){
				FreezeTime.IntValue = 0;
				if(SpecialDay == 3){
					AutoBalance.IntValue = 0;
				}
				else{
					AutoBalance.IntValue = 1;
				}
			}
			else{
				AutoBalance.IntValue = 1;
				FreezeTime.IntValue = 10;
			}
		}
		else{
			RatDay = NormalChance.IntValue;
		}
	}
	else{
			AutoBalance.IntValue = 1;
			FreezeTime.IntValue = 10;
	}
}

public Action OnWeaponCanUse(int client, int weapon){
	CCSPlayer p = CCSPlayer(client);
	CWeapon wep = CWeapon.FromIndex(weapon);
	char weaponClassName[32];
	wep.GetClassname(weaponClassName, sizeof(weaponClassName));
	//PrintToChatAll(weaponClassName);
	switch(CurrentDay){
		case Day_Snowball:{
			if(!StrEqual(weaponClassName, "weapon_snowball")){return Plugin_Stop;}
		}
		case Day_HEThrow:{
			if(!StrEqual(weaponClassName, "weapon_hegrenade")){return Plugin_Stop;}
		}
		case Day_Bumpy:{
			if(!StrEqual(weaponClassName, "weapon_deagle")){return Plugin_Stop;}
		}
		case Day_OneInTheChamber:{
			if(!StrEqual(weaponClassName, "weapon_deagle") && !StrEqual(weaponClassName, "weapon_knife")){return Plugin_Stop;}
		}
		case Day_HideNSeek:{
			if(GetTeamClientCount(CS_TEAM_T) == 1 ){
				if(CS_TEAM_CT == p.Team){
					if(!StrEqual(weaponClassName, "weapon_taser") && !StrEqual(weaponClassName, "weapon_tagrenade")  && !StrEqual(weaponClassName, "weapon_glock")){
						return Plugin_Stop;
					}
				}
				else if(CS_TEAM_T == p.Team){
					if(!StrEqual(weaponClassName, "weapon_snowball") && !StrEqual(weaponClassName, "weapon_hkp2000") && !StrEqual(weaponClassName, "weapon_mp7")){
						return Plugin_Stop;
					}
				}
			}
			if(GetTeamClientCount(CS_TEAM_T) > 1 ){
				if(CS_TEAM_CT == p.Team){
					if(!StrEqual(weaponClassName, "weapon_taser") && !StrEqual(weaponClassName, "weapon_tagrenade")){
						return Plugin_Stop;
					}
				}
				else if(CS_TEAM_T == p.Team){
					if(!StrEqual(weaponClassName, "weapon_snowball")){
						return Plugin_Stop;
					}
				}
			}
		}
		case Day_ExoBump:{
			if(!StrEqual(weaponClassName, "weapon_shield") && !StrEqual(weaponClassName, "weapon_bumpmine")){
				return Plugin_Stop;
			}
		}
		default:{
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &dmg, int &dmgType, int &weapon, float dmgForce[3], float dmgPos[3], int dmgCustom) {
	if(CurrentDay == Day_OneInTheChamber || CurrentDay == Day_ExoBump){
		if(dmgType == DMG_FALL){
			dmg = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast){
	if(CurrentDay == Day_HideNSeek){
		CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
		CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
		int hpDamage;
		int hpLeft;
		char weaponUsed[64];
		GetEventString(event, "weapon", weaponUsed, sizeof(weaponUsed));
		//PrintToChatAll(weaponused);
		GetEventInt(event, "dmg_health", hpDamage);
		GetEventInt(event, "health", hpLeft);
		if(StrEqual(weaponUsed, "taser", false)){
			attacker.Health += hpDamage/2;
			victim.Speed = hpLeft/100.0;
		}
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
	CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
	char weaponUsed[60];
	GetEventString(event, "weapon", weaponUsed, sizeof(weaponUsed));
	//PrintToChatAll(weaponused);
	if(CurrentDay == Day_OneInTheChamber){
		CWeapon wep = attacker.GetWeapon(CS_SLOT_SECONDARY);
		wep.Ammo += 1;
	}
	if(CurrentDay == Day_HideNSeek){
		if(GetTeamClientCount(CS_TEAM_T) > 1){
			if(StrEqual(weaponUsed, "taser", false)){
				victim.SwitchTeam(CS_TEAM_CT);
				attacker.Speed += 0.05;
				TimerRespawnHider = CreateTimer(1.0, Timer_RespawnHider, victim, TIMER_FLAG_NO_MAPCHANGE);
			}
			else{
				victim.SwitchTeam(CS_TEAM_CT);
			}
		}
		else{
			CCSPlayer p;
			while(CCSPlayer.Next(p)){
				if(p.InGame && !p.FakeClient && p.Alive){
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
				}
			}
		}
	}
	if(CurrentDay == Day_Bumpy){
		if(StrEqual(weaponUsed, "revolver", false)){
			EmitSoundToAll("rats/bumpybumpy.mp3");
		}
	}
}

public void SpecialDay_Normal(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Normal Day\x01!");
}

public void SpecialDay_BigJug(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Fat Day\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Health = 200;
			p.Armor = 200;
			p.HeavyArmor = true;
			p.Speed = 0.6;
			CWeapon wep;
			if((wep = p.GetWeapon(CS_SLOT_PRIMARY)) != NULL_CWEAPON){
				p.RemoveItem(wep);
				wep.Kill();
			}
		}
	}
}

public void SpecialDay_SnowballFight(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Snowball Fight\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	TimerGiveSnowballT = CreateTimer(1.0, Timer_GiveSnowballT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	TimerGiveSnowballCT = CreateTimer(1.0, Timer_GiveSnowballCT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
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
			else{
				p.Health = 25;
			}
		}
	}
}

public void SpecialDay_HideNSeek(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Hide N Seek\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	TimerGiveTactNade = CreateTimer(90.0, Timer_GiveTactAware, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	TimerGiveSnowballT = CreateTimer(60.0, Timer_GiveSnowballT,_, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	TimerSeekerStart = CreateTimer(60.0, Timer_SeekerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	TimerPlayTaunt = CreateTimer(60.0, Timer_PlayTaunt, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll(XG_PREFIX_CHAT_ALERT..."You have \x0C60 seconds \x01to hide!");
	CCSPlayer randPlayers[64];
	CCSPlayer realPlayers[64];
	int i, chosen, count = 0;
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient){
			realPlayers[count] = p;
			count++;
			for(i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
	float seekersPlayers = totalplayers / 4.0;
	//Random Players
	for (i = 0; i <= RoundFloat(seekersPlayers); i++){
		randPlayers[i] = realPlayers[GetRandomInt(0, count-1)];
		chosen = count-1;
		while(randPlayers[chosen] == randPlayers[i]){
			randPlayers[i] = realPlayers[GetRandomInt(0, count-1)];
			chosen--;
		}
		char buf[64];
		GetClientName(randPlayers[i].Index, buf, sizeof(buf));
		PrintToChatAll(XG_PREFIX_CHAT..."Seekers: %s", buf);
		SetEntPropFloat(randPlayers[i].Index, Prop_Data, "m_flLaggedMovementValue", 0.0);
		Handle hMsg = StartMessageOne("Fade", randPlayers[i].Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		PbSetInt(hMsg, "duration", 5000);
		PbSetInt(hMsg, "hold_time", 1500);
		PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
		PbSetColor(hMsg, "clr", {0, 0, 0, 255});
		EndMessage();
		randPlayers[i].SwitchTeam(CS_TEAM_CT);
	}
	CCSPlayer player; 
	while(CCSPlayer.Next(player)){
		if(player.InGame && player.Alive){
			SetEntProp(player.Index, Prop_Data, "m_takedamage", 0, 1);
			for (i = 0; i <= GetClientCount(true)/4; i++){
				if(player != randPlayers[i]){
					player.SwitchTeam(CS_TEAM_T);
					player.Speed = 0.95;
					player.Armor = false;
				}
			}
		}
	}
}

public void SpecialDay_HeThrow(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06HE Throw\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true); 
	TimerGiveHENade = CreateTimer(1.0, Timer_GiveHEGrenade, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
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

public void SpecialDay_SanicSpeed(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Sanic Day\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Speed = 3.0;
		}
	}
}

public void SpecialDay_LowGravity(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Low Gravity\x01!");
	CCSPlayer p;
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Gravity = 0.2;
		}
	}
}

public void SpecialDay_Bumpy(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06R8 8/8 M8\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	EmitSoundToAll("rats/bumpybumpy.mp3");
	TimerInfiniteR8 = CreateTimer(0.3, Timer_InfiniteR8, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
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

public void SpecialDay_OneInTheChamber(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06One In The Chamber\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
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
			p.Health = 1;
			p.Armor = 1;
			GivePlayerWeapon(p, "weapon_knife");
			wep = GivePlayerWeapon(p, "weapon_revolver");
			wep.Ammo = 1;
			wep.ReserveAmmo = 0;
		}
	}
}

public void SpecialDay_ExoBump(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06ExoBump Day\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
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
			SetEntProp(p.Index, Prop_Send, "m_passiveItems", 1, 1, 1);
			GivePlayerWeapon(p, "weapon_shield");
			GivePlayerWeapon(p, "weapon_bumpmine");
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

public Action Timer_PlayTaunt(Handle timer){
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

public Action Timer_RespawnHider(Handle timer, CCSPlayer victim){
	victim.Respawn();
	victim.Speed = 1.0;
	for(int i = 0; i <= CS_SLOT_C4;i++){
		CWeapon wep;
		while((wep = victim.GetWeapon(i)) != NULL_CWEAPON){
			victim.RemoveItem(wep);
			wep.Kill();
		}
	}
	GivePlayerWeapon(victim, "weapon_taser");
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
	if(TimerGiveSnowballCT != null){
		delete TimerGiveSnowballCT;
	}
	if(TimerGiveSnowballT != null){
		delete TimerGiveSnowballT;
	}
	if(TimerSeekerStart != null){
		delete TimerSeekerStart;
	}
	if(TimerGiveTactNade != null){
		delete TimerGiveTactNade;
	}
	if(TimerGiveHENade != null){
		delete TimerGiveHENade;
	}
	if(TimerPlayTaunt != null){
		delete TimerPlayTaunt;
	}
	if(TimerInfiniteR8 != null){
		delete TimerInfiniteR8;
	}
	if(TimerRespawnHider != null){
		delete TimerRespawnHider;
	}
}