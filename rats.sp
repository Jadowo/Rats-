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
Handle stripprimary;
Handle stripsecondary;
ConVar autobalance;
ConVar taserrecharge;
ConVar roundtime;
ConVar defuseroundtime;
ConVar hostageroundtime;
ConVar freezetime;
int ratdaynum;
int ratday;
bool firstround;
bool forceday;
char dayname[64];

public void OnPluginStart(){
	RegAdminCmd("sm_forceday", Command_ForceDay, ADMFLAG_ROOT);
	RegAdminCmd("sm_fd", Command_ForceDay, ADMFLAG_ROOT);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
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
	freezetime.IntValue = 5;
	autobalance.IntValue = 1;
}

//2 is Terrorist
//3 is Counter_Terrorist

public Action Command_ForceDay(int client, int args){
	Menu menu = new Menu(Menu_ForceDay);
	menu.SetTitle("Force Day");
	menu.AddItem("normal", "Normal");
	menu.AddItem("bigjug", "Fat");
	menu.AddItem("snowball", "SnowballFight");
	menu.AddItem("hidenseek", "HideNSeek");
	menu.AddItem("hethrow", "HE Throw");
	menu.AddItem("sanic", "Sanic Speed");
	menu.AddItem("lowgrav", "Low Gravity");
	menu.AddItem("bumpy", "R8 8/8");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_ForceDay(Menu menu, MenuAction action, int client, int itemNum){
	if (action == MenuAction_Select){
		char info[32], display[64];
		menu.GetItem(itemNum, info, sizeof(info), _, display, sizeof(display));
		if (StrEqual(info, "normal")){
			ratday = 1;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Normal Day\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "bigjug")){
			ratday = 8;
			ratdaynum = 1;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Fat Day\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "snowball")){
			ratday = 8;
			ratdaynum = 2;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Snowball Fight\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "hidenseek")){
			ratday = 8;
			ratdaynum = 3;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Hide N Seek\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "hethrow")){
			ratday = 8;
			ratdaynum = 4;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06He Throw\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "sanic")){
			ratday = 8;
			ratdaynum = 5;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Sanic Day\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "lowgrav")){
			ratday = 8;
			ratdaynum = 6;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Low Gravity Day\x01.");
			forceday = true;
		}
		else if (StrEqual(info, "bumpy")){
			ratday = 8;
			ratdaynum = 7;
			PrintToChatAll(XG_PREFIX_CHAT..."Next Day \x02forced \x01to \x06Bumpy Day\x01.");
			forceday = true;
		}
	}
	else if (action == MenuAction_End){
		delete menu;
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontbroadcast){
	ratday = GetRandomInt(1, 10);
	ratdaynum = GetRandomInt(1, 7);
	if(firstround){
		ratdaynum = 1;
		firstround = false;
	}
	if(ratday <= 7){
		autobalance.IntValue = 1;
		dayname = "normal";
		RatDay_Normal();
	}
	else if(ratday >= 8){
		//1 BigJug 
		if(ratdaynum == 1){
			autobalance.IntValue = 1;
			dayname = "bigjug";
			RatDay_BigJug();
		}
		//2 Snowball Fight
		else if(ratdaynum == 2){
			autobalance.IntValue = 1;
			dayname = "snowball";
			RatDay_SnowballFight();
		}
		//3 HideNSeek
		else if(ratdaynum == 3){
			if(GetClientCount(true)>=4){
				autobalance.IntValue = 0;
				dayname = "hide";
				RatDay_HideNSeek();
			}
			else{
				PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Not enough \x02players \x01for \x06Hide N Seek\x01!");
				autobalance.IntValue = 1;
				dayname = "normal";
				RatDay_Normal();
			}
		}
		//4 HEThrow
		else if(ratdaynum == 4){
			autobalance.IntValue = 1;
			dayname = "he";
			RatDay_HeThrow();
		}
		//5 SanicSpeed
		else if(ratdaynum == 5){
			autobalance.IntValue = 1;
			dayname = "sanic";
			RatDay_SanicSpeed();
		}
		//6 LowGrav
		else if(ratdaynum == 6){
			autobalance.IntValue = 1;
			dayname = "lowgrav";
			RatDay_LowGrav();
		}
		//7 Bumpy
		else if(ratdaynum == 7){
			autobalance.IntValue = 1;
			dayname = "bumpy";
			RatDay_Bumpy();
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontbroadcast){
	Stop_Timers();
	if(forceday){
		ratday = GetRandomInt(1,10);
	}
	else if(forceday){
		forceday = false;
	}
	//Check for days that don't need to use buymenu
	if((ratdaynum >= 2 && ratdaynum <= 4) || ratdaynum == 7){
		freezetime.IntValue = 0;
	}
	else{
		freezetime.IntValue = 5;
	}
	CCSPlayer p = CCSPlayer(0);
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
		}
		else{
			victim.Health += hpdamage/2;
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
				victim.SwitchTeam(3);
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
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Money = 10000;
		}
	}
}

public void RatDay_BigJug(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Fat Day\x01!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_PRIMARY);
			p.RemoveItem(wep);
			wep.Kill();
			char sModel[PLATFORM_MAX_PATH];
			char sHand[PLATFORM_MAX_PATH];
			p.GetPropString(Prop_Send, "m_szArmsModel", sHand, sizeof(sHand));
			p.GetModel(sModel, sizeof(sModel));
			p.HeavyArmor = true;
			p.Health = 200;
			p.Armor = 200;
			p.Speed = 0.7;
			p.SetModel(sModel);
			p.SetPropString(Prop_Send, "m_szArmsModel", sHand);
			p.Money = 10000;
		}
	}
}

public void RatDay_SnowballFight(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Snowball Fight\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	stripprimary = CreateTimer(1.0, Timer_StripPrimary, _, TIMER_REPEAT);
	stripsecondary = CreateTimer(1.0, Timer_StripSecondary, _, TIMER_REPEAT);
	snowballtimert = CreateTimer(1.0, Timer_GiveSnowballT, _, TIMER_REPEAT);
	snowballtimerct = CreateTimer(1.0, Timer_GiveSnowballCT, _, TIMER_REPEAT);
	CCSPlayer p = CCSPlayer(0);
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
	stripprimary = CreateTimer(1.0, Timer_StripPrimary, _, TIMER_REPEAT);
	stripsecondary = CreateTimer(1.0, Timer_StripSecondary, _, TIMER_REPEAT);
	tacttimer = CreateTimer(90.0, Timer_GiveTactAware, _, TIMER_REPEAT);
	snowballtimert = CreateTimer(60.0, Timer_GiveSnowballT,_, TIMER_REPEAT);
	unfreezect = CreateTimer(60.0, Timer_SeekerStart);
	playtaunt = CreateTimer(60.0, Timer_Taunt, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll(XG_PREFIX_CHAT_ALERT..."You have \x0C60 seconds \x01to hide!");
	CCSPlayer[] ranplayers = new CCSPlayer[GetClientCount(true)];
	//Random Players
	int i, l, chosen;
	for (i = 1; i <= GetClientCount(true)/3; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true)/3; l++){
				ranplayers[l] = CCSPlayer(GetRandomInt(1, GetClientCount(true)));
				char buf[50];
				GetClientName(ranplayers[l].Index, buf, sizeof(buf));
				for (chosen = l; chosen > 1; chosen--){
					if(ranplayers[chosen] == ranplayers[l]){
						ranplayers[l] = CCSPlayer(GetRandomInt(1, GetClientCount(true)));
					}
				}
				GetClientName(ranplayers[l].Index, buf, sizeof(buf));
				PrintToChatAll(XG_PREFIX_CHAT..."Seekers: %s", buf);
				SetEntPropFloat(ranplayers[l].Index, Prop_Data, "m_flLaggedMovementValue", 0.0);
				Handle hMsg = StartMessageOne("Fade", ranplayers[l].Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
				PbSetInt(hMsg, "duration", 5000);
				PbSetInt(hMsg, "hold_time", 1500);
				PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
				PbSetColor(hMsg, "clr", {0, 0, 0, 255});
				EndMessage();
				ranplayers[l].SwitchTeam(3);
			}
		}
	}
	CCSPlayer p = CCSPlayer(0);
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
			i = 1;
			while(i <= GetClientCount(true)/2){
				if(p != ranplayers[i]){
					p.SwitchTeam(2);
					p.Speed = 0.9;
				}
				i++;
			}
		}
	}
}

public void RatDay_HeThrow(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06HE Throw\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true); 
	stripprimary = CreateTimer(1.0, Timer_StripPrimary, _, TIMER_REPEAT);
	stripsecondary = CreateTimer(1.0, Timer_StripSecondary, _, TIMER_REPEAT);
	hetimer = CreateTimer(1.0, Timer_GiveHEGrenade, _, TIMER_REPEAT);
	CCSPlayer p = CCSPlayer(0);
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
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Speed = 3.0;
			p.Money = 10000;
		}
	}
}

public void RatDay_LowGrav(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06Low Gravity\x01!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			p.Gravity = 0.2;
			p.Money = 10000;
		}
	}
}

public void RatDay_Bumpy(){
	PrintToChatAll(XG_PREFIX_CHAT..."\x06R8 8/8 M8\x01!");
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	stripprimary = CreateTimer(1.0, Timer_StripPrimary, _, TIMER_REPEAT);
	EmitSoundToAll("rats/bumpybumpy.mp3");
	infiniter8 = CreateTimer(0.0, Timer_InfiniteR8, _, TIMER_REPEAT);
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			for(int i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			CWeapon wep = GivePlayerWeapon(p, "weapon_revolver");
			wep.Ammo = 8;
			wep.ReserveAmmo = 0;
		}
	}
}

public Action Timer_GiveSnowballCT(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action Timer_GiveSnowballT(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_T == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action Timer_GiveTactAware(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_tagrenade");
			}
		}
	}
}

public Action Timer_GiveHEGrenade(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive && CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_hegrenade");
			}
		}
	}
}

public Action Timer_SeekerStart(Handle timer, any client){
	PrintToChatAll(XG_PREFIX_CHAT..."\x02Ready or not here they come!");
	CCSPlayer p = CCSPlayer(0);
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

public Action Timer_Taunt(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
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
	for(int i = 0; i <= CS_SLOT_C4;i++){
		CWeapon wep;
		while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
			p.RemoveItem(wep);
			wep.Kill();
		}
	}
	GivePlayerWeapon(p, "weapon_taser");
}

public Action Timer_InfiniteR8(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_SECONDARY);
			wep.Ammo = 8;
		}
	}
}

public Action Timer_StripPrimary(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_PRIMARY);
			p.RemoveItem(wep);
			wep.Kill();
		}
	}
}

public Action Timer_StripSecondary(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame && !p.FakeClient && p.Alive){
			CWeapon wep = p.GetWeapon(CS_SLOT_SECONDARY);
			p.RemoveItem(wep);
			wep.Kill();
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
	if(stripprimary != null){
		delete stripprimary;
	}
	if(stripsecondary != null){
		delete stripsecondary;
	}
}