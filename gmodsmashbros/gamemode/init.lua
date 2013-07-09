AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

--networking
util.AddNetworkString("HitScaleSender")
util.AddNetworkString("ModelSender")
local function sendhitscale(ply)
	net.Start("HitScaleSender")
	net.WriteFloat(tostring(ply.HitScale))
	net.Send(ply)
end



net.Receive( "ModelSender", function( length, ply )
        ply.plmodel = net.ReadString()
        PrintMessage(HUD_PRINTTALK, "GOT IT!!!"..ply.plmodel)
   end )


--useful functions

local function verticalthrow(ply)
	if ply.HitScale < 250 then
		return 300
	else
		return ply.HitScale
	end
end

-- HOOKED STUFF!






function giveweapon( ply )

			local oldhands = ply:GetHands()
  if ( IsValid( oldhands ) ) then oldhands:Remove() end

  local hands = ents.Create( "gmod_hands" )
  if ( IsValid( hands ) ) then
    ply:SetHands( hands )
    hands:SetOwner( ply )

    -- Which hands should we use?
    local cl_playermodel = ply:GetInfo( "cl_playermodel" )
    local info = player_manager.TranslatePlayerHands( cl_playermodel )
    if ( info ) then
      hands:SetModel( info.model )
      hands:SetSkin( info.skin )
      hands:SetBodyGroups( info.body )
    end

    -- Attach them to the viewmodel
    local vm = ply:GetViewModel( 0 )
    hands:AttachToViewmodel( vm )

    vm:DeleteOnRemove( hands )
    ply:DeleteOnRemove( hands )

    hands:Spawn()
  end

	ply:Give("weapon_fists")
end




local pmodels = {
	"models/player/alyx.mdl",
	"models/player/breen.mdl",
	"models/player/barney.mdl",
	"models/player/eli.mdl",
	"models/player/gman_high.mdl",
	"models/player/kleiner.mdl",
	"models/player/monk.mdl",
	"models/player/odessa.mdl",
	"models/player/magnusson.mdl",
	"models/player/Police.mdl",
	"models/player/Combine_Soldier.mdl",
	"models/player/Combine_Soldier_PrisonGuard.mdl",
	"models/Combine_Super_Soldier.mdl",
}

for k, v in pairs(pmodels) do
	util.PrecacheModel(v)
end



function GM:PlayerSetModel( ply )
	print(ply.plmodel)
	ply:SetModel( ply.plmodel )
end

local function smash(vic, info)
	local attacker = info:GetAttacker()
	local weapon = info:GetInflictor()
	if vic:IsPlayer() and attacker:IsPlayer() and weapon:GetClass("weapon_fists") then
		vic:SetVelocity(Vector(attacker:GetAimVector().x *attacker.HitScale, attacker:GetAimVector().y *attacker.HitScale, verticalthrow(attacker)))
		attacker.HitScale = math.Round(attacker.HitScale * 1.1)
		vic.HitScale = math.Round(vic.HitScale *.95)
		vic.LastHit = attacker:Name()
		sendhitscale(attacker)
		PrintMessage(HUD_PRINTTALK, "New HitScale: "..tostring(attacker.HitScale).."")
	end
end

local function setup(ply)
	if !ply.plmodel then
		ply.plmodel = "models/player/eli.mdl"
	end
	ply.HitScale = 100
	ply.LastHit = "himself"
	sendhitscale(ply)
end

local function zeroo(ply)
	ply.HitScale = 100
	sendhitscale(ply)
	ply.LastHit = "himself"
end

local function killonground(ply)
	if ply:GetPos().z < -12287 then
		ply:SetHealth(0)
		PrintMessage(HUD_PRINTTALK, ply:Name().." has been thrown off the level by "..ply.LastHit)
	end
end

local function doublejump(ply, key)
	if key == IN_JUMP then
		if !ply:IsOnGround() then
			if ply.FirstJump == 1 then
				ply:SetVelocity(Vector(0,0,200) + Vector(0,0,-1*ply:GetVelocity().z))
				ply.FirstJump = 0
			end
		else
			ply.FirstJump = 1
		end
	end
end

hook.Add("PlayerSpawn", "givefists", giveweapon)
hook.Add("PlayerSetModel", "SetModel", setmodel)
hook.Add("EntityTakeDamage", "makefly", smash)
hook.Add("PlayerInitialSpawn", "setting up", setup)
hook.Add("PlayerDeath", "zeroing", zeroo)
hook.Add("OnPlayerHitGround", "killing", killonground)
hook.Add("KeyPress", "doublejump", doublejump)


--basic admin mod stuff
local function sb_kick(ply, cmd, args)
	if !args[1] or !args[2] then return end
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Name()), string.lower(args[1])) then
				v:Kick(args[2])
				PrintMessage(HUD_PRINTTALK, wv:Name().."just got kicked: "..args[2])
			end
		end
	end
end

local function sb_kill(ply, cmd, args)
	if !args[1] then return end
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Name()), string.lower(args[1])) then
				v:Kill()
				PrintMessage(HUD_PRINTTALK, v:Name().." just got slayed" )
			end
		end
	end
end

local function sb_ban(ply, cmd, args)
	if !args[1] or !args[2] or !args[3] then return end
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Name()), string.lower(args[1])) then
				v:Ban( args[2], args[3])
				PrintMessage(HUD_PRINTTALK, v:Name().." just got banned for "..args[2].."minutes: "..args[3])
			end
		end
	end
end

local function sb_debug()
	for k, v in pairs(player.GetAll()) do
		print(v.HitScale)
	end
end

concommand.Add("sb_kick", sb_kick)
concommand.Add("sb_kill", sb_kill)
concommand.Add("sb_ban", sb_ban)
concommand.Add("sb_debug", sb_debug)

local function ps_sgive(ply, cmd, args)
	if !ply then
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Name()), string.lower(args[1])) then
				v:ps_givepoints(args[2])
				print("Gave: "..v:Name().." "..args[2].." points.")
			end
		end
	else
		print("You must be on the server console to run this")
	end
end


print(NullEntity():IsValid())

local function ps_sgivetest(ply, cmd, args)
	if !nent then
		print"works"
	end
end

concommand.Add("ps_sgive", ps_sgive)
concommand.Add("ps_sgivetest", ps_sgivetest)