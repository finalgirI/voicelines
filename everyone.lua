-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- https://lua.expert/
local t = {}
t.__index = t
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ModuleScripts = ReplicatedStorage.ModuleScripts
local PlayerScripts = Players.LocalPlayer.PlayerScripts
local v1 = ModuleScripts.Enums
local Janitor = require(ReplicatedStorage.Vendor.Janitor)
local v2 = require(script.Parent)
local ClientDebounce = require(PlayerScripts.ModuleScripts.ClientDebounce)
local TargetSystem = require(ModuleScripts.TargetSystem)
local TargetType = require(v1.TargetType)
local CompulsionList = require(ModuleScripts.FusionComponents.ScreenUtils.CompulsionList)
local CompulsionActionNames = require(v1.CompulsionActionNames)
local CharacterNames = require(v1.CharacterNames)
local SpecieType = require(ReplicatedStorage.ModuleScripts.Enums.SpecieType)
local AbilityService = ReplicatedStorage.Remotes.AbilityService
local AbilityActivated____ = AbilityService.ToServer.AbilityActivated____
local Abilities = PlayerScripts.Bindables.Abilities
local FusionStates = ReplicatedStorage.Bindables.FusionStates
local LocalPlayer = Players.LocalPlayer
local t2 = {}
local t3 = {
	[CompulsionActionNames.WalkAway] = script.WalkAway,
	[CompulsionActionNames.Sleep] = script.Sleep,
	[CompulsionActionNames.FollowMe] = script.FollowMe,
	[CompulsionActionNames.MakeInvisible] = script.MakeInvisible
}
local t4 = {
	[CharacterNames.MarcelGerard] = true,
	[CharacterNames.Luna] = true,
	[CharacterNames.Marina] = true,
	[CharacterNames.Raven] = true,
	[CharacterNames.TheGrinch] = true,
	[CharacterNames.TheDeer] = true,
	[CharacterNames.Elora] = true,
	[CharacterNames.Valeria] = true
}
local t5 = {
	[SpecieType.Mortal] = true,
	[SpecieType.Werewolf] = true,
	[SpecieType.Witch] = true
}
local t6 = {
	[SpecieType.Mortal] = true,
	[SpecieType.Werewolf] = true,
	[SpecieType.Witch] = true,
	[SpecieType.Hybrid] = true,
	[SpecieType.Heretic] = true,
	[SpecieType.Vampire] = true
}
local t7 = {
	[SpecieType.Mortal] = true,
	[SpecieType.Werewolf] = true,
	[SpecieType.Witch] = true,
	[SpecieType.Vampire] = true,
	[SpecieType.Hybrid] = true,
	[SpecieType.Heretic] = true,
	[SpecieType.Original] = true
}
function t.new(p1) --[[ Line: 78 | Upvalues: v2 (copy), t (copy), TargetSystem (copy), TargetType (copy) ]]
	local v1 = v2.new(p1)
	if v1 then
		setmetatable(v1, t)
		v1.raycastParams = RaycastParams.new()
		v1.raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		v1.raycastParams.FilterDescendantsInstances = { v1._character }
		v1.raycastParams.IgnoreWater = true
		v1.raycastParams.CollisionGroup = "RaycastExclusion"
		v1._targetSystem = TargetSystem.new(TargetType.Hitscan, v1)
		v1._janitor:Add(v1._targetSystem, "Destroy")
		return v1
	else
		return false
	end
end
function t.equip(p1) --[[ equip | Line: 96 | Upvalues: ClientDebounce (copy) ]]
	p1._janitor:Add(task.spawn(function() --[[ Line: 97 | Upvalues: ClientDebounce (ref), p1 (copy) ]]
		if ClientDebounce.isAlive(p1._name) then
			p1._janitor:Add(task.delay(ClientDebounce.getTimeLeft(p1._name), function() --[[ Line: 101 | Upvalues: p1 (ref) ]]
				p1:equip()
			end), true)
		else
			p1._targetSystem:Start()
		end
	end), true, "equip")
end
function t.unequip(p1) --[[ unequip | Line: 112 ]]
	if p1._janitor then
		p1._janitor:Destroy()
		p1._janitor = nil
	end
end
function t.activated(p1) --[[ activated | Line: 119 | Upvalues: ClientDebounce (copy), v2 (copy), Players (copy), LocalPlayer (copy), t4 (copy), t7 (copy), SpecieType (copy), t6 (copy), t5 (copy), FusionStates (copy), Abilities (copy), AbilityActivated____ (copy) ]]
	if ClientDebounce.set(p1._name, p1._timeout) then
		local v1 = p1._targetSystem and p1._targetSystem:GetTargetInfo()
		if v1 and v2.canBeAffected(Players:GetPlayerFromCharacter(v1) or v1.Name, p1._name) then
			local v3 = LocalPlayer:GetAttribute("CharacterName")
			local v4 = p1._character:GetAttribute("SpecieType")
			local v5 = v1:GetAttribute("SpecieType")
			local v6 = false
			if t4[v3] then
				if not t7[v5] then
					v6 = true
				end
			elseif v4 == SpecieType.Original or v4 == SpecieType.Tribrid then
				if not t6[v5] then
					v6 = true
				end
			elseif not t5[v5] then
				v6 = true
			end
			if v6 then
				FusionStates.SetNotification:Fire("You can\'t compel this specie!")
				ClientDebounce.kill(p1._name)
			else
				Abilities.AbilityActivated:Fire(p1._name)
				AbilityActivated____:FireServer(v1)
				p1._targetSystem:Stop()
				p1._janitor:Add(task.delay(ClientDebounce.getTimeLeft(p1._name), function() --[[ Line: 161 | Upvalues: p1 (copy) ]]
					p1:equip()
				end), true)
			end
			return
		end
		ClientDebounce.kill(p1._name)
	end
end
function t.deactivate(p1) --[[ deactivate | Line: 167 ]] end
function t.begin(p1, p2) --[[ begin | Line: 171 | Upvalues: t2 (copy), Janitor (copy), CompulsionList (copy), AbilityService (copy) ]]
	if t2[p1] then
		t2[p1]:Destroy()
		t2[p1] = nil
	end
	local v1 = Janitor.new()
	t2[p1] = v1
	CompulsionList:show(v1, p2, function(p12) --[[ Line: 180 | Upvalues: CompulsionList (ref), AbilityService (ref), p1 (copy) ]]
		CompulsionList:hide()
		AbilityService.ToServer.BeginAbility:FireServer(p1, p12)
	end)
end
function t.stop() --[[ stop | Line: 186 | Upvalues: CompulsionList (copy) ]]
	if CompulsionList then
		CompulsionList:hide()
	end
end
function t.applyAction(p1, p2, p3) --[[ applyAction | Line: 192 | Upvalues: t3 (copy) ]]
	if t3[p1] then
		t3[p1][p2](p3)
	end
end
function t.init() --[[ init | Line: 199 | Upvalues: t (copy), v2 (copy), t3 (copy) ]]
	setmetatable(t, v2)
	for v3, v4 in t3 do
		t3[v3] = require(v4)
		require(v4).init()
	end
end
return t
