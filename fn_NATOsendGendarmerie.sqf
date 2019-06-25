private _town = _this;
private _townPos = server getVariable _town;

private _stability = server getVariable format["stability%1",_town];
private _region = server getVariable [format["region_%1",_town],"fake_region"];

private _police = [];
private _support = [];
private _groups = [];

params ["_weapon","_magazine","_base"];

private _close = nil;
private _dist = 8000;
private _closest = "";
private _abandoned = server getVariable["NATOabandoned",[]];
private _attacking = server getVariable["NATOattacking",""];
{
	_pos = _x select 0;
	_name = _x select 1;
	_garrison = server getVariable[format["garrison%1",_name],0];
	if(_name != _attacking) then {
		if(([_pos,_townPos] call OT_fnc_regionIsConnected) && !(_name in _abandoned)) then {
			_d = (_pos distance _townPos);
			if(_d < _dist) then {
				_dist = _d;
				_close = _pos;
				_closest = _name;
			};
		};
	};
}foreach(OT_NATOobjectives);

if(!isNil "_close") then {
	_current = server getVariable [format ["garrison%1",_town],0];
	server setVariable [format ["garrison%1",_town],_current+4,true];
	if !(_townPos call OT_fnc_inSpawnDistance) exitWith {};

	_start = [_close,0,200, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_group = creategroup blufor;
	_groups pushback _group;
	_usecar = false;
	_veh = objNull;

	if(((_close distance _townPos) > 2000) && (random 100) > 50) then {
		_spawnpos = _start findEmptyPosition [5,100,OT_NATO_Vehicle_Police];
		_veh =  OT_NATO_Vehicle_Police createVehicle _spawnpos;
		_veh setDir (random 360);
		_group addVehicle _veh;
		_usecar = true;
		_groups pushback _veh;
	};

	_civ = _group createUnit [OT_NATO_Unit_SWATCommander, _start, [],0, "NONE"]; // SWAT leader
	removeAllWeapons _civ;
	_hour = date select 3;
	if(_skill > 0.5) then {
		if(_hour > 17 or _hour < 6) then {
			_civ linkItem "CUP_NVG_PVS15_green";
			_civ addGoggles "G_Tactical_clear";
			_civ enableGunLights "ForceOn";
		};
	};


	_civ addItem "ACE_fieldDressing";
	_civ addItem "ACE_fieldDressing";
	_civ addItem "ACE_morphine";
	_civ addItem "ACE_epinephrine";

	_weapon = "rhs_weap_g36c";
	_base = [_weapon] call BIS_fnc_baseWeapon;
	_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
	_civ addMagazine "rhssaf_30rnd_556x45_SOST_G36";
	_civ addMagazine "rhssaf_30rnd_556x45_SOST_G36";
	_civ addMagazine "rhssaf_30rnd_556x45_SOST_G36";
	_civ addWeaponGlobal _weapon;
	_civ addPrimaryWeaponItem "cup_acc_anpeq_15_flashlight_black_I";
	_civ addPrimaryWeaponItem "rksl_optic_eot552";
	_police pushBack _civ;
	[_civ,_town] call OT_fnc_initSWAT;
	_civ setBehaviour "SAFE";
	sleep 0.01;

	_start = [_start, 0, 20, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_civ1 = _group createUnit [OT_NATO_Unit_SWAT, _start, [],0, "NONE"];
	removeAllWeapons _civ1;
	_hour = date select 3;
	if(_skill > 0.5) then {
		if(_hour > 17 or _hour < 6) then {
			_civ1 linkItem "CUP_NVG_PVS15_green";
			_civ1 addGoggles "G_Tactical_clear";
			_civ1 enableGunLights "ForceOn";
		};
	};

	_civ1 addItem "ACE_fieldDressing";
	_civ1 addItem "ACE_fieldDressing";
	_civ1 addItem "ACE_morphine";
	_civ1 addItem "ACE_epinephrine";
	_weapon = "CUP_sgun_AA12";
	_base = [_weapon] call BIS_fnc_baseWeapon;
	_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
	_civ1 addMagazine "CUP_20Rnd_B_AA12_Pellets";
	_civ1 addMagazine "CUP_20Rnd_B_AA12_74Slug";
	_civ1 addMagazine "CUP_20Rnd_B_AA12_HE";
	_civ1 addWeaponGlobal _weapon;
	_police pushBack _civ1;
	[_civ1,_town] call OT_fnc_initSWAT;
	_civ1 setBehaviour "SAFE";

	_start = [_start, 0, 20, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_civ2 = _group createUnit [OT_NATO_Unit_SWAT, _start, [],0, "NONE"];
	removeAllWeapons _civ2;
	_hour = date select 3;
	if(_skill > 0.5) then {
		if(_hour > 17 or _hour < 6) then {
			_civ2 linkItem "CUP_NVG_PVS15_green";
			_civ2 addGoggles "G_Tactical_clear";
			_civ2 enableGunLights "ForceOn";
		};
	};


	_civ2 addItem "ACE_fieldDressing";
	_civ2 addItem "ACE_fieldDressing";
	_civ2 addItem "ACE_morphine";
	_civ2 addItem "ACE_epinephrine";


_weapon = "rhs_weap_m590_8RD";
_base = [_weapon] call BIS_fnc_baseWeapon;
_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
_civ2 addMagazine "rhusf_8rnd_00Buck";
_civ2 addMagazine "rhusf_8rnd_Slug";
_civ2 addMagazine "rhusf_8rnd_HE";
_civ2 addMagazine "rhusf_8rnd_Frag";
_civ2 addWeaponGlobal _weapon;

	_police pushBack _civ2;
	[_civ2,_town] call OT_fnc_initSWAT;
	_civ2 setBehaviour "SAFE";

	_start = [_start, 0, 20, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_civ3 = _group createUnit [OT_NATO_Unit_SWAT, _start, [],0, "NONE"];
	removeAllWeapons _civ3;
	_hour = date select 3;
	if(_skill > 0.5) then {
		if(_hour > 17 or _hour < 6) then {
			_civ3 linkItem "CUP_NVG_PVS15_green";
			_civ3 addGoggles "G_Tactical_clear";
			_civ3 enableGunLights "ForceOn";
		};
	};


	_civ3 addItem "ACE_fieldDressing";
	_civ3 addItem "ACE_fieldDressing";
	_civ3 addItem "ACE_morphine";
	_civ3 addItem "ACE_epinephrine";

_weapon = "rhs_weap_m590_8RD";
_base = [_weapon] call BIS_fnc_baseWeapon;
_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
_civ3 addMagazine "rhusf_8rnd_00Buck";
_civ3 addMagazine "rhusf_8rnd_Slug";
_civ3 addMagazine "rhusf_8rnd_HE";
_civ3 addMagazine "rhusf_8rnd_Frag";
_civ3 addWeaponGlobal _weapon;
	_police pushBack _civ3;
	[_civ3,_town] call OT_fnc_initSWAT;
	_civ3 setBehaviour "SAFE";

	_start = [_start, 0, 20, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_civ4 = _group createUnit [OT_NATO_Unit_SWAT, _start, [],0, "NONE"];
	removeAllWeapons _civ4;
	_hour = date select 3;
	if(_skill > 0.5) then {
		if(_hour > 17 or _hour < 6) then {
			_civ4 linkItem "CUP_NVG_PVS15_green";
			_civ4 addGoggles "G_Tactical_clear";
			_civ4 enableGunLights "ForceOn";
		};
	};


	_civ4 addItem "ACE_fieldDressing";
	_civ4 addItem "ACE_fieldDressing";
	_civ4 addItem "ACE_morphine";
	_civ4 addItem "ACE_epinephrine";


_weapon = "CUP_hgun_Ballisticshield_Armed";
_base = [_weapon] call BIS_fnc_baseWeapon;
_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
_civ4 addMagazine "CUP_15Rnd_9x19_M9";
_civ4 addMagazine "CUP_15Rnd_9x19_M9";
_civ4 addMagazine "CUP_15Rnd_9x19_M9";
_civ4 addMagazine "CUP_15Rnd_9x19_M9";
_civ4 addWeaponGlobal _weapon;
	_police pushBack _civ4;
	[_civ4,_town] call OT_fnc_initSWAT;
	_civ4 setBehaviour "SAFE";



	if(_usecar) then {
		{
			_x moveInAny _veh;
		}foreach(units _group);

		_drop = (([_townPos, 50, 350, 1, 0, 0, 0] call BIS_fnc_findSafePos) nearRoads 500) select 0;

		_move = _group addWaypoint [_drop,0];
		_move setWaypointType "MOVE";
		_move setWaypointBehaviour "CARELESS";
		_move setWaypointStatements ["true","(vehicle this) setvariable ['LUCE', 1, false];"];
		_move setWaypointStatements ["true","(vehicle this) setvariable ['AUDIO', 1, false];"];
		_move setWaypointStatements ["true", "(vehicle this) action ['lightOn', vehicle this];"];
		_move = _group addWaypoint [_drop,0];
		_move setWaypointType "UNLOAD";
	};

	sleep 1;

	_group call OT_fnc_initGendarmPatrol;

};



_groups
