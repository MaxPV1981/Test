params ["_frompos","_ao","_attackpos","_byair",["_delay",0]];
if (_delay > 0) then {sleep _delay};
private _spawnpos = _frompos;
private _vehtype = [];
private _tgroup = false;
if(_byair) then {
	sleep 0.3;
	_vehtype = OT_NATO_Vehicle_AirTransport;
        private _group1 = [_spawnpos, WEST, (configFile >> "CfgGroups" >> "West" >> "LIB_FSJ" >> "Jump" >> "LIB_FSJ_Infantry_squad")] call BIS_fnc_spawnGroup;
        _group1 deleteGroupWhenEmpty true;
}else{
	sleep 0.3;
        _vehtype = OT_NATO_Vehicle_Transport call BIS_fnc_selectRandom;
	private _group2 = [_spawnpos, WEST, (configFile >> "CfgGroups" >> "West" >> OT_faction_NATO >> OT_faction_NATO_Infantry >> "LIB_GER_infantry_squad")] call BIS_fnc_spawnGroup;
	_group2 deleteGroupWhenEmpty true;
};

sleep 0.5;
private _allunits = [];
private _veh = false;
private _pos = false;

//Transport
private _tgroup = creategroup blufor;
private _dir = 0;
_tgroup deleteGroupWhenEmpty true;

if(_byair) then {
   _frompos = OT_NATO_JetPos;
   _pos = _frompos findEmptyPosition [2,100,_vehtype];
   _veh =  _vehtype createVehicle _pos;
   _veh setDir OT_NATO_JetDir;
   _veh setVariable ["garrison","HQ",false];
   _tgroup addVehicle _veh;
   createVehicleCrew _veh;
{
	[_x] joinSilent _tgroup;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["NOAI",true,false];
}foreach(crew _veh);
_allunits = (units _tgroup);
{
	_x addCuratorEditableObjects [(units _tgroup) + [_veh],true];
} forEach allCurators;
sleep 1;

{
	if(typename _tgroup isEqualTo "GROUP") then {
		_x moveInCargo _veh;
	};
	[_x] joinSilent _group1;
	_allunits pushback _x;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["VCOM_NOPATHING_Unit",true,false];

	[_x] call OT_fnc_initMilitary;

}foreach(units _group1);

{
	_x addCuratorEditableObjects [units _group1,true];
} forEach allCurators;

spawner setVariable ["NATOattackforce",(spawner getVariable ["NATOattackforce",[]])+[_group1],false];
}else{



if !(_pos isEqualType []) then {
	_pos = _frompos findEmptyPosition [15,100,_vehtype];
	if(count _pos == 0) then {
		_pos = [_frompos,0,75,false,[0,0],[120,_vehtype]] call SHK_pos_fnc_pos;
	};
	_dir = [_frompos,_ao] call BIS_fnc_dirTo;
};
_pos set [2,1];
_veh = createVehicle [_vehtype, [0,0,1000+random 1000], [], 0, "CAN_COLLIDE"];
_veh setDir (_dir);
_veh setPosATL _pos;
_veh setVariable ["garrison","HQ",false];

_tgroup addVehicle _veh;
createVehicleCrew _veh;
{
	[_x] joinSilent _tgroup;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["NOAI",true,false];
}foreach(crew _veh);
_allunits = (units _tgroup);
{
	_x addCuratorEditableObjects [(units _tgroup) + [_veh],true];
} forEach allCurators;
sleep 1;

	{
		if(typename _tgroup isEqualTo "GROUP") then {
			_x moveInCargo _veh;
		};
		[_x] joinSilent _group2;
		_x setVariable ["VCOM_NOPATHING_Unit",true,false];
		_allunits pushback _x;
		_x setVariable ["garrison","HQ",false];
		[_x] call OT_fnc_initMilitary;

	}foreach(units _group2);
	{
		_x addCuratorEditableObjects [units _group2,true];
	} forEach allCurators;
	spawner setVariable ["NATOattackforce",(spawner getVariable ["NATOattackforce",[]])+[_group2],false];
};



sleep 5;
if(_byair && _tgroup isEqualType grpNull) then {
	_wp = _tgroup addWaypoint [_frompos,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCompletionRadius 150;
	_wp setWaypointStatements ["true",format["(vehicle this) flyInHeight %1;",250+random 50]];

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointStatements ["true", "(vehicle this) action ['lightOn', vehicle this];"];
	_wp setWaypointStatements ["true", "(vehicle this) setCollisionLight true;"];
	_wp setWaypointCompletionRadius 50;
	_wp setWaypointSpeed "FULL";

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointStatements ["true","[vehicle this,75] spawn OT_fnc_parachuteAll"];
	_wp setWaypointTimeout [5,5,5];

/*
	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointBehaviour "CARELESS";
//	_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['DoorLB', 0, false];"];
	_wp setWaypointTimeout [2,2,2];
*/
}else{
	if(typename _tgroup isEqualTo "GROUP") then {
		_veh setdamage 0;
		_dir = [_attackpos,_frompos] call BIS_fnc_dirTo;
		_roads = _ao nearRoads 150;
		private _dropos = _ao;

		//Try to make sure drop position is on a bigger road
		{
			private _pos = getpos _x;
			if(isOnRoad _pos) exitWith {_dropos = _pos};
		}foreach(_roads);

		_move = _tgroup addWaypoint [_dropos,0];
		_move setWaypointBehaviour "CARELESS";
		_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['door_1_1_rotate', 1, false];"];
		_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['door_2_1_rotate', 1, false];"];
		_move setWaypointTimeout [30,30,30];
		_move setWaypointType "TR UNLOAD";
		_move setWaypointCompletionRadius 50;

		_wp = _tgroup addWaypoint [_frompos,0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "CARELESS";
		_wp setWaypointCompletionRadius 25;

		_wp = _tgroup addWaypoint [_frompos,0];
		_wp setWaypointType "SCRIPTED";
		_wp setWaypointCompletionRadius 25;
		_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['door_1_1_rotate', 0, true];"];
		_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['door_2_1_rotate', 0, true];"];
		_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup"];
	};
};
sleep 10;

if (_byair) then {
_wp = _group1 addWaypoint [_attackpos,100];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointSpeed "FULL";
};

if !(_byair) then {
	_wp = _group2 addWaypoint [_attackpos,100];
	_wp setWaypointType "SAD";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
};

if(typename _tgroup isEqualTo "GROUP") then {

	[_veh,_tgroup,_frompos,_byair] spawn {
		//Ejects crew from vehicles when they take damage or stay relatively still for too long (you know, like when they ram a tree for 4 hours)
		params ["_veh","_tgroup","_frompos","_byair"];
		private _done = false;
		private _stillfor = 0;
		private _lastpos = getpos _veh;
		while{sleep 10;!_done} do {
			if(isNull _veh) exitWith {};
			if(isNull _tgroup) exitWith {};
			if(!alive _veh) exitWith {};
			private _eject = false;
			if((damage _veh) > 0.5 && ((getpos _veh) select 2) < 2) then {
				//Vehicle damaged (and on the ground)
				_eject = true;
			};
			if((getpos _veh) distance _lastpos < 0.5) then {
				_stillfor = _stillfor + 10;
				if(_stillfor > 60) then {
					//what are you doing? gtfo
					_eject = true;
				};
			}else{
				_stillfor = 0;
			};
			if(_eject) exitWith {
				while {(count (waypoints _tgroup)) > 0} do {
				 	deleteWaypoint ((waypoints _tgroup) select 0);
				};
				commandStop (driver _veh);
				{
					unassignVehicle _x;
					commandGetOut _x;
				}foreach(crew _veh);
				_done = true;
				waitUntil {sleep 2;(count crew _veh) isEqualTo 0};
				[_veh] call OT_fnc_cleanup;
			};
//			if(_byair && (_veh getVariable ["OT_deployedTroops",false])) exitWith {
			if(_byair) exitWith {
			    _wp = _tgroup addWaypoint [OT_NATO_JetLandPos,50];
			    _wp setWaypointType "MOVE";
			    _wp setWaypointBehaviour "SAFE";
			    _wp setWaypointSpeed "FULL";

			    waitUntil{sleep 10;(alive _veh && (_veh distance OT_NATO_JetLandPos) < 150) || !alive _veh};

			    if(alive _veh) then {
			        while {(count (waypoints _tgroup)) > 0} do {
			            deleteWaypoint ((waypoints _tgroup) select 0);
			        };
			        _veh action ["LAND", _veh];
			        waitUntil{sleep 10;(speed _veh) isEqualTo 0};
    };
				    _veh call OT_fnc_cleanup;
				    _tgroup call OT_fnc_cleanup;
				_done = true;
			};

		};
	};
};

