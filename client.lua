local identifier = "pn-lb-vehiclehistory"
local QBCore = exports['qb-core']:GetCoreObject()

while GetResourceState("lb-phone") ~= "started" do
    Wait(500)
end

local function addApp()
    local added, errorMessage = exports["lb-phone"]:AddCustomApp({
        identifier = identifier, -- unique app identifier

        name = "Carnet Entretien",
        description = "Historique d'entretien des véhicules",
        developer = "Nico",

        defaultApp = false, --  set to true, the app will automatically be added to the player's phone
        size = 59812, -- the app size in kb
        -- price = 0, -- OPTIONAL make players pay with in-game money to download the app

        images = { -- OPTIONAL array of screenshots of the app, used for showcasing the app
            "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/assets/screenshot-light.png",
            "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/assets/screenshot-dark.png"
        },

        -- ui = "http://localhost:5500/" .. GetCurrentResourceName() .. "/ui/index.html",
        ui = GetCurrentResourceName() .. "/ui/index.html",

        icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/assets/icon.png",

        fixBlur = true -- set to true if you use em, rem etc instead of px in your css
    })

    if not added then
        print("Could not add app:", errorMessage)
    end
end

addApp()

AddEventHandler("onResourceStart", function(resource)
    if resource == "lb-phone" then
        addApp()
    end
end)

RegisterNUICallback("getOwnedVehicles", function(_, cb)
    QBCore.Functions.TriggerCallback('pn-lb-vehiclehistory:server:GetOwnedVehicles', function(list)
        cb(list or {})
    end)
end)

RegisterNUICallback("getHistoryByPlate", function(data, cb)
    local plate = data and data.plate or nil
    QBCore.Functions.TriggerCallback('pn-lb-vehiclehistory:server:GetHistoryByPlate', function(history)
        cb(history or {})
    end, plate)
end)

RegisterNUICallback("notify", function(data, cb)
    exports["lb-phone"]:SendNotification({
        app = identifier,
        title = data and data.title or "Carnet Entretien",
        content = data and data.message or ""
    })
    cb('ok')
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
