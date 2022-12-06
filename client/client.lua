local healthcheck = false
local lastwound = _U('None')
local createdped = 0
local damagebone = _U('None')
local damageboneself = _U('None')
local Playerjob
local amount 
local close
local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)


local PromptGorup = GetRandomIntInRange(0, 0xffffff)

function SetupUsePrompt()
        local str = 'Use'
        UsePrompt = PromptRegisterBegin()
        PromptSetControlAction(UsePrompt, 0xC7B5340A)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(UsePrompt, str)
        PromptSetEnabled(UsePrompt, true)
        PromptSetVisible(UsePrompt, true)
        PromptSetHoldMode(UsePrompt, true)
        PromptSetGroup(UsePrompt, PromptGorup)
        PromptRegisterEnd(UsePrompt)
end

Citizen.CreateThread(function()
	SetupUsePrompt()
	while true do
		Wait(0)
		local ped = PlayerPedId()
        local pedpos = GetEntityCoords(PlayerPedId(), true)
        for k,v in pairs(Doctoroffices) do
            local distance = GetDistanceBetweenCoords(v.Pos.x, v.Pos.y, v.Pos.z, pedpos.x, pedpos.y, pedpos.z, false)
            if distance <= 1.0 then
		if not IsEntityDead(ped) then
                local item_name = CreateVarString(10, 'LITERAL_STRING', _U('Open_Cabinet'))
                PromptSetActiveGroupThisFrame(PromptGorup, item_name)
			if Citizen.InvokeNative(0xC92AC953F0A982AE, UsePrompt) then
				TriggerServerEvent('legacy_medic:checkjob')
				  Wait(2000)
					if CheckTable(MedicJobs,Playerjob) then 
                    			CabinetMenu()				
					else
					VORPcore.NotifyRightTip(_U('you_do_not_have_job'),4000)		
                			end
			end
            	else
		Wait(500)
		end
		else
		Wait(500)
		end
        end
	end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Doctoroffices) do
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.x, v.y, v.z)
        SetBlipSprite(blip, -695368421, 1)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, _U('Map_Blip'))
    end
end)

function RevivePlayer(playerPed)
    local closestPlayerPed = GetPlayerPed(playerPed)
    if IsPedDeadOrDying(closestPlayerPed, 1) then
        local dic = "mech_revive@unapproved"
        local anim = "revive"
        loadAnimDict(dic)
        TaskPlayAnim(PlayerPedId(), dic, anim, 1.0, 8.0, 2000, 31, 0, true, true, false, false, true)
        Wait(2000)
        ClearPedTasksImmediately(PlayerPedId())
        TriggerServerEvent('legacy_medic:reviveclosestplayer', GetPlayerServerId(playerPed))
    else
		VORPcore.NotifyRightTip(_U('player_not_unconscious'),4000)
    end
end

function SpawnNPC()

	local model = GetHashKey(Config.doctors.ped)
					RequestModel(model)
					if not HasModelLoaded(model) then 
						RequestModel(model) 
					end
					while not HasModelLoaded(model) or HasModelLoaded(model) == 0 or model == 1 do
						Citizen.Wait(1) 
					end
    for k, v in pairs(Config.doctors) do

  	local coords = GetEntityCoords(PlayerPedId())
        local randomAngle = math.rad(math.random(0, 360))
        local x = coords.x + math.sin(randomAngle) * math.random(1, 100) * 0.5
        local y = coords.y + math.cos(randomAngle) * math.random(1, 100) * 0.5 -- End Number multiplied by is radius to player
        local z = coords.z
        local b, rdcoords, rdcoords2 = GetClosestVehicleNode(coords.x, coords.y, coords.z, 1, 10.0, 10.0)
        if (rdcoords.x == 0.0 and rdcoords.y == 0.0 and rdcoords.z == 0.0) then
            local valid, outPosition = GetSafeCoordForPed(x, y, z, false, 8)
            if valid then
                x = outPosition.x
                y = outPosition.y
                z = outPosition.z
            end
        else
            local inwater = Citizen.InvokeNative(0x43C851690662113D, createdped, 100)
            if inwater then
             DeleteEntity(createdped)
             VORPcore.NotifyRightTip(_U('inwater'),4000)
            end
            local valid, outPosition = GetSafeCoordForPed(x, y, z, false, 16)
            if valid then
                x = outPosition.x
                y = outPosition.y
                z = outPosition.z
            end

            local foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(x, y, z)
            if foundground then
                z = groundZ
            else
                VORPcore.NotifyRightTip(_U('missground'),4000)
                DeleteEntity(createdped)
            end
        end

					if createdped == 0 then
						createdped = CreatePed(model, x+2.0, y, z ,true, true, true, true)
						Wait(500)
                    else
                        DeleteEntity(createdped)
                        VORPcore.NotifyRightTip(_U('doctordied'),4000)
                        createdped = 0
					end

					Citizen.InvokeNative(0x283978A15512B2FE, createdped, true) 

                    local ped = PlayerPedId()    
                    FreezeEntityPosition(createdped, false)
                    Citizen.InvokeNative(0x923583741DC87BCE, createdped, "default")
                    TaskGoToEntity(createdped, ped, -1, 2.0, 5.0, 1073741824, 1)
                    Wait(0)
                    while createdped do 
                        local pcoords = GetEntityCoords(PlayerPedId())
                        local tcoords = GetEntityCoords(createdped)
                        local distance = Vdist2(pcoords.x,pcoords.y,pcoords.z,tcoords.x,tcoords.y,tcoords.z)
                        Wait(0)
                        if distance < 5 then       
                            if createdped then 
                            Wait(5000)
                            DeleteEntity(createdped)
			TriggerServerEvent('legacy_medic:reviveplayer', source)
                            end
                        end

                    end
    end
end

RegisterNetEvent('legacy_medic:finddoc')
AddEventHandler('legacy_medic:finddoc', function(docs)
    if IsEntityDead(PlayerPedId()) then
        VORPcore.NotifyRightTip(_U('calldoctor'),4000)
        SpawnNPC()
    else
        VORPcore.NotifyRightTip(_U('notdead'),4000)
    end
end)

RegisterNetEvent('legacy_medic:getclosestplayerrevive', function ()
	local closestPlayer, closestDistance = GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
	RevivePlayer(closestPlayer)
	else 
	VORPcore.NotifyRightTip(_U('not_near_player'),4000)
	end
end)

RegisterNetEvent('legacy_medic:reviveclosest')
AddEventHandler('legacy_medic:reviveclosest', function(closestPlayer)

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
		Citizen.Wait(50)
    end
    
    Citizen.Wait(1200)
    TriggerEvent('vorp:resurrectPlayer', closestPlayer)
    DoScreenFadeIn(800)
end)

RegisterNetEvent('legacy_medic:getclosestplayerbandage', function ()
	local ped = PlayerPedId()
	local pedcoords = GetEntityCoords(ped)
	local closestPlayer, closestDistance = GetClosestPlayer()
	local closestPlayerPed = GetPlayerPed(closestPlayer)
	local closestPlayerCoords = GetEntityCoords(closestPlayer, true)

	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerServerEvent('legacy_medic:healplayer', GetPlayerServerId(closestPlayer))
	else 
		VORPcore.NotifyRightTip(_U('not_near_player'),4000)
	end
end)

RegisterNetEvent('legacy_medic:sendjob', function (job)
	Playerjob = job
end)

RegisterCommand(Config.Command, function(source, args)

	TriggerServerEvent('legacy_medic:checkjob')
	if CheckTable(MedicJobs,Playerjob) then 
	DoctorMenu()
	else
	MedicMenu()
	end
end)

RegisterCommand(Config.doctors.command,function(source)
	TriggerServerEvent("legacy_medic:getalljob")		
end)

MenuData = {}
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)

function MedicMenu() -- Base Police Menu Logic
	MenuData.CloseAll()

	local ped = PlayerPedId()
	local pedcoords =  GetEntityCoords(ped)
	local health = GetEntityHealth(ped)
	local pulse = health / 5 + math.random(20,30)
	
	
	local closestPlayer,closestDistance = GetClosestPlayer()
	local closestPlayerPed = GetPlayerPed(closestPlayer)
	local patienthealth = GetEntityHealth(closestPlayer)
	local patientpulse = patienthealth / 5 + math.random(20,30)

	local closesthit, closestbone = GetPedLastDamageBone(closestPlayerPed)
	local hit, bone = GetPedLastDamageBone(PlayerPedId())
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerEvent("legacy_medic:checkpartother", closestbone)
	else
	end
	Wait(1000)
	TriggerEvent("legacy_medic:checkpart", bone)

	local elements = {
		{label = _U('Pulse') ..pulse, value = 'pulse' , desc = _U('Pulse')},
		{label = _U('ClosestInjury') ..damagebone, value = 'lastwound' , desc = _U('ClosestInjuryDesc') ..damagebone},
		{label = _U('CheckInjury') ..damageboneself, value = 'lastwoundself' , desc = _U('CheckInjuryDesc') ..damageboneself},

	}

   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = _U('MedicMenu'),
		subtext    = _U('MenuDesc'),
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
		
	if (data.current.value == 'lastwound') then 
		if closestPlayer ~= -1 and closestDistance <= 3.0 then

			if healthcheck == false then
				healthcheck = true 
			  hit, closestbone = GetPedLastDamageBone(closestPlayerPed)
				TriggerEvent("legacy_medic:checkpartother", closestbone)
			else
				healthcheck = false
			end

		else
		end
		MedicMenu()
	end
		if (data.current.value == 'lastwoundself') then
			if healthcheck == false then
				healthcheck = true 
			  hit, bone = GetPedLastDamageBone(PlayerPedId())
				TriggerEvent("legacy_medic:checkpart", bone)
			else
				healthcheck = false
			end
			MedicMenu()

		end
	end,
	function(data, menu)
		damagebone = _U('None')
		damageboneself = _U('None')
		menu.close()
	end)
end

function DoctorMenu() -- Base Police Menu Logic
	MenuData.CloseAll()


	local ped = PlayerPedId()
	local pedcoords =  GetEntityCoords(ped)
	local health = GetEntityHealth(ped)
	local pulse = health / 4 + math.random(20,30)
	
	
	local closestPlayer,closestDistance = GetClosestPlayer()
	local closestPlayerPed = GetPlayerPed(closestPlayer)
	local patienthealth = GetEntityHealth(closestPlayerPed)
	local patientpulse = patienthealth / 4 + math.random(20,30)

	local closesthit, closestbone = GetPedLastDamageBone(closestPlayerPed)
	local hit, bone = GetPedLastDamageBone(PlayerPedId())
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerEvent("legacy_medic:checkpartother", closestbone)
	else
	end
	Wait(1000)
	TriggerEvent("legacy_medic:checkpart", bone)

		local elements = {
			{label = _U('PatientPulse') ..patientpulse, value = 'patientpulse' , desc = _U('PatientPulse')..patientpulse},
			{label = _U('Pulse') ..pulse, value = 'pulse' , desc = _U('Pulse')},
			{label = _U('ClosestInjury') ..damagebone, value = 'lastwound' , desc = _U('ClosestInjuryDesc') ..damagebone},
			{label = _U('CheckInjury') ..damageboneself, value = 'lastwoundself' , desc = _U('CheckInjuryDesc') ..damageboneself},
	
		}

   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = _U('MedicMenu'),
		subtext    = _U('MenuDesc'),
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
		
	if (data.current.value == 'lastwound') then 
		if closestPlayer ~= -1 and closestDistance <= 3.0 then

			if healthcheck == false then
				healthcheck = true 
			  hit, closestbone = GetPedLastDamageBone(closestPlayerPed)
				TriggerEvent("legacy_medic:checkpartother", closestbone)
			else
				healthcheck = false
			end

		else
		end
		DoctorMenu()
	end
		if (data.current.value == 'lastwoundself') then
			if healthcheck == false then
				healthcheck = true 
			  hit, bone = GetPedLastDamageBone(PlayerPedId())
				TriggerEvent("legacy_medic:checkpart", bone)
			else
				healthcheck = false
			end
			DoctorMenu()

		end
	end,
	function(data, menu)
		damagebone = _U('None')
		damageboneself = _U('None')
		menu.close()
	end)
end

function CabinetMenu() -- Base Police Menu Logic
	MenuData.CloseAll()

	local elements = {
		{label = _U('Bandage'), value = 'takebandage' , desc = _U('TakeBandage')},
		{label = _U('Stim'), value = 'takestim' , desc = _U('TakeStim')},
	}

	
	local myInput = {
		type = "enableinput", -- don't touch
		inputType = "input", -- input type
		button = _U('Button'), -- button name
		placeholder = _U('Placeholder'), -- placeholder name
		style = "block", -- don't touch
		attributes = {
			inputHeader = _U('Amount'), -- header
			type = "text", -- inputype text, number,date,textarea ETC
			pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
			title = _U('NumOnly'), -- if input doesnt match show this message
			style = "border-radius: 10px; background-color: ; border:none;"-- style 
		}
	}

   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = _U('CabinetMenu'),
		subtext    = _U('CabinetDesc'),
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
		
		if (data.current.value == 'takebandage') then 

			TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
		
				if result ~= "" or result then -- making sure its not empty or nil
					TriggerServerEvent('legacy_medic:takeitem',Config.Bandage,result)
				else
					print("its empty?") -- notify
				end
			end)

		end

		if (data.current.value == 'takestim') then 

			TriggerEvent("vorpinputs:advancedInput", json.encode(myInput), function(result)
		
				if result ~= "" or result then -- making sure its not empty or nil
					TriggerServerEvent('legacy_medic:takeitem',Config.Revive,result)
				else
					print("its empty?") -- notify
				end
			end)

		end

	end,

	function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("legacy_medic:checkpart")
AddEventHandler("legacy_medic:checkpart", function(bone)
		if bone == 21030 then 
			damageboneself = _U('Head')
	elseif bone == 6884 or bone == 43312 then
		damageboneself =_U('RightLeg')
	elseif bone == 65478 or bone == 55120 or bone == 45454 then
		damageboneself = _U('LeftLeg')
			elseif bone == 14411 or bone == 14410 then
				damageboneself = _U('Stomach')
		elseif bone == 14412 then
			damageboneself = _U('Stomach_Chest')
		elseif bone == 14414 then
			damageboneself = _U('Chest')
		elseif bone == 54187 or bone == 46065 then
			damageboneself = _U('RightArm')
		elseif bone == 37873 or bone == 53675 then
			damageboneself = _U('LeftArm')
		elseif bone == 54802 then
			damageboneself = _U('RightShoulder')
		elseif bone == 30226 then
			damageboneself = _U('LeftShoulder')
		elseif bone == 56200 then
			damageboneself = _U('Pelvis')
			elseif bone == 0 then
				damageboneself ="None"
		end
end) 

RegisterNetEvent("legacy_medic:checkpartother")
AddEventHandler("legacy_medic:checkpartother", function(bone)
	if bone == 21030 then 
		damagebone = _U('Head')
	elseif bone == 6884 or bone == 43312 then
	damagebone =_U('RightLeg')
	elseif bone == 65478 or bone == 55120 or bone == 45454 then
	damagebone = _U('LeftLeg')
		elseif bone == 14411 or bone == 14410 then
			damagebone = _U('Stomach')
	elseif bone == 14412 then
		damagebone = _U('Stomach_Chest')
	elseif bone == 14414 then
		damagebone = _U('Chest')
	elseif bone == 54187 or bone == 46065 then
		damagebone = _U('RightArm')
	elseif bone == 37873 or bone == 53675 then
		damagebone = _U('LeftArm')
	elseif bone == 54802 then
		damagebone = _U('RightShoulder')
	elseif bone == 30226 then
		damagebone = _U('LeftShoulder')
	elseif bone == 56200 then
		damagebone = _U('Pelvis')
		elseif bone == 0 then
			damagebone ="None"
	end
end) 

RegisterNetEvent("legacy_medic:revive")
AddEventHandler("legacy_medic:revive", function()
    TriggerEvent('vorp:resurrectPlayer', source)
end)

function GetPlayers()
	local players = {}
	for i = 0, 256 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, GetPlayerServerId(i))
		end
	end
	return players
end

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false
    
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end
    
    for i=1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

function CheckTable(table, element) --Job checking table
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end
