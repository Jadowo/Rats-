#include <sourcemod>
#include <ccsplayer>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_AUTHOR "Jadow"
#define PLUGIN_VERSION "0.7"

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

public void OnPluginStart(){
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	
}

Handle snowballtimerct;
Handle snowballtimert;
Handle hetimer;
Handle tacttimer;
Handle unfreezect;
public void OnMapStart(){
	// When setting Heavy Armor, model is changed.
	PrecacheModel("models/player/custom_player/legacy/ctm_heavy.mdl");
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl");
	ServerCommand("mp_taser_recharge_time 1.5");
	ServerCommand("mp_limitteams 30");
}

public Action Event_RoundStart(Event event, const char[] sName, bool bDontBroadcast){
	int ratdaynum = GetRandomInt(1,100);
	//Normal
	if(ratdaynum >= 1 && ratdaynum <= 30){
		ServerCommand("mp_autoteambalance 1");
		RatDay_Normal();
	}
	//BigJug
	else if(ratdaynum >= 31 && ratdaynum <= 40){
		ServerCommand("mp_autoteambalance 1");
		RatDay_BigJug();
	}
	//Snowball
	else if(ratdaynum >= 41 && ratdaynum <= 50){
		ServerCommand("mp_autoteambalance 1");
		RatDay_SnowballFight();
	}
	//HideNSeek
	else if(ratdaynum >= 51 && ratdaynum <= 60){
		if(GetClientCount(true)>=4){
		ServerCommand("mp_autoteambalance 1");
		RatDay_HideNSeek();
		}
		else{
			PrintToChatAll(XG_PREFIX_CHAT_ALERT..."Not enough players for HideNSeek!");
			RatDay_Normal();
		}
	}
	//HeThrow
	else if(ratdaynum >= 61 && ratdaynum <= 70){
		ServerCommand("mp_autoteambalance 1");
		RatDay_HeThrow();
	}
	//SanicSpeed
	else if(ratdaynum >= 71 && ratdaynum <= 80){
		ServerCommand("mp_autoteambalance 1");
		RatDay_SanicSpeed();
	}
	//LowGrav
	else if(ratdaynum >= 81 && ratdaynum <=90){
		ServerCommand("mp_autoteambalance 1");
		RatDay_LowGrav();
	}
	else if(ratdaynum >= 91){
		ServerCommand("mp_autoteambalance 1");
		RatDay_Bumpy();
	}
}

public Action Event_RoundEnd(Event event, const char[] sName, bool bDontBroadcast){
	if(snowballtimerct != null){
		delete snowballtimerct;
	}
	if(unfreezect != null){
		delete unfreezect;
	}
	if(snowballtimert != null){
		delete snowballtimert;
	}
	if(tacttimer != null){
		delete tacttimer;
	}
	if(hetimer != null){
		delete hetimer;
	}
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		p.HeavyArmor = false;
	}
}


public void RatDay_Normal(){
	PrintToChatAll(XG_PREFIX_CHAT..."Normal Day!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		p.Money = 10000;
	}
}

public void RatDay_BigJug(){
	PrintToChatAll(XG_PREFIX_CHAT..."Big Jug!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		char sModel[PLATFORM_MAX_PATH];
		char sHand[PLATFORM_MAX_PATH];
		p.GetPropString(Prop_Send, "m_szArmsModel", sHand, sizeof(sHand));
		p.GetModel(sModel, sizeof(sModel));
		p.HeavyArmor = true;
		p.Armor = 200;
		p.Speed = 0.5;
		p.SetModel(sModel);
		p.SetPropString(Prop_Send, "m_szArmsModel", sHand);
		p.Money = 10000;
	}
}

public void RatDay_SnowballFight(){
	PrintToChatAll(XG_PREFIX_CHAT..."Snowball Fight!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame){
			for(int i = 0; i <= CS_SLOT_C4;i++){
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
	snowballtimert = CreateTimer(2.0, TimerGiveSnowballT, _, TIMER_REPEAT);
	snowballtimerct = CreateTimer(2.0, TimerGiveSnowballCT, _, TIMER_REPEAT);
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
	
}

public void RatDay_HideNSeek(){
	PrintToChatAll(XG_PREFIX_CHAT..."Hide N Seek!");
	ServerCommand("mp_autoteambalance 0");
	int[] ranplayers = new int[GetClientCount(true)];
	int[] otherplayers = new int[GetClientCount(true)];
	int i, chosen, l;
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame){
			for(int ix = 0; ix <= CS_SLOT_C4;ix++){
				CWeapon wep;
				while((wep = p.GetWeapon(ix)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
	//Get Random Players
	for (i = 1; i <= GetClientCount(true)/4; i++){
		ranplayers[i] = GetRandomInt(1, GetClientCount(true));
		for (chosen = i; chosen > 0; chosen--){
			if(ranplayers[chosen] == ranplayers[i]){
				ranplayers[i] = GetRandomInt(1, GetClientCount(true));
				char buf[50];
				GetClientName(ranplayers[i], buf, sizeof(buf));
				PrintToChatAll(XG_PREFIX_CHAT..."Seekers: %s", buf);
				CCSPlayer player = CCSPlayer(ranplayers[chosen]);
				SetEntPropFloat(ranplayers[chosen], Prop_Data, "m_flLaggedMovementValue", 0.0);
				SetEntProp(ranplayers[chosen], Prop_Data, "m_takedamage", 0, 1);
				PrintToChatAll(XG_PREFIX_CHAT_ALERT..."You have 60 seconds to hide!");
				unfreezect = CreateTimer(65.0, TimerUnfreezeCT, GetClientUserId(ranplayers[chosen]));
				//ServerCommand("sm_blind @ct 255");
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
	//2 is Terrorist
	//3 is Counter_Terrorist
	for (l = 1; l <= MAXPLAYERS; l++){
		otherplayers[l] = l;
		char buf[50];
		char buf2[50];
		GetClientName(otherplayers[l], buf, sizeof(buf));
		//PrintToChatAll(XG_PREFIX_CHAT..."Players: %s", buf);
		for (chosen = GetClientCount(true) / 2; chosen > 0; chosen--){
			GetClientName(ranplayers[chosen], buf2, sizeof(buf2));
			//PrintToChatAll(XG_PREFIX_CHAT..."Chosen Players: %s", buf2);
			if(otherplayers[l] != ranplayers[chosen]){
				CCSPlayer player = CCSPlayer(otherplayers[l]);
				player.Speed = 0.9;
				player.SwitchTeam(2);
				for(int ix = 0; ix <= CS_SLOT_C4;ix++){
					CWeapon wep;
					while((wep = p.GetWeapon(ix)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				GivePlayerWeapon(player, "weapon_flashbang");
				GivePlayerWeapon(player, "weapon_decoy");
			}
		}
	}
	snowballtimert = CreateTimer(5.0, TimerGiveSnowballT, _, TIMER_REPEAT);
	tacttimer = CreateTimer(45.0, TimerGiveTactAware, _, TIMER_REPEAT);
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
}

public void RatDay_HeThrow(){
	PrintToChatAll(XG_PREFIX_CHAT..."HE Throw!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame){
			for(int i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
	}
	hetimer = CreateTimer(1.5, TimerGiveHEGrenade, _, TIMER_REPEAT);
	GameRules_SetProp("m_bTCantBuy", true, _, _, true);
	GameRules_SetProp("m_bCTCantBuy", true, _, _, true);
}

public void RatDay_SanicSpeed(){
	PrintToChatAll(XG_PREFIX_CHAT..."Sanic Speed!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		p.Speed = 3.0;
		p.Money = 10000;
	}
}

public void RatDay_LowGrav(){
	PrintToChatAll(XG_PREFIX_CHAT..."Low Gravity!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		p.Gravity = 0.2;
		p.Money = 10000;
	}
}

public void RatDay_Bumpy(){
	PrintToChatAll(XG_PREFIX_CHAT..."Bumpy!");
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.InGame){
			for(int ix = 0; ix <= CS_SLOT_C4;ix++){
				CWeapon wep;
				while((wep = p.GetWeapon(ix)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
		}
		CWeapon wep = GivePlayerWeapon(p, "weapon_revolver");
		wep.Ammo = 6969;
		wep.ReserveAmmo = 0;
	}
}
	
public Action TimerGiveSnowballCT(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(CS_TEAM_CT == p.Team){
			if(p.Alive){
				for(int i = 0; i <= CS_SLOT_C4;i++){
					CWeapon wep;
					while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action TimerGiveSnowballT(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(CS_TEAM_T == p.Team){
			if(p.Alive){
				for(int i = 0; i <= CS_SLOT_C4;i++){
					CWeapon wep;
					while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
						p.RemoveItem(wep);
						wep.Kill();
					}
				}
				GivePlayerWeapon(p, "weapon_snowball");
			}
		}
	}
}

public Action TimerGiveTactAware(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(CS_TEAM_CT == p.Team){
			if(p.GetWeapon(CS_SLOT_GRENADE).IsNull){
				GivePlayerWeapon(p, "weapon_tagrenade");
			}
		}
	}
}

public Action TimerUnfreezeCT(Handle timer, any userid){
	PrintToChatAll(XG_PREFIX_CHAT..."Ready or not here they come!");
	int client = GetClientOfUserId(userid);
	CCSPlayer player = CCSPlayer(client);
	Handle hMsg = StartMessageOne("Fade", player.Index, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
	PbSetInt(hMsg, "duration", 5000);
	PbSetInt(hMsg, "hold_time", 1500);
	PbSetInt(hMsg, "flags", 0x0008 | 0x0010);
	PbSetColor(hMsg, "clr", {0, 0, 0, 0});
	EndMessage();
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(CS_TEAM_CT == p.Team){
			GivePlayerItem(client, "weapon_taser");
		}
	}
}

public Action TimerGiveHEGrenade(Handle timer, any client){
	CCSPlayer p = CCSPlayer(0);
	while(CCSPlayer.Next(p)){
		if(p.Alive){
			for(int i = 0; i <= CS_SLOT_C4;i++){
				CWeapon wep;
				while((wep = p.GetWeapon(i)) != NULL_CWEAPON){
					p.RemoveItem(wep);
					wep.Kill();
				}
			}
			GivePlayerWeapon(p, "weapon_hegrenade");
		}
	}
}