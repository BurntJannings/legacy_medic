Config = {}

Config.Locale = 'en'

Config.Bandage = 'Bandage'
Config.Revive = 'Morphine'
Config.Webhook = 'https://discord.com/api/webhooks/1000202324863627375/vFVEjxm-oQJ31CEdVqoqXEW3X9wWwiD1ZThKOIoM9u4ZSBEBt7_MK9OdIeTLWCZqlOPi'
Config.Command = 'medic'
Config.gonegative = 'false

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

Npcs = {
        val = {
            model = "mp_u_m_m_nat_farmer_01",
            Pos = {x = -765.25, y = -1258.38, z = 43.5, h = 355.3}, -- location 
                    --[[ jobs = {"police","doctor","marshal"},
            pay = 0.2, ]] -- work in progress
        },
        
    }

MedicJobs = {
    "doctor"
}


Config.doctors = {
    ped = 
    "mp_u_m_m_nat_farmer_01",

    command = "sendhelp",

    amount = 45,

    job = { "doctor" }
}


