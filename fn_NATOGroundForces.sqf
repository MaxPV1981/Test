params ["_frompos","_ao","_attackpos","_byair",["_delay",0]];
if (_delay > 0) then {sleep _delay};
private _done = false;
private _vehtype = [];
private _group1 = false;
private _group2 = false;
private _tplanes = server getVariable ["NATOplanes",[]];
private _allunits = [];
private _veh = false;
private _pos = false;
private _tgroup = creategroup blufor;
private _dir = 0;

if(_byair && _tplanes > 0) then {

sleep 0.2;
_frompos = OT_NATO_JetPos;
_vehtype = OT_NATO_Vehicle_AirTransport;
_group1 = [_frompos, WEST, (configFile >> "CfgGroups" >> "West" >> "LIB_FSJ" >> "Jump" >> "LIB_FSJ_Infantry_squad")] call BIS_fnc_spawnGroup;
_group1 deleteGroupWhenEmpty true;

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

_tgroup deleteGroupWhenEmpty true;
sleep 0.2;

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
	_x addCuratorEditableObjects [(units _group1) + (units _tgroup) + [_veh],true];
} forEach allCurators;

spawner setVariable ["NATOattackforce",(spawner getVariable ["NATOattackforce",[]])+[_group1],false];

	private _move = _tgroup addWaypoint [_frompos,-800];
	_move setWaypointType "MOVE";
	_move setWaypointBehaviour "SAFE";
	_move setWaypointSpeed "FULL";
	_move setWaypointCompletionRadius 750;
	_move setWaypointStatements ["true",format["(vehicle this) flyInHeight %1;",350+random 50]];
	_move setWaypointTimeout [1,1,1];

	_move = _tgroup addWaypoint [_ao,300];
	_move setWaypointType "MOVE";
	_move setWaypointStatements ["true","(vehicle this) action ['lightOn', vehicle this]; (vehicle this) setCollisionLight true;"];
	_move setWaypointCompletionRadius 350;
	_move setWaypointSpeed "FULL";

	_move = _tgroup addWaypoint [_ao,0];
	_move setWaypointType "SCRIPTED";
	_move setWaypointStatements ["true","[vehicle this,350] spawn OT_fnc_parachuteAll"];
	_move setWaypointCompletionRadius 500;
//	_move setWaypointTimeout [3,3,3];

	_move = _tgroup addWaypoint [OT_NATO_JetLandPos,50];
	_move setWaypointType "MOVE";
	_move setWaypointBehaviour "SAFE";
	_move setWaypointSpeed "FULL";
	_move setWaypointCompletionRadius 500;

	_move = _tgroup addWaypoint [OT_NATO_JetLandPos,50];
	_move setWaypointBehaviour "SAFE";
	_move setWaypointSpeed "FULL";
	_move setWaypointType "SCRIPTED";
	_move setWaypointStatements ["true","(vehicle this) action ['LAND']"];

	private _wp = _group1 addWaypoint [_attackpos,100];
	_wp setWaypointType "SAD";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";

sleep 60;

waitUntil {(isNull _veh) or (!alive _veh) or (alive _veh && _veh distance OT_NATO_JetPos < 350 && speed _veh < 10 && (position _veh select 2) < 20 && (count crew _veh < 4))};
if((isNull _veh) or (!alive _veh)) exitWith {
    private _tplanes = server getVariable ["NATOplanes",[]];			
    _tplanes = _tplanes - 1;
    server setVariable ["NATOplanes",_tplanes,true];
    sleep 60; 
    private _back = ((leader _tgroup call OT_fnc_nearestObjective) select 0);
    private _base = ((leader _tgroup call OT_fnc_nearestObjective) select 1);
    if (count units _tgroup isEqualTo 0) then {
        _back = ((leader _group1 call OT_fnc_nearestObjective) select 0);
        _base = ((leader _group1 call OT_fnc_nearestObjective) select 1);
    };
    if (typename _tgroup isEqualTo "GROUP" && (leader _group1 distance _attackpos > 2000) && (leader _group1 distance leader _tgroup < 500)) then { // infantry group will escort pilots to the nearby base
        while {(count (waypoints _group1)) > 0} do {
        deleteWaypoint ((waypoints _group1) select 0)};
        while {(count (waypoints _tgroup)) > 0} do {
        deleteWaypoint ((waypoints _tgroup) select 0)};
        sleep 1; 
	{
            [_x] joinSilent _group1;
	}foreach(units _tgroup);
        private _wp = _group1 addWaypoint [_back,0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointCompletionRadius 150;

        Hint format ["Groups are moving to %1",_back];
        waitUntil {(leader _group1 distance _back < 50)};
        _group1 call OT_fnc_cleanup;
        private _numNATO = server getVariable format["garrison%1",_base]; //adding group members to the base garrison
	_numNATO = (_numNATO + (count units _group));
	server setVariable [format["garrison%1",_name],_numNATO,true];
     } else {
        while {(count (waypoints _tgroup)) > 0} do {
        deleteWaypoint ((waypoints _tgroup) select 0)};
        sleep 60;
        Hint format ["Pilots group are moving to %1",_back];

        private _move = _tgroup addWaypoint [_back,0];
        _move setWaypointType "MOVE";
        _move setWaypointBehaviour "SAFE";
        _move setWaypointCompletionRadius 150;

        waitUntil {(leader _tgroup distance _back < 150)};
        _tgroup call OT_fnc_cleanup;
    };
};

if ((alive _veh && (_veh distance OT_NATO_JetPos) < 350) && (speed _veh) < 10) exitwith {
     while {(count (waypoints _tgroup)) > 0} do {
     deleteWaypoint ((waypoints _tgroup) select 0);
     sleep 1;
     _veh call OT_fnc_cleanup;
     _tgroup call OT_fnc_cleanup;
    };
};

} else { //Ground forces

sleep 0.2;
private _gungroup = [];
private _gun = [];

_vehtype = selectrandom OT_NATO_Vehicle_Transport;
_group2 = [_frompos, WEST, (configFile >> "CfgGroups" >> "West" >> OT_faction_NATO >> OT_faction_NATO_Infantry >> "LIB_GER_infantry_squad")] call BIS_fnc_spawnGroup;
_group2 deleteGroupWhenEmpty true;

_pos = _frompos findEmptyPosition [15,100,_vehtype];
private _dir = [_frompos,_ao] call BIS_fnc_dirTo;

_veh = _vehtype createVehicle _pos; 
_veh setDir (_dir);
_veh setVariable ["garrison","HQ",false];

_tgroup addVehicle _veh;
_tgroup deleteGroupWhenEmpty true;

private _driver = _tgroup createUnit ["LIB_GER_scout_rifleman", driver _veh, [], 0, "NONE"]; 
_driver moveInDriver _veh;


if (random 100 < 50) then { //tow a gun with 50% chance
_gungroup = creategroup blufor;
_gun = "IFA3_Pak38" createVehicle [(getpos _veh) select 0, (getpos _veh select 1) + 3.5, (getpos _veh select 2) + 0.1]; //LIB_ger_Pak40_Camo00 dir +180 IFA3_Pak38
_gun setDir (getDir _veh) + 180; 
_gun setPos (getPos _gun); 
[_veh,_gun] call LIB_System_Artillery_Towing_Condition_Attach_General;
[_veh] spawn LIB_System_Artillery_Towing_Statement_Attach_Wheeled_APCs;
[_gun,_gungroup] call OT_fnc_crew_replace;
_gun setVariable ["LIB_ARTY_MOVING_TOWING",true,true];
_gungroup addVehicle _gun;
_gungroup deleteGroupWhenEmpty true;

{
	[_x] joinSilent _gungroup;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["NOAI",true,false];
	_x setVariable ["VCOM_NOPATHING_Unit",true,false];
}foreach(crew _gun);

{
	_x addCuratorEditableObjects [units _gungroup,true];
} forEach allCurators;
};

{
	[_x] joinSilent _tgroup;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["NOAI",true,false];
	_x setVariable ["VCOM_NOPATHING_Unit",true,false];
}foreach(crew _veh);

_allunits = (units _tgroup);
{
	_x addCuratorEditableObjects [(units _tgroup) + [_veh],true];
} forEach allCurators;

sleep 0.2;

{
	if(typename _tgroup isEqualTo "GROUP") then {
		_x moveInAny _veh;
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

[_veh turretUnit [0]] joinSilent _tgroup;

sleep 0.2;

		_dir = [_attackpos,_frompos] call BIS_fnc_dirTo;
		_roads = _ao nearRoads 150;
		private _dropos = _ao;

		//Try to make sure drop position is on a bigger road
		{
			private _pos = getpos _x;
			if(isOnRoad _pos) exitWith {_dropos = _pos};
		}foreach(_roads);

                private _move = _tgroup addWaypoint [_dropos,0];
                _move setWaypointType "MOVE";
                _move setWaypointBehaviour "SAFE";
                _move setWaypointSpeed "FULL";
                _move setWaypointCompletionRadius 50;

		_move = _tgroup addWaypoint [_dropos,0];
		_move setWaypointBehaviour "SAFE";
		_move setWaypointTimeout [15,15,15];
		_move setWaypointType "TR UNLOAD";
		_move setWaypointCompletionRadius 50;

		_move = _tgroup addWaypoint [_frompos,0];
		_move setWaypointType "MOVE";
		_move setWaypointBehaviour "SAFE";
		_move setWaypointCompletionRadius 50;

		private _wp = _group2 addWaypoint [_attackpos,100];
		_wp setWaypointType "SAD";
		_wp setWaypointBehaviour "COMBAT";
		_wp setWaypointSpeed "FULL";

if (typename _gungroup isEqualTo "GROUP") then {
[_veh,_tgroup,_group2,_dropos,_gun,_gungroup] spawn { //function for artillery
    sleep 10;
    params ["_veh","_tgroup","_group2","_dropos","_gun","_gungroup"];
    private _done = false;
    while{sleep 2;!_done} do {
            if ((isNull _veh) or (!alive _veh)) exitWith {
                _done = true;
            };
            if (isNull _tgroup) exitWith {
                _done = true;
            };
            if (((_veh distance _dropos) < 50) && (speed _veh < 10)) then {
                    _gun setVariable ["LIB_ARTY_MOVING_TOWING",false,true];
                    [_veh,_gun] call LIB_System_Artillery_Towing_Condition_Drop_General;
                    [_veh,_gun] call LIB_System_Artillery_Towing_Statement_Drop_General;
                    sleep 2;
                    _gun setDir (getdir _veh);
                    _gungroup setCombatMode "RED";
                    _gungroup enableDynamicSimulation true;
                    if (count crew _veh > 2) then {
                    {
                        unassignVehicle _x;
                        commandGetOut _x;
                    }foreach (units _group2);
                   _done = true;
                };
            };

        };
    };
};

[_veh,_tgroup,_gun] spawn {
    //Ejects crew from vehicles when they take damage or stay relatively still for too long (you know, like when they ram a tree for 4 hours)
        sleep 20;
        params ["_veh","_tgroup","_gun"];
        private _done = false;
        private _cpos = getpos _veh;
        private _eject = false;
        while{sleep 120;!_done && alive _veh} do {
	        private _back = ((leader _tgroup call OT_fnc_nearestObjective) select 0); //escape to the nearest base

            if ((isNull _veh) or (!alive _veh)) exitWith {
	        if (typename _tgroup isEqualTo "GROUP") then { 
	        while {(count (waypoints _tgroup)) > 0} do {
	        deleteWaypoint ((waypoints _tgroup) select 0)};
	        sleep 10;
                _wp = _tgroup addWaypoint [_back,0];
                _wp setWaypointType "MOVE";
                _wp setWaypointBehaviour "SAFE";
                _wp setWaypointCompletionRadius 50;
	        waitUntil {(leader _tgroup distance _back < 150)};
	        _tgroup call OT_fnc_cleanup;
                _done = true;
	        };
            };
            if (isNull _tgroup) exitWith {
            _done = true;
            };
            if((damage _veh) > 0.5 && ((getpos _veh) select 2) < 2) then {
            //Vehicle damaged (and on the ground)
            _eject = true;
            };
            if ((_veh distance _cpos) < 1)  then {
            _eject = true;
            }else{
            private _distance = _veh distance _cpos;
            _cpos = getpos _veh;
            };
            if (_eject) exitWith {
                while {(count (waypoints _tgroup)) > 0} do {
                deleteWaypoint ((waypoints _tgroup) select 0);
                };
                if (typename _gungroup isEqualTo "GROUP") then {
                _gun setVariable ["LIB_ARTY_MOVING_TOWING",false,true]; //if ejected with the gun attached, then detach the gun
                [_veh,_gun] call LIB_System_Artillery_Towing_Condition_Drop_General;
                [_veh,_gun] call LIB_System_Artillery_Towing_Statement_Drop_General;
                sleep 2;
                _gun setDir (getdir _veh);
                _gungroup setCombatMode "RED";
                };
                commandStop (driver _veh);
                {
                unassignVehicle _x;
                commandGetOut _x;
                }foreach(crew _veh);
                waitUntil {count crew _veh isEqualTo 0};
                _veh call OT_fnc_cleanup;
                _done = true;
               _wp = _tgroup addWaypoint [_back,0];
               _wp setWaypointType "MOVE";
               _wp setWaypointBehaviour "SAFE";
               _wp setWaypointCompletionRadius 50;
                waitUntil {(leader _tgroup distance _back < 150)};
               _tgroup call OT_fnc_cleanup;
           };            
        };
    };


sleep 30;

waitUntil {((alive _veh) && (_veh distance _frompos) < 150 && speed _veh < 10 && (count crew _veh) < 4)};
        while {(count (waypoints _tgroup)) > 0} do {
        deleteWaypoint ((waypoints _tgroup) select 0);
        };
	sleep 1;
	_tgroup call OT_fnc_cleanup;
	_veh call OT_fnc_cleanup;
	_done = true;

};
