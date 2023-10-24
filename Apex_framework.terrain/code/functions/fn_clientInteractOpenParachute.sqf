/*
File: fn_clientInteractOpenParachute.sqf
Author:

	Quiksilver
	
Last Modified:

	12/10/2022 A3 2.14 by Quiksilver
	
Description:

	Open Parachute Interaction
________________________________________________*/

if (diag_tickTime < (uiNamespace getVariable ['QS_client_openParachuteCooldown',-1])) exitWith {};
uiNamespace setVariable ['QS_client_openParachuteCooldown',diag_tickTime + 5];
_objectParent = objectParent player;
if (isNull _objectParent) then {
	_velocity = velocity player;
	_para = createVehicle [QS_core_classNames_steerableP,[-500 + (random 100),-500 + (random 100),500 + (random 100)]];
	_para setDir (getDir player);
	_para setPos (player modelToWorld [0,5,0]);
	player assignAsDriver _para;
	player moveInDriver _para;
	[_para,_velocity] spawn {
		params ['_para','_velocity'];
		for '_i' from 0 to 2 step 1 do {
			sleep 1;
			if (isTouchingGround _para) exitWith {};
			_para setVelocity _velocity;
		};
	};
} else {
	_position = getPosWorld _objectParent;
	_velocity = velocity _objectParent;
	private _chuteType = qs_core_classnames_vehicleparachute;
	if (_objectParent isKindOf 'Tank') then {
		_chuteType = qs_core_classnames_vehicleparachute; //_chuteType = 'SpaceshipCapsule_01_parachute_F';
	};
	_para = createVehicle [_chuteType,_position];
	_para setPosWorld (_position vectorAdd [0,0,5]);
	_para allowDamage FALSE;
	_para setDir (getDir _objectParent);
	[1,_objectParent,[_para,[0,0,1]]] call QS_fnc_eventAttach;
	_para setVelocity _velocity;
	[_para,_velocity] spawn {
		params ['_para','_velocity'];
		for '_i' from 0 to 2 step 1 do {
			sleep 1;
			if (isTouchingGround _para) exitWith {};
			_para setVelocity _velocity;
		};
	};
	[_objectParent,_para] spawn {
		params ['_objectparent','_para'];
		waitUntil {
			(
				(((getPos _objectparent) # 2) < 10) ||
				{(!alive _objectparent)} ||
				{(isNull (attachedTo _objectParent))} ||
				{isNull _para}
			)
		};
		if (!isNull (attachedTo _objectParent)) then {
			[0,_objectParent] call QS_fnc_eventAttach;
			sleep 1;
			deleteVehicle _para;
		};
	};
};