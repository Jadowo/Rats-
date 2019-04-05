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
Handle playbumpy;
Handle hetimer;
Handle tacttimer;
Handle unfreezect;
ConVar autobalance;
ConVar taserrecharge;
ConVar roundtime;
ConVar defuseroundtime;
ConVar hostageroundtime;
ConVar freezetime;
int ratdaynum;
bool firstround;
bool forceday;

public void OnPluginStart(){
	RegAdminCmd("sm_forceday", Command_ForceDay, ADMFLAG_ROOT);
	RegAdminCmd("sm_fd", Command_ForceDay, ADMFLAG_ROOT);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
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
}

public Action Command_ForceDay(int client, int args){
	Menu menu = new Menu(Menu_ForceDay);
	menu.SetTitle("Force Day");
	menu.AddItem("normal", "Normal");
	menu.AddItem("bigjug", "BigJug");
	menu.AddItem("snowball", "SnowballFight");
	menu.AddItem("hidenseek", "HideNSeek");
	menu.AddItem("hethrow", "HE Throw");
	menu.AddItem("sanic", "Sanic Speed");
	menu.AddItem("lowgrav", "Low Gravity");
	menu.AddItem("bumpy", "Bumpy");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_ForceDay(Menu menu, MenuAction action, int client, int itemNum){
	if (action == MenuAction_Select){
		char info[32], display[64];
		menu.GetItem(itemNum, info, sizeof(info), _, display, sizeof(display));
		if (StrEqual(info, "normal")){
			ratdaynum = 1;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be a Normal Day");
			forceday = true;
		}
		else if (StrEqual(info, "bigjug")){
			ratdaynum = 31;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be BigJug Day");
			forceday = true;
		}
		else if (StrEqual(info, "snowball")){
			ratdaynum = 41;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be Snowball Fight");
			forceday = true;
		}
		else if (StrEqual(info, "hidenseek")){
			ratdaynum = 51;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be Hide N Seek");
			forceday = true;
		}
		else if (StrEqual(info, "hethrow")){
			ratdaynum = 61;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be He Throw");
			forceday = true;
		}
		else if (StrEqual(info, "sanic")){
			ratdaynum = 71;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be Sanic Day");
			forceday = true;
		}
		else if (StrEqual(info, "lowgrav")){
			ratdaynum = 81;
			PrintToChat(client, XG_PREFIX_CHAT..."Next Day will be Low Gravity Day");
			forceday = true;
		}
		else if (StrEqual(info, "bumpy")){
			ratdaynum = 91;
			PrintToChat(client, XG_PREFIX_CHAT..."Bumpy Bumpy");
			forceday = true;
		}
	}
	else if (action == MenuAction_End){
		delete menu;
	}
}

public Action Event_RoundStart(Event event, const char[] sName, bool bDontBroadcast){
	if(firstround){
		ratdaynum = GetRandomInt(1,30);
		firstround = false;
	}
	//Normal
	if(ratdaynum >= 1 && ratdaynum <= 30){
		autobalance.IntValue = 1;
		RatDay_Normal();
	}
	//BigJug
	else if(ratdaynum >= 31 && ratdaynum <= 40){
		autobalance.IntValue = 1;
		RatDay_BigJug();
	}
	//Snowball Fight
	else if(ratdaynum >= 41 && ratdaynum <= 50){
		autobalance.IntValue = 1;
		RatDay_SnowballFight();
	}
	//HideNSeek
	else if(ratdaynum >= 51 && ratdaynum <= 60){
		if(GetClientCount(true)>=0){
			autobalance.IntValue = 0;
			RatDay_HideNSeek();
		}
		else{
			PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Not enough players for HideNSeek!");
			autobalance.IntValue = 1;
			RatDay_Normal();
		}
	}
	//HEThrow
	else if(ratdaynum >= 61 && ratdaynum <= 70){
		autobalance.IntValue = 1;
		RatDay_HeThrow();
	}
	//SanicSpeed
	else if(ratdaynum >= 71 && ratdaynum <= 80){
		autobalance.IntValue = 1;
		RatDay_SanicSpeed();
	}
	//LowGrav
	else if(ratdaynum >= 81 && ratdaynum <=90){
		autobalance.IntValue = 1;
		RatDay_LowGrav();
	}
	//Bumpy
	else if(ratdaynum >= 91){
		autobalance.IntValue = 1;
		RatDay_Bumpy();
	}
}

public Action Event_RoundEnd(Event event, const char[] sName, bool bDontBroadcast){
	if(!forceday){
		//PrintToChatAll("Random Day %d", ratdaynum);
		ratdaynum = GetRandomInt(1,100);
	}
	else if(forceday){
		//PrintToChatAll("Force Day %d", ratdaynum);
		forceday = false;
	}
	//Check if HideNSeek
	if(ratdaynum >= 51 && ratdaynum <= 60){
		freezetime.IntValue = 0;
	}
	//Check if Snowball Fight
	else if(ratdaynum >= 41 && ratdaynum <= 50){
		freezetime.IntValue = 0;
	}
	//Check if HE Throw
	else if(ratdaynum >= 61 && ratdaynum <= 70){
		freezetime.IntValue = 0;
	}
	else if(ratdaynum >= 91){
		freezetime.IntValue = 0;
	}
	else{
		freezetime.IntValue = 5;
	}
	Stop_Timers();
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				p.HeavyArmor = false;
			}
		}
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	//Nothing for now
}

public void RatDay_Normal(){
	PrintToChatAll(XG_PREFIX_CHAT..."Normal Day!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				p.Money = 10000;
			}
		}
	}
}

public void RatDay_BigJug(){
	PrintToChatAll(XG_PREFIX_CHAT..."Big Jug!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				for(i = 0; i <= CS_SLOT_PRIMARY;i++){
					CWeapon wep;
					while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				char sModel[PLATFORM_MAX_PATH];
				char sHand[PLATFORM_MAX_PATH];
				p.GetPropString(Prop_Send, "m_szArmsModel", sHand, sizeof(sHand));
				p.GetModel(sModel, sizeof(sModel));
				p.HeavyArmor = true;
				p.Health = 200;
				p.Armor = 200;
				p.Speed = 0.5;
				p.SetModel(sModel);
				p.SetPropString(Prop_Send, "m_szArmsModel", sHand);
				p.Money = 10000;
			}
		}
	}
}

public void RatDay_SnowballFight(){
	PrintToChatAll(XG_PREFIX_CHAT..."Snowball Fight!");
	snowballtimert = CreateTimer(1.0, TimerGiveSnowballT, _, TIMER_REPEAT);
	snowballtimerct = CreateTimer(1.0, TimerGiveSnowballCT, _, TIMER_REPEAT);
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				for(i = 0; i <= CS_SLOT_C4;i++){
					CWeapon wep;
					while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				p.Health = 25;
				p.Armor = false;
			}
		}
	}
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
}

public void RatDay_HideNSeek(){
	PrintToChatAll(XG_PREFIX_CHAT..."Hide N Seek!");
	int i, chosen, l;
	int[] allplayers = new int[GetClientCount(true)];
	int[] ranplayers = new int[GetClientCount(true)];
	tacttimer = CreateTimer(90.0, TimerGiveTactAware, _, TIMER_REPEAT);
	snowballtimert = CreateTimer(60.0, TimerGiveSnowballT,_, TIMER_REPEAT);
	PrintToChatAll(XG_PREFIX_CHAT_ALERT..."You have 60 seconds to hide!");
	//2 is Terrorist
	//3 is Counter_Terrorist
	//Get Random Players
	for (i = 1; i <= GetClientCount(true); i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true)/4; l++){
				ranplayers[l] = GetClientUserId(GetRandomInt(1, GetClientCount(true)));
				for (chosen = l; chosen > 0; chosen--){
					if(l>1){
						if(ranplayers[chosen] == ranplayers[l]){
							ranplayers[l] = GetClientUserId(GetRandomInt(1, GetClientCount(true)));
						}
					}
					int client = GetClientOfUserId(ranplayers[l]);
					CCSPlayer player = CCSPlayer(client);
					char buf[50];
					GetClientName(client, buf, sizeof(buf));
					PrintToChatAll(XG_PREFIX_CHAT..."Seekers: %s", buf);
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					unfreezect = CreateTimer(5.0, TimerUnfreezeCT, client);
					Handle hMsg = StartMessageOne("Fade", player.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
					PbSetInt(hMsg, "duration", 5000);
					PbSetInt(hMsg, "hold_time", 1500);
					PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
					PbSetColor(hMsg, "clr", {0, 0, 0, 255});
					EndMessage();
					player.SwitchTeam(3);
				}
			}
		}
	}
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer player = CCSPlayer(client);
				if(player.Team == CS_TEAM_T)
				playbumpy = CreateTimer(60.0, Timer_Locate, player.Index, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				for(i = 0; i <= CS_SLOT_C4;i++){
					CWeapon wep;
					while((wep = player.GetWeapon(i)) != NULL_CWEAPON){
						player.RemoveItem(wep);
						wep.Kill();
					}
				}
				for (chosen = 1; chosen <= GetClientCount(true)/4; chosen++){
					if(allplayers[l] != ranplayers[chosen]){
						player.Speed = 0.9;
						player.SwitchTeam(2);
					}
				}
			}
		}
	}
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
}

public void RatDay_HeThrow(){
	PrintToChatAll(XG_PREFIX_CHAT..."HE Throw!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				if(p.InGame){
					for(i = 0; i <= CS_SLOT_C4;i++){
						CWeapon wep;
						while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
							p.RemoveItem(wep);
							wep.Kill();
						}
					}
				}
			}
		}
	}
	hetimer = CreateTimer(1.0, TimerGiveHEGrenade, _, TIMER_REPEAT);
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
}

public void RatDay_SanicSpeed(){
	PrintToChatAll(XG_PREFIX_CHAT..."Sanic Day!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				p.Speed = 3.0;
				p.Money = 10000;
			}
		}
	}
}

public void RatDay_LowGrav(){
	PrintToChatAll(XG_PREFIX_CHAT..."Low Gravity!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				p.Gravity = 0.2;
				p.Money = 10000;
			}
		}
	}
}

public void RatDay_Bumpy(){
	PrintToChatAll(XG_PREFIX_CHAT..."Bumpy!");
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int client = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(client);
				for(i = 0; i <= CS_SLOT_C4;i++){
					CWeapon wep;
					while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				CWeapon wep = GivePlayerWeapon(p, "weapon_revolver");
				wep.Ammo = 6969;
				wep.ReserveAmmo = 0;
			}
		}
	}
}

public Action TimerGiveSnowballCT(Handle timer, any client){
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int player = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(player);
				if(CS_TEAM_CT == p.Team){
					if(p.Alive){
						if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
							GivePlayerWeapon(p, "weapon_snowball");
						}
					}
				}
			}
		}
	}
}

public Action TimerGiveSnowballT(Handle timer, any client){
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int player = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(player);
				if(CS_TEAM_T == p.Team){
					if(p.Alive){
						if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
							GivePlayerWeapon(p, "weapon_snowball");
						}
					}
				}
			}
		}
	}
}

public Action TimerGiveTactAware(Handle timer, any client){
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int player = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(player);
				if(CS_TEAM_CT == p.Team){
					if(p.Alive){
						if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
							GivePlayerWeapon(p, "weapon_tagrenade");
						}
					}
				}
			}
		}
	}
}

public Action TimerGiveHEGrenade(Handle timer, any client){
	int i, l;
	int[] allplayers = new int[GetClientCount(true)];
	for (i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			for (l = 1; l <= GetClientCount(true); l++){
				allplayers[l] = GetClientUserId(i);
				int player = GetClientOfUserId(allplayers[l]);
				CCSPlayer p = CCSPlayer(player);
				if(p.Alive){
					if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
						GivePlayerWeapon(p, "weapon_hegrenade");
					}
				}
			}
		}
	}
}

public Action TimerUnfreezeCT(Handle timer, any client){
	PrintToChatAll(XG_PREFIX_CHAT..."Ready or not here they come!");
	CCSPlayer player = CCSPlayer(client);
	Handle hMsg = StartMessageOne("Fade", player.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
	PbSetInt(hMsg, "duration", 5000);
	PbSetInt(hMsg, "hold_time", 1500);
	PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
	PbSetColor(hMsg, "clr", {0, 0, 0, 0});
	EndMessage();
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	for (int i = 1; i <= MAXPLAYERS; i++){
		if(IsClientInGame(i) && !IsFakeClient(i)){
			if(CS_TEAM_CT == player.Team){
				GivePlayerItem(client, "weapon_taser");
			}
		}
	}
}

public Action Timer_Locate(Handle timer, any client){
	if (IsClientInGame(client) && IsPlayerAlive(client) && 0 < client <= MaxClients && GetClientTeam(2)){
		float vec[3];
		GetClientAbsOrigin(client, vec);
		vec[2] += 10;
		GetClientEyePosition(client, vec);
		int taunt = GetRandomInt(1, 13);
		if(taunt == 1){
			EmitAmbientSound("rats/bumpybumpy.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 2){
			EmitAmbientSound("rats/bb2.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 3){
			EmitAmbientSound("rats/bb3.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 4){
			EmitAmbientSound("rats/bb4.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 5){
			EmitAmbientSound("rats/bb5.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 6){
			EmitAmbientSound("rats/bb6.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 7){
			EmitAmbientSound("rats/bb7.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 8){
			EmitAmbientSound("rats/bb8.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 9){
			EmitAmbientSound("rats/bb9.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 10){
			EmitAmbientSound("rats/bb10.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 11){
			EmitAmbientSound("rats/bb11.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 12){
			EmitAmbientSound("rats/bb12.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
		else if(taunt == 13){
			EmitAmbientSound("rats/bb13.mp3", vec, client, SNDLEVEL_SCREAMING);
		}
	}
}

public Action Stop_Timers(){
	if(snowballtimerct != null){
		delete snowballtimerct;
		//PrintToChatAll("SnowballCTDeleted");
	}
	if(snowballtimert != null){
		delete snowballtimert;
		//PrintToChatAll("SnowballTDeleted");
	}
	if(unfreezect != null){
		delete unfreezect;
		//PrintToChatAll("UnFreezeCTDeleted");
	}
	if(tacttimer != null){
		delete tacttimer;
		//PrintToChatAll("TactTimerDeleted");
	}
	if(hetimer != null){
		delete hetimer;
		//PrintToChatAll("HEDeleted");
	}
	if(playbumpy != null){
		delete playbumpy;
		//PrintToChatAll("BumpyDeleted");
	}
}