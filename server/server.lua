local VorpCore = {}
local VORPInv = {}

local VORPInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

local Needs = {}

TriggerEvent("Outsider_Needs", function(cb) -- to use in server only for security
    Needs = cb
end)

local table = {
    food = 25,
    water = 25,
    health = 25,
}


local stafftable = {}

RegisterServerEvent('legacy_medic:checkjob', function()
    print('working')
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local job = Character.job
    TriggerClientEvent('legacy_medic:sendjob', _source, job)
end)

---@param table table
---@param job string
---@return boolean

local CheckPlayer = function(table, job)

    for _, jobholder in pairs(table) do
        local onduty = exports["syn_society"]:IsPlayerOnDuty(jobholder, job)
        print(onduty)
        return onduty
    end

    return false
end

RegisterServerEvent("legacy_medicalertjobs", function()
    local _source = source
    local docs = 0
    if Config.synsociety then
        if CheckPlayer(stafftable, MedicJobs[1]) or CheckPlayer(stafftable, MedicJobs[2]) then
            VorpCore.NotifyRightTip(_source, _U('doctoractive'), 4000)
        else
            TriggerClientEvent('legacy_medic:finddoc', _source)
        end
    else
        for z, m in ipairs(GetPlayers()) do
            local User = VorpCore.getUser(m)
            local used = User.getUsedCharacter
            if CheckTable(MedicJobs, used.job) then
                docs = docs + 1

            end
            if docs < 1 then
                TriggerClientEvent('legacy_medic:finddoc', _source)
            end
        end


    end

end)

RegisterServerEvent("legacy_medic:sendPlayers", function(source)
    local _source = source
    local user = VorpCore.getUser(_source).getUsedCharacter
    local job = user.job -- player job

    if CheckTable(MedicJobs, job) then
        stafftable[#stafftable + 1] = _source -- id
    end
end)

AddEventHandler('playerDropped', function()
    local _source = source
    for index, value in pairs(stafftable) do
        if value == _source then
            stafftable[index] = nil
        end
    end
end)

RegisterServerEvent('legacy_medic:takeitem', function(item, number)
    local _source = source
    VORPInv.addItem(_source, item, number)
    VorpCore.NotifyRightTip(_source, _U('Received') .. number .. _U('Of') .. item, 4000)

end)

RegisterServerEvent("legacy_medic:reviveplayer")
AddEventHandler("legacy_medic:reviveplayer", function()

    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local money = Character.money
    if not Config.gonegative then
        if money >= Config.doctors.amount then
            Character.removeCurrency(0, Config.doctors.amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
            VorpCore.NotifyRightTip(_source, _U('revived') .. Config.doctors.amount, 4000)
            TriggerClientEvent('legacy_medic:revive', _source)
            Needs.addStats(_source, table) -- send as a table
        else
            VorpCore.NotifyRightTip(_source, _U('notenough') .. Config.doctors.amount, 4000)
        end
    elseif Config.gonegative then
        Character.removeCurrency(0, Config.doctors.amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
        VorpCore.NotifyRightTip(_source, _U('revived') .. Config.doctors.amount, 4000)
        TriggerClientEvent('legacy_medic:revive', _source)
        Needs.addStats(_source, table) -- send as a table
    else
        VorpCore.NotifyRightTip(_source, _U('notenough') .. Config.doctors.amount, 4000)
    end
end)

RegisterServerEvent('legacy_medic:reviveclosestplayer')
AddEventHandler('legacy_medic:reviveclosestplayer', function(closestPlayer)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local target = VorpCore.getUser(closestPlayer).getUsedCharacter
    local playname2 = target.firstname .. ' ' .. target.lastname
    local count = VORPInv.getItemCount(_source, Config.Revive)
    local playername = Character.firstname .. ' ' .. Character.lastname

    if count > 0 then
        VORPInv.subItem(_source, Config.Revive, 1)
        TriggerClientEvent('legacy_medic:revive', closestPlayer)
        Needs.addStats(_source, table) -- send as a table
        if Config.usewebhook then
            VorpCore.AddWebhook(Config.WebhookTitle, Config.Webhook,
                _U('Player_Syringe') .. playername .. _U('Used_Syringe') .. playname2)
        else
        end
    else
        VorpCore.NotifyRightTip(_source, _U('Missing') .. Config.Revive, 4000)
    end
end)

RegisterServerEvent('legacy_medic:healplayer')
AddEventHandler('legacy_medic:healplayer', function(closestPlayer)
    print(closestPlayer)
    local _source = source
    local count = VORPInv.getItemCount(_source, Config.Bandage)
    if count > 0 then
        TriggerClientEvent('vorp:heal', closestPlayer)
    else
        VorpCore.NotifyRightTip(_source, _U('Missing') .. Config.Bandage, 4000)
    end
end)

VORPInv.RegisterUsableItem(Config.Revive, function(data)
    local _source = data.source -- the player that is using the item
    local user = VORPcore.getUser(_source).getUsedCharacter -- get user 
    local job = user.job
    if CheckTable(MedicJobs, job) then
        TriggerClientEvent('legacy_medic:getclosestplayerrevive', _source)
        VORPInv.subItem(_source, Config.Revive, 1)
        VORPcore.NotifyRightTip(_source, "You used " .. Config.Revive, 4000)
    else
        VORPcore.NotifyRightTip(_source, "dont have the job", 4000)

    end

end)

VORPInv.RegisterUsableItem(Config.Bandage, function(data)
    TriggerClientEvent('legacy_medic:getclosestplayerbandage', data.source)
    VorpCore.NotifyRightTip(data.source, "You used " .. Config.Bandage, 4000)
end)

function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end
