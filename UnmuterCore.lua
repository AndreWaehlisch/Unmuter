-- Global port
Unmuter = {}

-- set this to false to disable the addon temporarily - set it to true to re-enable it:
Unmuter.enabled = true

--define events
Unmuter.Events = {
	["UPDATE_BATTLEFIELD_STATUS"] = 1, -- battleground and arena
	["PARTY_INVITE_REQUEST"] = 1, -- party invite
	["DUEL_REQUESTED"] = 1, -- duel invite
	["READY_CHECK"] = 1, -- ready check requested
	["CONFIRM_SUMMON"]= 1, -- player is summoned
	["GROUP_INVITE_CONFIRMATION"] = 1, -- someone requests to join party (e.g. from friend list)
}

Unmuter.standardUnmuteTime = 2 -- in seconds

Unmuter.TimerFrame = CreateFrame("Frame")

Unmuter.Unmute = function()
	-- store current settings for "Enable Sound"
	local AllSound_Old = GetCVar("Sound_EnableAllSound")

	-- turn on "Enable Sound"
	if ( AllSound_Old == "0" ) then
		local LastUpdate = 0
		SetCVar("Sound_EnableAllSound", 1)
		Unmuter.TimerFrame:SetScript("OnUpdate", function(self, elapsed)
			LastUpdate = LastUpdate + elapsed
			if LastUpdate > Unmuter.standardUnmuteTime then
				-- remute sound
				if (AllSound_Old == "0") then
					SetCVar("Sound_EnableAllSound", 0)
				end

				self:SetScript("OnUpdate", nil)
			end
		end)
	end
end

Unmuter.WasNotConfirm = {}
for i = 1, MAX_BATTLEFIELD_QUEUES do
	Unmuter.WasNotConfirm[i] = true
end

Unmuter.EventFrame = CreateFrame("Frame")

for i in pairs(Unmuter.Events) do
	Unmuter.EventFrame:RegisterEvent(i)
end

Unmuter.EventFrame:SetScript("OnEvent", function(self,event,...)
	if not Unmuter.enabled then
		return
	end

	if ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		for i = 1, GetMaxBattlefieldID() do
			if ( GetBattlefieldStatus(i) == "confirm" ) then
				if Unmuter.WasNotConfirm[i] then
					Unmuter.WasNotConfirm[i] = false
					Unmuter.Unmute()
					PlaySoundFile("Sound\\Interface\\iPlayerInviteA.ogg", "Master")
				end
			else
				Unmuter.WasNotConfirm[i] = true
			end
		end
	else
		Unmuter.Unmute()
		PlaySoundFile("Sound\\Interface\\iPlayerInviteA.ogg", "Master")
	end
end)