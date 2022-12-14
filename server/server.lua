local VorpCore = {}
local VORPInv = {}

local VORPInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore",function(core)
    VorpCore = core
end)
webhookURL = Config.Webhook;
Webhookname = Config.Webhookname;
Webhooklogo = Config.Webhooklogo;

local webhook = webhookURL
local name = Webhookname
local logo = Webhooklogo
RegisterServerEvent('legacy_calleAI', function(reason)
    local _source = source
    local playerName = GetPlayerName(_source)
    local playerIp = GetPlayerEndpoint(_source)
    local playerHex = GetPlayerIdentifier(_source)
    local identifiers = GetNumPlayerIdentifiers(_source)
    local steamIdentifier = GetPlayerIdentifiers(_source)[1]
    local playerDiscordTag = nil
    for _, identifier in ipairs(GetPlayerIdentifiers(_source)) do
        if identifier:match('discord') then
            playerDiscordTag = '<@' .. identifier:gsub('discord:', '') .. '>'
        end
    end
    local result = exports.oxmysql:executeSync("SELECT * FROM characters WHERE identifier = ?", { steamIdentifier })
    Wait(2000)
    if result then
        local characterName = result[1].firstname .. ' ' .. result[1].lastname
        local Called_AI = {
            {
                ["color"] = "000000",
                ["title"] = "Called the AI Doc",
                ["description"] = "Steam Name: *"..playerName.."*\nPlayer IP: *"..playerIp.."*\nPlayer Steam ID: *"..playerHex.."*\nPlayer's Discord: " .. playerDiscordTag .. "\nPlayer's character name: " .. characterName.. "\nPlayers ID:" .._source,
                ["footer"] = {
                    ["text"] = name,
                    ["icon_url"] = logo,
                },
            }
        }

        PerformHttpRequest(webhook, function (err, text, headers) end, 'POST', json.encode({username = name, embeds = Called_AI}), { ['Content-Type'] = 'application/json' })
    end
end)
RegisterServerEvent('legacy_medic:checkjob', function()
    print('working')
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local job = Character.job
    TriggerClientEvent('legacy_medic:sendjob',_source, job)
end)

RegisterServerEvent("legacy_medic:getalljob")
AddEventHandler("legacy_medic:getalljob", function()
    local _source = source
    local docs = 0
    for z, m in ipairs(GetPlayers()) do
        local User = VorpCore.getUser(m)
        local used = User.getUsedCharacter
          if CheckTable(Config.doctors.job, used.job) then
                    if Config.synsociety then
                    local duty = exports["syn_society"]:IsPlayerOnDuty(_source,used.job)
                        if duty then
                        docs = docs + 1
                        print(duty)
                        else
                        print(duty)
                        end
                    else
                    docs = docs + 1
                    end
            end 
        end

    if docs == 0 then
      TriggerClientEvent('legacy_medic:finddoc', _source)

    end

    if docs >= 1 then
      VorpCore.NotifyRightTip(_source,_U('doctoractive'),4000)
      end
end)

RegisterServerEvent('legacy_medic:takeitem', function(item,number)
    local _source = source
    VORPInv.addItem(_source, item, number) 
    VorpCore.NotifyRightTip(_source,_U('Received')..number.. _U('Of') ..item,4000)

end)

RegisterServerEvent("legacy_medic:reviveplayer")
AddEventHandler("legacy_medic:reviveplayer", function()
 
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local money = Character.money
if not Config.gonegative then
    if money >= Config.doctors.amount then
        Character.removeCurrency(0, Config.doctors.amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
        VorpCore.NotifyRightTip(_source,_U('revived')..Config.doctors.amount,4000)
    else
        VorpCore.NotifyRightTip(_source,_U('notenough')..Config.doctors.amount,4000)
    end
elseif Config.gonegative then
    Character.removeCurrency(0, Config.doctors.amount) -- Remove money 1000 | 0 = money, 1 = gold, 2 = rol
    VorpCore.NotifyRightTip(_source,_U('revived')..Config.doctors.amount,4000)
else
        VorpCore.NotifyRightTip(_source,_U('notenough')..Config.doctors.amount,4000)
end
end)

RegisterServerEvent('legacy_medic:reviveclosestplayer')
AddEventHandler('legacy_medic:reviveclosestplayer', function(closestPlayer)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local target = VorpCore.getUser(closestPlayer).getUsedCharacter
    local playname2 = target.firstname.. ' ' ..target.lastname
    local count = VORPInv.getItemCount(_source, Config.Revive)
    local playername = Character.firstname.. ' ' ..Character.lastname

    if count > 0 then
        VORPInv.subItem(_source, Config.Revive, 1)
        TriggerClientEvent('legacy_medic:revive', closestPlayer)
        if Config.usewebhook then
        VorpCore.AddWebhook(Config.WebhookTitle, Config.Webhook,  _U('Player_Syringe') ..playername.. _U('Used_Syringe') ..playname2)
        else
        end
    else
        VorpCore.NotifyRightTip(_source, _U('Missing') ..Config.Revive,4000)
    end
end)

RegisterServerEvent('legacy_medic:healplayer')
AddEventHandler('legacy_medic:healplayer', function(closestPlayer)
    print(closestPlayer)
    local _source = source
    local count = VORPInv.getItemCount(_source, Config.Bandage)
    if count > 0 then
        VORPInv.subItem(_source, Config.Bandage, 1)
        TriggerClientEvent('vorp:heal', closestPlayer)
    else
        VorpCore.NotifyRightTip(_source, _U('Missing') ..Config.Bandage,4000)
    end
end)

VORPInv.RegisterUsableItem(Config.Revive, function(data)
    TriggerClientEvent('legacy_medic:getclosestplayerrevive',data.source)
    VorpCore.NotifyRightTip(data.source, "You used " ..Config.Revive,4000)
  end)
  
  VORPInv.RegisterUsableItem(Config.Bandage, function(data)
    TriggerClientEvent('legacy_medic:getclosestplayerbandage',data.source)
    VorpCore.NotifyRightTip(data.source, "You used " ..Config.Bandage,4000)
  end)

  function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
  end
