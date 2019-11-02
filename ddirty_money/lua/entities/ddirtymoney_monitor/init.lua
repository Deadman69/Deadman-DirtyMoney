AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "dirtymoney_config.lua" )
include( "dirtymoney_config.lua" )
include('shared.lua')

local percentage = DDirtyMoney.Percentage

util.AddNetworkString("DDirtyMoney:StartMonitor")
util.AddNetworkString("DDirtyMoney:SendNotifications")
util.AddNetworkString("DDirtyMoney:StartMinigame")
util.AddNetworkString("DDirtyMoney:MinigameEnded")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/computer_monitor.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	local pos = self:GetPos()
	if phys:IsValid() then
		phys:Wake()
	end
end


function ENT:Use( activator, caller, usetype, value )
	if (activator == caller) and (activator:IsPlayer()) and (activator:IsValid()) and activator:Alive() then
		if not DDirtyMoney.LaunderTeam[team.GetName( activator:Team() )] then return end
		local badMoney = activator:GetNWInt("Dirtymoney")
		local goodMoney = activator:getDarkRPVar("money")
		local moneyToGive = math.Round(badMoney*percentage)


		net.Start("DDirtyMoney:StartMonitor")
			net.WriteInt(moneyToGive, 32)
		net.Send(caller)

	end
end


net.Receive("DDirtyMoney:StartMinigame", function(len, ply)
	local difficulty = net.ReadInt(32)
	local moneyPlyRisk = tonumber(net.ReadInt(32))
	local value,timerValue,canPlay

	if DDirtyMoney.LaunderTeam[team.GetName( ply:Team() )] then

		if moneyPlyRisk <= tonumber(ply:GetNWInt("Dirtymoney")) then
			canPlay = true
		end

		if canPlay then

			if difficulty == 1 then -- Safe
				value = "easy"
				timerValue = DDirtyMoney.GameEasyTime
			elseif difficulty == 2 then -- Half Safe
				value = "half"
				timerValue = DDirtyMoney.GameHalfSafeTime
			else -- Risky
				value = "risky"
				timerValue = DDirtyMoney.GameRiskyTime
			end

			ply:SetNWInt("BadmoneyToBadBitch", tonumber(moneyPlyRisk))

			timer.Simple(0.3, function()
				net.Start("DDirtyMoney:StartMinigame")
					net.WriteString(value)
					net.WriteInt(timerValue, 32)
				net.Send(ply)
			end)

		else
			net.Start("DDirtyMoney:SendNotifications")
				net.WriteString("You have not enough money to send "..moneyPlyRisk.."$ to the Bahamas !")
			net.Send(ply)
		end
	else
		net.Start("DDirtyMoney:SendNotifications")
			net.WriteString("You don't have the knowlegde to send money to the Bahamas !")
		net.Send(ply)
	end
end)



net.Receive("DDirtyMoney:MinigameEnded", function(len, ply)
	local bool = net.ReadBool() -- If true, ply has win, else, he failed
	local int = net.ReadInt(32) -- Timer by default (for the difficulty)

	local moneyRisky = ply:GetNWInt("BadmoneyToBadBitch")

	if tonumber(ply:GetNWInt("Dirtymoney")) < tonumber(ply:GetNWInt("BadmoneyToBadBitch")) then
		bool = false
	end

	if int == DDirtyMoney.GameEasyTime then
		moneyRisky = moneyRisky*DDirtyMoney.GameEasyTax
	elseif int == DDirtyMoney.GameHalfSafeTime then
		moneyRisky = moneyRisky*DDirtyMoney.GameHalfSafeTax
	elseif int == DDirtyMoney.GameRiskyTime then
		moneyRisky = moneyRisky*DDirtyMoney.GameRiskyTax
	end

	if bool then

		ply:SetNWInt("Dirtymoney", ply:GetNWInt("Dirtymoney")-ply:GetNWInt("BadmoneyToBadBitch"))
		ply:addMoney(moneyRisky)

		net.Start("DDirtyMoney:SendNotifications")
			net.WriteString("You have transfer "..moneyRisky.."$ to the Bahamas !")
		net.Send(ply)

	else
		ply:SetNWInt("Dirtymoney", ply:GetNWInt("Dirtymoney")-ply:GetNWInt("BadmoneyToBadBitch"))

		net.Start("DDirtyMoney:SendNotifications")
			net.WriteString("You loose "..moneyRisky.."$ and the cops saw you !")
		net.Send(ply)

		if DDirtyMoney.IsWanted then
			ply:wanted(ply, "Illegal Transaction", DDirtyMoney.TimeWanted)
		end
	end

end)
