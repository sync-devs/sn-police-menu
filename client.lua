-- SCALEFORMS
---@diagnostic disable: undefined-global

local CreateThread <const> = Citizen.CreateThread
local Wait <const>         = Citizen.Wait

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do Wait(1) end;

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, config.buttons[4].key, true))
    ButtonMessage(config.buttons[4].buttonName)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, config.buttons[3].key, true))
    ButtonMessage(config.buttons[3].buttonName)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, config.buttons[2].key, true))
    ButtonMessage(config.buttons[2].buttonName)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, config.buttons[1].key, true))
    ButtonMessage(config.buttons[1].buttonName)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(140)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

RegisterNetEvent("sync-script:polmenu:open", function(propList) 
    SendNUIMessage({act = "togMenu", props = propList}) 
    SetNuiFocus(true, true)
end)

local createdProps = {}

RegisterNetEvent('ax:client:syncProps', function(props)
    for _,v in pairs(props) do
        local x,y,z,heading = v.position.x, v.position.y, v.position.z, v.heading
        local propHash = GetHashKey(v.spawnCode)

        if not IsObjectNearPoint(propHash, x, y, z, 0.2) then
            local obj = CreateObject(propHash, x, y, z)

            SetEntityHeading(obj, heading)
            SetEntityCollision(obj, 1, 1)
            FreezeEntityPosition(obj, 1)
            SetEntityInvincible(obj, 1)

            local propData = {
                prop = obj,
                spawnCode = v.spawnCode,
                position = GetEntityCoords(obj),
                heading  = GetEntityHeading(obj)
            }

            table.insert(createdProps, propData)        -- --Ax-: Needs new table bcs the entityCode can differ on client side
        end
    end
end)

-- RegisterNetEvent("polmenu:selProp", function()
-- RegisterCommand("poltest", function(...)
RegisterNUICallback("polmenu:selProp", function(data, cb)
    CreateThread(function()
        SetNuiFocus(false, false)

        -- local testProp = "prop_barrier_work04a"
        local testProp = data.prop
        local buttons = setupScaleform("instructional_buttons")

        RequestModel(GetHashKey(testProp))
        while not HasModelLoaded(GetHashKey(testProp)) do Wait(1) end;

        local propObj = CreateObject(GetHashKey(testProp), (GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId())), false, false, false)
        SetEntityHeading(propObj, GetEntityHeading(PlayerPedId()))
        PlaceObjectOnGroundProperly(propObj)
        FreezeEntityPosition(propObj, true)
        SetEntityAsMissionEntity(propObj, true, true)
        SetEntityAlpha(propObj, 150, false)
        SetEntityCollision(propObj, false, false)

        while true do 
            DrawScaleformMovieFullscreen(buttons)

            DisableControlAction(0, config.buttons[1].key, true)
            DisableControlAction(0, config.buttons[2].key, true)
            DisableControlAction(0, config.buttons[3].key, true)
            DisableControlAction(0, config.buttons[4].key, true)

            if config.disableAiming then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisablePlayerFiring(PlayerPedId(), true)
            end

            SetEntityCoords(propObj, ((GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId())) - vector3(0.0, 0.0, 1.5)))
            PlaceObjectOnGroundProperly(propObj)

            if IsDisabledControlJustPressed(0, config.buttons[1].key) then

                local finalObj = CreateObject(GetHashKey(testProp), ((GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId())) - vector3(0.0, 0.0, 1.0)), true, false, false)
                SetEntityHeading(finalObj, GetEntityHeading(propObj))
                PlaceObjectOnGroundProperly(finalObj)
                FreezeEntityPosition(finalObj, true)
                SetEntityAsMissionEntity(finalObj, true, true)
                SetEntityAlpha(finalObj, 255, false)

                DeleteEntity(propObj)

                local propData = {
                    prop = finalObj,
                    spawnCode = data.prop,
                    position = GetEntityCoords(finalObj),
                    heading  = GetEntityHeading(propObj)
                }

                table.insert(createdProps, propData)

                TriggerServerEvent('ax:server:addProp', propData)

                SetNotificationTextEntry("STRING")
                AddTextComponentString(config.placeMessage)
                DrawNotification(false, false)
                break
            end

            if IsDisabledControlJustPressed(0, config.buttons[2].key) then
                DeleteEntity(propObj)
                break
            end

            if IsDisabledControlJustPressed(0, config.buttons[3].key) then
                SetEntityHeading(propObj, (GetEntityHeading(propObj) + config.rotationSpeed))
            end

            if IsDisabledControlJustPressed(0, config.buttons[4].key) then
                SetEntityHeading(propObj, (GetEntityHeading(propObj) - config.rotationSpeed))
            end

            Wait(1)
        end

    end)
end)


RegisterNetEvent('ax:client:giveRemoveAccess',function ()
    local hasRemoved = false
    local timeout = 0;
    local maxTimeout = config.removeThreadTimeout * 1000

    if #createdProps == 0 then
        return
    end

    CreateThread(function()
        local ticks = 1000
        while not hasRemoved and timeout < maxTimeout do 
            local playerCoords = GetEntityCoords(PlayerPedId())
    
            for k, v in pairs(createdProps) do 
                local propCoords = v.position
                local distance = #(playerCoords - propCoords)
    
                if distance < 1.5 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Press ~INPUT_PICKUP~ to remove this prop.")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
    
                    ticks = 1
                    DrawMarker(0, (propCoords + vector3(0.0, 0.0, 1.7)), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 50, true, true, 2, nil, nil, false)
                    if IsControlJustPressed(0, 38) then
                        DeleteEntity(v.prop)
                        table.remove(createdProps, k)
                        hasRemoved = true
                    end
                else
                    ticks = 1000
                end
            end

            timeout = timeout + ticks
            Wait(ticks)
        end
    end)
end)

local getClosestSpike <const> = function ()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current, dist, closestSpike

    for _, v in pairs(createdProps) do

        if v.spawnCode ~= config.spikesCode then
            goto skip
        end

        local spike = v.position

        if current == nil then
            dist = #(pos - vector3(spike.x, spike.y, spike.z))
            current = spikeID
        elseif current then
            if #(pos - vector3(spike.x, spike.y, spike.z)) < dist then
                current = spikeID
            end
        end
        
        closestSpike = spike

        ::skip::
    end

    return closestSpike
end

CreateThread(function ()
    while true do
        local ped = PlayerPedId()
        local ticks = 1000
        
        while IsPedInAnyVehicle(ped, true) do
            Wait(ticks)

            local vehicle = GetVehiclePedIsIn(ped, false)
            local closestSpike = getClosestSpike()

            if closestSpike then
                ticks = 1
                local spikePos = closestSpike

                if #(spikePos - GetEntityCoords(ped)) <= 10 then
                    local tires = {
                        {bone = "wheel_lf", index = 0},
                        {bone = "wheel_rf", index = 1},
                        {bone = "wheel_lm", index = 2},
                        {bone = "wheel_rm", index = 3},
                        {bone = "wheel_lr", index = 4},
                        {bone = "wheel_rr", index = 5},
                    }
     
                    for a = 1, #tires do
                        local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
     
                        if #(tirePos - spikePos) < 1.8 then
                            if not IsVehicleTyreBurst(vehicle, tires[a].index, false) then
                                SetVehicleTyreBurst(vehicle, tires[a].index, true, 1000.0)
                            end
                        end
                    end
                end
            else
                ticks = 1000
            end
        end

        Wait(ticks)
    end
end)


AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(createdProps) do 
            DeleteEntity(v.prop)
        end
    end
end)

CreateThread(function()
    print("SYNC SCRIPTS: POLICE MENU LOADED")
end)

RegisterNetEvent("sync-script:polmenu:notify", function(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end)