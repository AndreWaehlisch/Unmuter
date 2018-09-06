--Global port
Unmuter = {}

--set this to false to disable the addon temporarily - set it to true to re-enable it:
Unmuter.enabled = true

--define events
Unmuter.Events = {
	["UPDATE_BATTLEFIELD_STATUS"] = 1, --battleground and arena
	["LFG_PROPOSAL_SHOW"] = 1, --lfg tool
	["PARTY_INVITE_REQUEST"] = 1, --party invite
	["DUEL_REQUESTED"] = 1, --duel invite
	["READY_CHECK"] = 1, --ready check requested
	["CONFIRM_SUMMON"]= 1, --player is summoned
	["PET_BATTLE_QUEUE_PROPOSE_MATCH"] = 1, --pet battle invite
	["LFG_LIST_APPLICANT_UPDATED"] = 1, -- new lfg tool
	["GROUP_INVITE_CONFIRMATION"] = 1, -- someone requests to join party (e.g. from friend list)
}

Unmuter.standardUnmuteTime = 2 --in seconds

Unmuter.TimerFrame = CreateFrame("Frame")

Unmuter.Unmute = function(Soundtime, PlayNewSound)
	local LastUpdate = 0

	local AllSound_Old = GetCVar("Sound_EnableAllSound")
	local SFXSound_Old = GetCVar("Sound_EnableSFX")
		
	--unmute if sound is off
	if (AllSound_Old == "0") then
		SetCVar("Sound_EnableAllSound", 1)
	end
	if (SFXSound_Old == "0") then
		SetCVar("Sound_EnableSFX", 1)
	end
	
	--play "new" sound when sound was off
	if (SFXSound_Old == "0") or (AllSound_Old == "0") then
		if ( PlayNewSound == true ) then
			PlaySoundFile("Sound\\Interface\\iPlayerInviteA.ogg", "SFX")
		end
		Unmuter.TimerFrame:SetScript("OnUpdate", function(self, elapsed)
			LastUpdate = LastUpdate + elapsed
			if LastUpdate > Soundtime then
				--remute sound
				if (AllSound_Old == "0") then
					SetCVar("Sound_EnableAllSound", 0)
				end
				if (SFXSound_Old == "0") then
					SetCVar("Sound_EnableSFX", 0)
				end
				self:SetScript("OnUpdate", nil)
			end
		end)
	end
end

Unmuter.WasNotConfirm = {}
for i = 1, GetMaxBattlefieldID() do
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
					Unmuter.Unmute(Unmuter.standardUnmuteTime, true)
				end
			else
				Unmuter.WasNotConfirm[i] = true
			end
		end
	elseif ( event == "LFG_LIST_APPLICANT_UPDATED" ) then
			if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
				local apps = C_LFGList.GetApplicants()
				for i = 1, #apps do
					local _, _, _, _, isNew = C_LFGList.GetApplicantInfo(apps[i])
					if ( isNew ) then
						Unmuter.Unmute(2*Unmuter.standardUnmuteTime, false)
						return
					end
				end
			end
	else
		Unmuter.Unmute(Unmuter.standardUnmuteTime, true)
	end
end)