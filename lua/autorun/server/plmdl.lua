--[[ Player Model Override : server init
     By 'Jai the Fox' 2020 ]]


-- Variables

-- Enumerations
local PLMDL_OVERRIDE_DISABLE_ALL = 1;
local PLMDL_OVERRIDE_DISABLE_COLORS = 2;
local PLMDL_OVERRIDE_DISABLE_MODELS = 3;

-- Table of gamemodes for predetermined overrides
local PLMDL_GAMEMODE_OVERRIDES = {
	["base"] = PLMDL_OVERRIDE_DISABLE_ALL,
	["sandbox"] = PLMDL_OVERRIDE_DISABLE_ALL,
	["prop_hunt"] = PLMDL_OVERRIDE_DISABLE_MODELS,
	["murder"] = PLMDL_OVERRIDE_DISABLE_ALL,
	["prophunters"] = PLMDL_OVERRIDE_DISABLE_ALL,
	["darkrp"] = PLMDL_OVERRIDE_DISABLE_ALL
};

-- ConVars
local plmdl_override_disable = CreateConVar("plmdl_override_disable", 0, FCVAR_NOTIFY, "Controls playermodel overrides. '1' disables completely, '2' overrides model but not colors, '3' overrides colors but not model.", 0, 3);


-- Functions

-- Function that is called a bit after PlayerSetModel
local function PostPlayerSetModel(ply)
	-- Get the playermodel information
	local plyModel = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"));
	local plySkin = ply:GetInfoNum("cl_playerskin", 0);
	local plyBGroups = ply:GetInfo("cl_playerbodygroups");
	local plyColor = ply:GetInfo("cl_playercolor");
	
	-- Make sure the bodygroups variable is not nil
	if (plyBGroups == nil) then plyBGroups = ""; end
	
	-- If the plmdl_override_disable cvar is set to 3, avoid this section
	if (plmdl_override_disable:GetInt() != PLMDL_OVERRIDE_DISABLE_MODELS) then
		-- Precaches the model
		util.PrecacheModel(plyModel);
		
		-- Sets the player's model + skin
		ply:SetModel(plyModel);
		ply:SetSkin(plySkin);
		
		-- Set the bodygroups
		plyBGroups = string.Explode(" ", plyBGroups);
		for k = 0, ply:GetNumBodyGroups() - 1 do
			ply:SetBodygroup(k, tonumber(plyBGroups[k + 1]) || 0);
		end
	end
	
	-- If the plmdl_override_disable is set to 2, avoid this section
	if (plmdl_override_disable:GetInt() != PLMDL_OVERRIDE_DISABLE_COLORS) then
		-- Set the player color
		ply:SetPlayerColor(Vector(plyColor));
	end
end

-- Hook the initialize function
local function pmdlInitialize()
	-- Add the network string
	util.AddNetworkString("plmdl_notify");
	
	-- Set the cvar to a predetermined value depending on the defined gamemode
	if (PLMDL_GAMEMODE_OVERRIDES[lower(engine.ActiveGamemode())]) then
		plmdl_override_disable:SetInt(tonumber(PLMDL_GAMEMODE_OVERRIDES[lower(engine.ActiveGamemode())]) || 0);
	end
end
hook.Add("Initialize", "pmdlInitialize", pmdlInitialize);

-- Hook the player set model function
local function pmdlPlayerSetModel(ply)
	-- Use a delayed call to set the model a bit after setting the initial model
	if (plmdl_override_disable:GetInt() != PLMDL_OVERRIDE_DISABLE_ALL && ply.overridePlayerModel) then
		timer.Simple(0.025, function() if (IsValid(ply)) then hook.Run("PostPlayerSetModel", ply); end end);
	end
end
hook.Add("PlayerSetModel", "pmdlPlayerSetModel", pmdlPlayerSetModel);

-- Receive the networked packet from the client to update their status on whether the playermodel should be overriden or not
local function pmdlNotify(len, ply)
	if (ply.overridePlayerModel == nil) then ply.overridePlayerModel = net.ReadBool(); hook.Run("PlayerSetModel", ply); end
end
net.Receive("plmdl_notify", pmdlNotify);
