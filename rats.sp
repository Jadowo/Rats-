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

#define MAX_TAUNTS 13
char taunts[MAX_TAUNTS][PLATFORM_MAX_PATH] = {
	"rats/bumpybumpy.mp3", 
	"rats/bb2.mp3", 
	"rats/bb3.mp3", 
	"rats/bb4.mp3", 
	"rats/bb5.mp3", 
	"rats/bb6.mp3", 
	"rats/bb7.mp3", 
	"rats/bb8.mp3", 
	"rats/bb9.mp3", 
	"rats/bb10.mp3", 
	"rats/bb11.mp3", 
	"rats/bb12.mp3", 
	"rats/bb13.mp3"
};

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
Handle TimerInfiniteR8;
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
int TotalPlayers;
bool FirstRound;
bool ForceDay;
bool FallEvent;
bool NoGunEvent;
int RareEventNum;

enum DayType {
	Day_Normal = 0, 
	Day_BigJug, 
	Day_Snowball, 
	Day_HideNSeek, 
	Day_HEThrow, 
	Day_Sanic, 
	Day_LowGravity, 
	Day_Bumpy, 
	Day_OneInTheChamber, 
	Day_ExoBump, 
	Day_RiotShield, 
	Day_ExoBoot, 
	Day_BumpMine
};
DayType CurrentDay;


public void OnPluginStart() {
	RegAdminCmd("sm_forceday", Command_ForceDay, ADMFLAG_ROOT);
	RegAdminCmd("sm_fd", Command_ForceDay, ADMFLAG_ROOT);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	NormalChance = CreateConVar("sm_normal_chance", "60", "Percentage out of 100 for normal day");
	PlayersForDays = CreateConVar("sm_specialdays_players", "4", "Number of player required for special day to be active");
	TaserRecharge = FindConVar("mp_taser_recharge_time");
	RoundTime = FindConVar("mp_roundtime");
	DefuseRoundTime = FindConVar("mp_roundtime_defuse");
	HostageRoundTime = FindConVar("mp_roundtime_hostage");
	FreezeTime = FindConVar("mp_freezetime");
	SnowballLimit = FindConVar("ammo_grenade_limit_snowballs");
	GrenadeLimit = FindConVar("ammo_grenade_limit_total");
	BhopEnable = FindConVar("sv_enablebunnyhopping");
	ExoForward = FindConVar("sv_exojump_jumpbonus_forward");
	AutoExecConfig(true, "plugin.rats");
}

public void OnMapStart() {
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
	SetConVarInt(TaserRecharge, 2);
	SetConVarInt(RoundTime, 10);
	SetConVarInt(DefuseRoundTime, 10);
	SetConVarInt(HostageRoundTime, 10);
	SetConVarInt(FreezeTime, 10);
	SetConVarInt(SnowballLimit, 1);
	SetConVarInt(GrenadeLimit, 4);
	SetConVarInt(BhopEnable, 1);
	SetConVarInt(ExoForward, 2);
}

public Action Command_ForceDay(int client, int args) {
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
	menu.AddItem("exobump", "RiotExoBump");
	menu.AddItem("riot", "Riot Shields");
	menu.AddItem("exoboot", "Exoboots");
	menu.AddItem("bumpmine", "Bump Mines");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_ForceDay(Menu menu, MenuAction action, int client, int itemNum) {
	char display[64], dayName[64];
	if (action == MenuAction_Select) {
		menu.GetItem(itemNum, dayName, sizeof(dayName), _, display, sizeof(display));
		if (StrEqual(dayName, "normal")) {
			RatDay = NormalChance.IntValue;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Normal Day\x01.");
		} else if (StrEqual(dayName, "bigjug")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 1;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Fat Day\x01.");
		} else if (StrEqual(dayName, "snowball")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 2;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Snowball Fight\x01.");
		} else if (StrEqual(dayName, "hide")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 3;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Hide N Seek\x01.");
		} else if (StrEqual(dayName, "he")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 4;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06He Throw\x01.");
		} else if (StrEqual(dayName, "sanic")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 5;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Sanic Day\x01.");
		} else if (StrEqual(dayName, "lowgrav")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 6;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Low Gravity Day\x01.");
		} else if (StrEqual(dayName, "bumpy")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 7;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Bumpy Day\x01.");
		} else if (StrEqual(dayName, "onechamber")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 8;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06One In The Chamber\x01.");
		} else if (StrEqual(dayName, "exobump")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 9;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06ExoBump Day\x01.");
		} else if (StrEqual(dayName, "riot")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 10;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Riot Shields\x01.");
		} else if (StrEqual(dayName, "exoboot")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 11;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Exoboots\x01.");
		} else if (StrEqual(dayName, "bumpmine")) {
			RatDay = NormalChance.IntValue + 1;
			SpecialDay = 12;
			ShowActivity2(client, XG_PREFIX_CHAT, "Next Day \x07forced \x01to \x06Bump Mines\x01.");
		}
		ForceDay = true;
	}
	else if (action == MenuAction_End) {
		delete menu;
	}
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

public void OnClientDisconnect(int client) {
	SDKUnhook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void Event_RoundStart(Event event, const char[] name, bool dontbroadcast) {
	if (FirstRound) {
		CurrentDay = Day_Normal;
		SpecialDay_Normal();
		FirstRound = false;
	}
	else {
		/*
		if(RatDay <= NormalChance.IntValue){
			PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", RatDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
			if(ForceDay){
				PrintToChatAll(XG_PREFIX_CHAT..."ForceDay: True");
			}else{
				PrintToChatAll(XG_PREFIX_CHAT..."ForceDay: False");
			}
		}
		if(RatDay > NormalChance.IntValue){
			PrintToChatAll(XG_PREFIX_CHAT..."Day Number: \x06%d", RatDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Number: \x06%d", SpecialDay);
			PrintToChatAll(XG_PREFIX_CHAT..."Normal Day Chance: \x06%d%", NormalChance.IntValue);
			PrintToChatAll(XG_PREFIX_CHAT..."Special Day Chance: \x06%d%", 100-NormalChance.IntValue);
			if(ForceDay){
				PrintToChatAll(XG_PREFIX_CHAT..."ForceDay: True");
			}else{
				PrintToChatAll(XG_PREFIX_CHAT..."ForceDay: False");
			}
		}
		*/
		if (RatDay <= NormalChance.IntValue) {
			CurrentDay = Day_Normal;
			SpecialDay_Normal();
			PlayerCount();
			if (TotalPlayers < PlayersForDays.IntValue) {
				int dayAlert = GetRandomInt(1, 2);
				if (dayAlert == GetRandomInt(1, 2)) { PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Need at least \x07%d players \x01to enable \x06Special Days!", PlayersForDays.IntValue); }
			}
		}
		else {
			switch (SpecialDay) {
				case 1: { CurrentDay = Day_BigJug; SpecialDay_BigJug(); }
				case 2: { CurrentDay = Day_Snowball; SpecialDay_SnowballFight(); }
				case 3: { CurrentDay = Day_HideNSeek; SpecialDay_HideNSeek(); }
				case 4: { CurrentDay = Day_HEThrow; SpecialDay_HeThrow(); }
				case 5: { CurrentDay = Day_Sanic; SpecialDay_SanicSpeed(); }
				case 6: { CurrentDay = Day_LowGravity; SpecialDay_LowGravity(); }
				case 7: { CurrentDay = Day_Bumpy; SpecialDay_Bumpy(); }
				case 8: { CurrentDay = Day_OneInTheChamber; SpecialDay_OneInTheChamber(); }
				case 9: { CurrentDay = Day_ExoBump; SpecialDay_ExoBump(); }
				case 10: { CurrentDay = Day_RiotShield; SpecialDay_RiotShield(); }
				case 11: { CurrentDay = Day_ExoBoot; SpecialDay_ExoBoot(); }
				case 12: { CurrentDay = Day_BumpMine; SpecialDay_BumpMine(); }
			}
		}
	}
	RareEvents();
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
	if (CurrentDay == Day_Snowball) {
		delete TimerGiveSnowballCT; delete TimerGiveSnowballT;
	}
	if (CurrentDay == Day_HideNSeek) {
		int countCT = GetTeamClientCount(CS_TEAM_CT);
		int countT = GetTeamClientCount(CS_TEAM_T);
		int total = countCT + countT;
		if (total % 2 == 0) {
			while (countCT != total/2) {
				if(countCT < total/2){
					while(countCT < total/2){
						CCSPlayer p;
						while(CCSPlayer.Next(p)){
							if(p.Team == CS_TEAM_T){p.SwitchTeam(CS_TEAM_CT);}
						}
					}
				}
				else{
					while(countCT >= total/2){
						CCSPlayer p;
						while(CCSPlayer.Next(p)){
							if(p.Team == CS_TEAM_CT){p.SwitchTeam(CS_TEAM_T);}
						}
					}
				}
			}					
		}
		delete TimerGiveSnowballT;
		delete TimerGiveTactNade;
		delete TimerPlayTaunt;
	}
	if (CurrentDay == Day_HEThrow) {
		delete TimerGiveHENade;
	}
	if (CurrentDay == Day_Bumpy) {
		delete TimerInfiniteR8;
	}
	FallEvent = false;
	NoGunEvent = false;
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			p.HeavyArmor = false;
			p.Speed = 1.0;
			p.Gravity = 1.0;
			SetEntProp(p.Index, Prop_Send, "m_passiveItems", 0, 1, 1);
			Handle hMsg = StartMessageOne("Fade", p.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
			PbSetInt(hMsg, "duration", 5000);
			PbSetInt(hMsg, "hold_time", 1500);
			PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
			PbSetColor(hMsg, "clr", { 0, 0, 0, 0 } );
			EndMessage();
		}
	}
	if (!ForceDay) {
		PlayerCount();
		RatDay = GetRandomInt(1, 100);
		SpecialDay = GetRandomInt(1, 12);
		if (TotalPlayers < PlayersForDays.IntValue) {
			RatDay = NormalChance.IntValue;
			SetConVarInt(FreezeTime, 10);
		}
	}
	//Get Random Day
	if (RatDay > NormalChance.IntValue) {
		PlayerCount();
		if (TotalPlayers >= PlayersForDays.IntValue || ForceDay) {
			if (TotalPlayers < PlayersForDays.IntValue && SpecialDay == 3 && !ForceDay) {
				SpecialDay = GetRandomInt(4, 12); 
			}
			switch (SpecialDay) {
				case 1: { /*BigJug*/SetConVarInt(FreezeTime, 10); }
				case 2: { /*Snowball*/SetConVarInt(FreezeTime, 0); }
				case 3: { /*HideNSeek*/SetConVarInt(FreezeTime, 0); }
				case 4: { /*HEThrow*/SetConVarInt(FreezeTime, 0); }
				case 5: { /*Sanic*/SetConVarInt(FreezeTime, 10); }
				case 6: { /*LowGravity*/SetConVarInt(FreezeTime, 10); }
				case 7: { /*Bumpy*/SetConVarInt(FreezeTime, 0); }
				case 8: { /*OneInTheChamber*/SetConVarInt(FreezeTime, 0); }
				case 9: { /*ExoBump*/SetConVarInt(FreezeTime, 10); }
				case 10: { /*RiotShield*/SetConVarInt(FreezeTime, 10); }
				case 11: { /*ExoBoot*/SetConVarInt(FreezeTime, 10); }
				case 12: { /*BumpMine*/SetConVarInt(FreezeTime, 10); }
			}
		}
	}
	else {
		SetConVarInt(FreezeTime, 10);
	}
	ForceDay = false;
}

public Action OnWeaponCanUse(int client, int weapon) {
	CCSPlayer p = CCSPlayer(client);
	CWeapon wep = CWeapon.FromIndex(weapon);
	char weaponClassName[32];
	switch (CurrentDay) {
		case Day_BigJug: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_knife")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_Snowball: {
			wep.GetClassname(weaponClassName, sizeof(weaponClassName));
			if (!StrEqual(weaponClassName, "weapon_snowball")) { return Plugin_Stop; }
		}
		case Day_HideNSeek: {
			wep.GetClassname(weaponClassName, sizeof(weaponClassName));
			if (GetTeamClientCount(CS_TEAM_T) == 1) {
				if (CS_TEAM_CT == p.Team) {
					if (!StrEqual(weaponClassName, "weapon_knife") && 
						!StrEqual(weaponClassName, "weapon_taser") && 
						!StrEqual(weaponClassName, "weapon_tagrenade") && 
						!StrEqual(weaponClassName, "weapon_deagle")) {
						return Plugin_Stop;
					}
				}
				else if (CS_TEAM_T == p.Team) {
					if (!StrEqual(weaponClassName, "weapon_knife") && 
						!StrEqual(weaponClassName, "weapon_snowball") && 
						!StrEqual(weaponClassName, "weapon_hkp2000") && 
						!StrEqual(weaponClassName, "weapon_mp7")) {
						return Plugin_Stop;
					}
				}
			}
			else {
				if (CS_TEAM_CT == p.Team) {
					if (!StrEqual(weaponClassName, "weapon_taser") && 
						!StrEqual(weaponClassName, "weapon_tagrenade")) {
						return Plugin_Stop;
					}
				}
				else if (CS_TEAM_T == p.Team) {
					if (!StrEqual(weaponClassName, "weapon_snowball")) {
						return Plugin_Stop;
					}
				}
			}
		}
		case Day_HEThrow: {
			wep.GetClassname(weaponClassName, sizeof(weaponClassName));
			if (!StrEqual(weaponClassName, "weapon_hegrenade")) { return Plugin_Stop; }
		}
		case Day_Sanic: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_knife")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_LowGravity: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_knife")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_Bumpy: {
			wep.GetClassname(weaponClassName, sizeof(weaponClassName));
			if (!StrEqual(weaponClassName, "weapon_deagle")) { return Plugin_Stop; }
		}
		case Day_OneInTheChamber: {
			wep.GetClassname(weaponClassName, sizeof(weaponClassName));
			if (!StrEqual(weaponClassName, "weapon_deagle") && !StrEqual(weaponClassName, "weapon_knife")) { return Plugin_Stop; }
		}
		case Day_ExoBump: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_shield") && 
					!StrEqual(weaponClassName, "weapon_knife") && 
					!StrEqual(weaponClassName, "weapon_bumpmine")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_RiotShield: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_shield") && 
					!StrEqual(weaponClassName, "weapon_knife")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_ExoBoot: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_knife")) {
					return Plugin_Stop;
				}
			}
		}
		case Day_BumpMine: {
			if (NoGunEvent) {
				wep.GetClassname(weaponClassName, sizeof(weaponClassName));
				if (!StrEqual(weaponClassName, "weapon_bumpmine")) {
					return Plugin_Stop;
				}
			}
		}
		default: {
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &dmg, int &dmgType, int &weapon, float dmgForce[3], float dmgPos[3], int dmgCustom) {
	if (CurrentDay == Day_OneInTheChamber || CurrentDay == Day_ExoBump) {
		if (dmgType == DMG_FALL && FallEvent == false) {
			dmg = 1.0;
			return Plugin_Changed;
		}
		else {
			if (dmgType == DMG_FALL && FallEvent == true) {
				dmg = 500.0;
				return Plugin_Changed;
			}
		}
	}
	if (dmgType == DMG_FALL && FallEvent == true) {
		dmg = 420.0;
		return Plugin_Changed;
	}
	if (CurrentDay == Day_OneInTheChamber) {
		char weaponUsed[64];
		GetEdictClassname(weapon, weaponUsed, sizeof(weaponUsed));
		if (StrEqual(weaponUsed, "weapon_deagle", false)) {
			dmg = 1000.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) {
	if (CurrentDay == Day_HideNSeek) {
		CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
		CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
		int hpDamage;
		int hpLeft;
		char weaponUsed[64];
		GetEventString(event, "weapon", weaponUsed, sizeof(weaponUsed));
		GetEventInt(event, "dmg_health", hpDamage);
		GetEventInt(event, "health", hpLeft);
		if (StrEqual(weaponUsed, "taser", false)) {
			attacker.Health += hpDamage / 2;
			victim.Speed = hpLeft / 100.0;
		}
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	CCSPlayer attacker = CCSPlayer.FromEvent(event, "attacker");
	CCSPlayer victim = CCSPlayer.FromEvent(event, "userid");
	char weaponUsed[60];
	GetEventString(event, "weapon", weaponUsed, sizeof(weaponUsed));
	if (CurrentDay == Day_OneInTheChamber) {
		CWeapon wep = attacker.GetWeapon(CS_SLOT_SECONDARY);
		wep.Ammo += 1;
	}
	if (CurrentDay == Day_HideNSeek) {
		if (GetTeamClientCount(CS_TEAM_T) > 1) {
			if (StrEqual(weaponUsed, "taser", false)) {
				victim.SwitchTeam(CS_TEAM_CT);
				attacker.Speed += 0.05;
				CreateTimer(1.0, Timer_RespawnHider, victim, TIMER_FLAG_NO_MAPCHANGE);
			}
			else {
				victim.SwitchTeam(CS_TEAM_CT);
			}
		}
		if (GetTeamClientCount(CS_TEAM_T) == 1) {
			CCSPlayer p;
			while (CCSPlayer.Next(p)) {
				if(p.Alive){
					if (CS_TEAM_T == p.Team) {
						GivePlayerWeapon(p, "weapon_mp5sd");
						GivePlayerWeapon(p, "weapon_usp_silencer");
						GivePlayerWeapon(p, "weapon_knife");
						p.Armor = true;
						p.Armor = 200;
						p.Speed = 2.5;
						p.Health = 200;
					} else if (CS_TEAM_CT == p.Team) {
						GivePlayerWeapon(p, "weapon_deagle");
						GivePlayerWeapon(p, "weapon_knife");
						p.Speed = 1.0;
					}
				}
			}
		}
	}
	if (StrEqual(weaponUsed, "revolver", false)) {
		CreateTimer(0.5, Timer_PlayBumpy, attacker, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void SpecialDay_Normal() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Normal Day\x01!");
}

public void SpecialDay_BigJug() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Fat Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			p.Health = 200;
			p.Armor = 200;
			p.HeavyArmor = true;
			p.Speed = 0.7;
			CWeapon wep;
			if ((wep = p.GetWeapon(CS_SLOT_PRIMARY)) != NULL_CWEAPON) {
				p.RemoveItem(wep);
				wep.Kill();
			}
		}
	}
}

public void SpecialDay_SnowballFight() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Snowball Fight\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	TimerGiveSnowballT = CreateTimer(1.0, Timer_GiveSnowballT, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TimerGiveSnowballCT = CreateTimer(1.0, Timer_GiveSnowballCT, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				CWeapon wep;
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			PlayerCount();
			p.Armor = false;
			if (TotalPlayers <= 6) {
				p.Health = 10;
			} else if (TotalPlayers <= 8) {
				p.Health = 15;
			} else if (TotalPlayers <= 12) {
				p.Health = 20;
			} else {
				p.Health = 25;
			}
		}
	}
}

public void SpecialDay_HideNSeek() {
	PlayerCount();
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	CreateTimer(60.0, Timer_SeekerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	TimerGiveTactNade = CreateTimer(90.0, Timer_GiveTactAware, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TimerPlayTaunt = CreateTimer(90.0, Timer_PlayTaunt, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TimerGiveSnowballT = CreateTimer(90.0, Timer_GiveSnowballT, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CCSPlayer randPlayers[64];
	CCSPlayer realPlayers[64];
	int chosenPlayers[64];
	int count = 0;
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			realPlayers[count] = p;
			count++;
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				CWeapon wep;
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
	int i = 0;
	int num;
	int numSeekers;
	if (TotalPlayers < 4) { numSeekers = 1;}
	if (TotalPlayers >= 4) { numSeekers = TotalPlayers / 4; }
	//PrintToChatAll("numSeekers: %d", numSeekers);
	//Random Players
	while (i < numSeekers) {
		num = GetRandomInt(0, TotalPlayers - 1);
		if (chosenPlayers[num] == 0) {
			chosenPlayers[num] = 1;
			randPlayers[i] = realPlayers[num];
			randPlayers[i].Speed = 0.0;
			randPlayers[i].SwitchTeam(CS_TEAM_CT);
			Handle hMsg = StartMessageOne("Fade", randPlayers[i++].Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
			PbSetInt(hMsg, "duration", 5000);
			PbSetInt(hMsg, "hold_time", 1500);
			PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
			PbSetColor(hMsg, "clr", { 0, 0, 0, 255 } );
			EndMessage();
		}
	}
	CCSPlayer player;
	while (CCSPlayer.Next(player)) {
		if (player.InGame && player.Alive) {
			SetEntProp(player.Index, Prop_Data, "m_takedamage", 0, 1);
			for (i = 0; i < numSeekers; i++) {
				if (randPlayers[i] != player) {
					player.SwitchTeam(CS_TEAM_T);
					player.Speed = 0.95;
					player.Armor = false;
				}
			}
		}
	}
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Hide N Seek\x01!");
	PrintToChatAll(XG_PREFIX_CHAT..."You have \x0C60 seconds \x01to hide!");
	PrintToChatAll(XG_PREFIX_CHAT..."Seekers: ");
	for (i = 0; i < numSeekers; i++) {
		char name[64];
		randPlayers[i].GetName(name, sizeof(name));
		PrintToChatAll(XG_PREFIX_CHAT..."%s", name);
	}
}

public void SpecialDay_HeThrow() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06HE Throw\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	TimerGiveHENade = CreateTimer(1.0, Timer_GiveHEGrenade, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				CWeapon wep;
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
}

public void SpecialDay_SanicSpeed() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Sanic Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			p.Speed = 3.0;
		}
	}
}

public void SpecialDay_LowGravity() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Low Gravity\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			p.Gravity = 0.2;
		}
	}
}

public void SpecialDay_Bumpy() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06R8 8/8 M8\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	int taunt = GetRandomInt(0, MAX_TAUNTS - 1);
	EmitSoundToAll(taunts[taunt]);
	TimerInfiniteR8 = CreateTimer(0.3, Timer_InfiniteR8, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CCSPlayer p;
	CWeapon wep;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
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

public void SpecialDay_OneInTheChamber() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06One In The Chamber\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	CCSPlayer p;
	CWeapon wep;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			GivePlayerWeapon(p, "weapon_knife");
			wep = GivePlayerWeapon(p, "weapon_revolver");
			wep.Ammo = 1;
			wep.ReserveAmmo = 0;
		}
	}
}

public void SpecialDay_ExoBump() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06ExoBump Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			for (int i = 0; i <= CS_SLOT_C4; i++) {
				CWeapon wep;
				while ((wep = p.GetWeapon(i)) != NULL_CWEAPON) {
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

public void SpecialDay_RiotShield() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Riot Shield Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			GivePlayerWeapon(p, "weapon_shield");
		}
	}
}

public void SpecialDay_ExoBoot() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06ExoBoot Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			SetEntProp(p.Index, Prop_Send, "m_passiveItems", 1, 1, 1);
		}
	}
}

public void SpecialDay_BumpMine() {
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Bumpy Mine Day\x01!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient && p.Alive) {
			GivePlayerWeapon(p, "weapon_bumpmine");
		}
	}
}

public Action Timer_GiveSnowballCT(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive && CS_TEAM_CT == p.Team) {
			if (p.GetWeapon(CS_SLOT_GRENADE).IsNull) { GivePlayerWeapon(p, "weapon_snowball"); }
		}
	}
}

public Action Timer_GiveSnowballT(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive && CS_TEAM_T == p.Team) {
			if (p.GetWeapon(CS_SLOT_GRENADE).IsNull) { GivePlayerWeapon(p, "weapon_snowball"); }
		}
	}
}

public Action Timer_GiveTactAware(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive && CS_TEAM_CT == p.Team) {
			if (p.GetWeapon(CS_SLOT_GRENADE).IsNull) { GivePlayerWeapon(p, "weapon_tagrenade"); }
		}
	}
}

public Action Timer_GiveHEGrenade(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			if (p.GetWeapon(CS_SLOT_GRENADE).IsNull) { GivePlayerWeapon(p, "weapon_hegrenade"); }
		}
	}
}

public Action Timer_SeekerStart(Handle timer) {
	PrintToChatAll(XG_PREFIX_CHAT..."\x02Ready or not here they come!");
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			SetEntProp(p.Index, Prop_Data, "m_takedamage", 2, 1);
			if (CS_TEAM_CT == p.Team) {
				p.Speed = 1.0;
				Handle hMsg = StartMessageOne("Fade", p.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
				PbSetInt(hMsg, "duration", 5000);
				PbSetInt(hMsg, "hold_time", 1500);
				PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
				PbSetColor(hMsg, "clr", { 0, 0, 0, 0 } );
				EndMessage();
				GivePlayerWeapon(p, "weapon_taser");
			}
		}
	}
}

public Action Timer_PlayTaunt(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive && CS_TEAM_T == p.Team) {
			float vec[3];
			GetClientAbsOrigin(p.Index, vec);
			vec[2] += 10;
			GetClientEyePosition(p.Index, vec);
			int taunt = GetRandomInt(0, MAX_TAUNTS - 1);
			EmitAmbientSound(taunts[taunt], vec, p.Index, SNDLEVEL_GUNFIRE);
		}
	}
}

public Action Timer_PlayBumpy(Handle timer, CCSPlayer attacker) {
	if (attacker.InGame && attacker.Alive) {
		float vec[3];
		GetClientAbsOrigin(attacker.Index, vec);
		vec[2] += 10;
		GetClientEyePosition(attacker.Index, vec);
		int taunt = GetRandomInt(0, MAX_TAUNTS - 1);
		EmitAmbientSound(taunts[taunt], vec, attacker.Index, SNDLEVEL_GUNFIRE);
	}
}

public Action Timer_RespawnHider(Handle timer, CCSPlayer victim) {
	victim.Respawn();
	victim.Speed = 1.0;
	for (int i = 0; i <= CS_SLOT_C4; i++) {
		CWeapon wep;
		while ((wep = victim.GetWeapon(i)) != NULL_CWEAPON) {
			victim.RemoveItem(wep);
			wep.Kill();
		}
	}
	GivePlayerWeapon(victim, "weapon_taser");
	if(GetTeamClientCount(CS_TEAM_T) == 1){
		GivePlayerWeapon(victim, "weapon_deagle");
	}
}

public Action Timer_InfiniteR8(Handle timer) {
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && p.Alive) {
			CWeapon wep = p.GetWeapon(CS_SLOT_SECONDARY);
			wep.Ammo = 8;
		}
	}
}

public void PlayerCount() {
	TotalPlayers = 0;
	CCSPlayer p;
	while (CCSPlayer.Next(p)) {
		if (p.InGame && !p.FakeClient) {
			TotalPlayers++;
		}
	}
}

public void RareEvents() {
	RareEventNum = GetRandomInt(1, 420);
	bool eventPick = false;
	FallEvent = false;
	NoGunEvent = false;
	while (!eventPick) {
		switch (RareEventNum) {
			case 181: {
				if (CurrentDay != Day_Snowball && CurrentDay != Day_HideNSeek && CurrentDay != Day_HEThrow && CurrentDay != Day_Bumpy && CurrentDay != Day_OneInTheChamber) {
					PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07No Buying'\x01!");
					GameRules_SetProp("m_bTCantBuy", true, _, _, true);
					GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
					NoGunEvent = true;
				}
				eventPick = true;
			}
			case 37: {
				if (CurrentDay != Day_HideNSeek) {
					PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07Double Speed\x01!");
					CCSPlayer p;
					while (CCSPlayer.Next(p)) {
						p.Speed *= 2;
					}
				}
				eventPick = true;
			}
			case 293: {
				if (CurrentDay != Day_HideNSeek) {
					PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07Everyone's Blind\x01!");
					CCSPlayer p;
					while (CCSPlayer.Next(p)) {
						Handle hMsg = StartMessageOne("Fade", p.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
						PbSetInt(hMsg, "duration", 5000);
						PbSetInt(hMsg, "hold_time", 1500);
						PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
						PbSetColor(hMsg, "clr", { 0, 0, 0, 255 } );
						EndMessage();
					}
				}
				eventPick = true;
			}
			case 132: {
				PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07Feather\x01!");
				CCSPlayer p;
				while (CCSPlayer.Next(p)) {
					p.Gravity = 0.2;
				}
				eventPick = true;
			}
			case 206: {
				PlayerCount();
				int count = 0;
				CCSPlayer allPlayers[64];
				CCSPlayer bigNoob;
				char bigNoobName[64];
				CCSPlayer player;
				while (CCSPlayer.Next(player)) {
					if (player.InGame && !player.FakeClient && player.Alive) {
						allPlayers[count] = player;
						count++;
					}
				}
				bigNoob = allPlayers[0];
				bigNoob.GetName(bigNoobName, sizeof(bigNoobName));
				for (int i = 1; i < TotalPlayers; i++) {
					if (allPlayers[i].Frags <= bigNoob.Frags) {
						bigNoob = allPlayers[i];
						bigNoob.GetName(bigNoobName, sizeof(bigNoobName));
					}
				}
				PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07Carrying %s\x01!", bigNoobName);
				CCSPlayer p;
				while (CCSPlayer.Next(p)) {
					p.Gravity *= 10;
					p.Speed *= 0.5;
				}
				eventPick = true;
			}
			case 400: {
				if (CurrentDay != Day_HideNSeek) {
					PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x071HP\x01!");
					CCSPlayer p;
					while (CCSPlayer.Next(p)) {
						p.Health = 1;
					}
				}
				eventPick = true;
			}
			case 368: {
				PrintToChatAll(XG_PREFIX_CHAT..."\x05Rare Event: \x07Don't Take Fall Damage!'\x01!");
				FallEvent = true;
				eventPick = true;
			}
			default: {
				eventPick = true;
			}
		}
	}
} 