Config = {}

Config.Locale = 'en'

Config.Bandage = 'Bandage'  --Can change to an equivalent item in your database or run the items.sql, icon in items folder, remember case sensitive
Config.Revive = 'Morphine' --Can change to an equivalent item in your database or run the items.sql, icon in items folder, remember case sensitive
Config.Webhook = 'https://discord.com/api/webhooks/1000202324863627375/vFVEjxm-oQJ31CEdVqoqXEW3X9wWwiD1ZThKOIoM9u4ZSBEBt7_MK9OdIeTLWCZqlOPi'
Config.Command = 'medic' -- Slash command to use in chat to open Medic Menu
Config.gonegative = false -- Can you go negative paying for NPC revival
Config.synsociety = false
Config.Webhooklogo = "https://i.imgur.com/yourlink.png"
Config.Webhookname = "AIdoctor Log"
Doctoroffices = {
                val = {
                Pos = {x = -288.72, y = 808.83, z = 119.39}, -- location 
                },
                bw = {
                Pos = {x = -807.85, y = -1239.01, z = 43.56}, -- location 
                },
                straw = {
                Pos = {x = -1807.87, y = -430.77, z = 158.83}, -- location 
                },
                stdenis = {
                Pos = {x = 2722.84, y = -1229.48, z = 50.37}, -- location 
                },
    }

MedicJobs = {
    "doctor" -- Jobs that count as Doctors in order to use advanced medical options
}


Config.doctors = {
    ped = 
    "mp_u_m_m_nat_farmer_01", -- Model of NPC Doctor or choose other ped model below

  			--am_valentinedoctors_females_01
			--cs_sddoctor_01
			--cs_creoledoctor
			--u_m_m_rhddoctor_01
			--u_m_m_valdoctor_01
  
    command = "sendhelp", -- Command to Call for NPC Doctor

    amount = 45, -- Payment for Revive from NPC Doctor

    job = { "doctor" } -- Job that if found will count as Doctor job, notifying player a doc is available
}


