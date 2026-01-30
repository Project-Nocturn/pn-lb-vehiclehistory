local QBCore = exports['qb-core']:GetCoreObject()

local function getIdentifier(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    return Player.PlayerData.citizenid
end

QBCore.Functions.CreateCallback('pn-lb-vehiclehistory:server:GetOwnedVehicles', function(source, cb)
    local cid = getIdentifier(source)
    if not cid then cb({}) return end
    local vehicles = MySQL.query.await("SELECT plate, `hash` FROM player_vehicles WHERE citizenid = ?", { cid }) or {}
    local list = {}
    for i = 1, #vehicles do
        local v = vehicles[i]
        list[#list+1] = {
            plate = v.plate,
            model = tonumber(v.hash)
        }
    end
    cb(list)
end)

QBCore.Functions.CreateCallback('pn-lb-vehiclehistory:server:GetHistoryByPlate', function(source, cb, plate)
    if type(plate) ~= "string" or plate == "" then
        cb({})
        return
    end
    local function trim(s)
        return s:gsub("^%s*(.-)%s*$", "%1")
    end
    local function nospace(s)
        return s:gsub("%s+", "")
    end
    local function resolveFakePlate(p)
        if GetResourceState("brazzers-fakeplates") ~= "started" then
            return false
        end
        local original = MySQL.scalar.await("SELECT plate FROM player_vehicles WHERE fakeplate = ?", { p })
        return original or false
    end
    local state = GetResourceState("jg-mechanic")
    if state ~= "started" then
        cb({})
        return
    end
    local variants = {}
    local p1 = trim(plate)
    local p2 = string.upper(p1)
    local p3 = nospace(p1)
    local p4 = nospace(p2)
    local pFake = resolveFakePlate(plate)
    if pFake then
        variants[#variants+1] = pFake
        variants[#variants+1] = trim(pFake)
        variants[#variants+1] = string.upper(trim(pFake))
        variants[#variants+1] = nospace(trim(pFake))
    end
    variants[#variants+1] = plate
    variants[#variants+1] = p1
    variants[#variants+1] = p2
    variants[#variants+1] = p3
    variants[#variants+1] = p4
    local found = {}
    for i = 1, #variants do
        local testPlate = variants[i]
        local ok, history = pcall(function()
            return exports["jg-mechanic"]:getVehicleServiceHistory(testPlate)
        end)
        if ok and history and type(history) == "table" and #history > 0 then
            found = history
            break
        end
    end
    if not found or #found == 0 then
        print(("[pn-lb-vehiclehistory] Aucun historique pour %s (jg-mechanic=%s)"):format(plate, state))
    end
    cb(found)
end)
