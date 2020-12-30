--[[ Player Model Override : client init
     By 'Jai the Fox' 2020 ]]


-- Variables

-- ConVar pointer variables
local cl_playercolor = GetConVar("cl_playercolor");
local cl_playerskin = GetConVar("cl_playerskin");
local cl_playerbodygroups = GetConVar("cl_playerbodygroups");


-- Functions

-- Hook into InitPostEntity so we can send a network packet to the server to notify about a few things
local function pmdlInitPostEntity()
	-- This variable starts off as false and is set to true if conditions below are met
	local modelOverride = false;
	
	-- If the playercolor cvar is nil, create it and set the modelOverride variable above to true
	if (cl_playercolor == nil) then
		modelOverride = true;
		cl_playercolor = CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255");
	end
	
	-- If the playerskin cvar is nil, create it and set the modelOverride variable above to true
	if (cl_playerskin == nil) then
		modelOverride = true;
		cl_playerskin = CreateConVar("cl_playerskin", "0", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The skin to use, if the model has any");
	end
	
	-- If the playerbodygroups cvar is nil, create it and set the modelOverride variable above to true
	if (cl_playerbodygroups == nil) then
		modelOverride = true;
		cl_playerbodygroups = CreateConVar("cl_playerbodygroups", "0", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The bodygroups to use, if the model has any");
	end
	
	-- Send a network packet to the server letting it know if it should override our model or not
	net.Start("plmdl_notify");
		net.WriteBool(modelOverride);
	net.SendToServer();
end
hook.Add("InitPostEntity", "pmdlInitPostEntity", pmdlInitPostEntity);
