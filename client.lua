-- SCALEFORMS

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

-- MAIN THREAD
local createdProps = {}

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
            -- SetEntityHeading(propObj, GetEntityHeading(PlayerPedId()))
            PlaceObjectOnGroundProperly(propObj)

            if IsDisabledControlJustPressed(0, config.buttons[1].key) then

                local finalObj = CreateObject(GetHashKey(testProp), ((GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId())) - vector3(0.0, 0.0, 1.0)), true, false, false)
                SetEntityHeading(finalObj, GetEntityHeading(propObj))
                PlaceObjectOnGroundProperly(finalObj)
                FreezeEntityPosition(finalObj, true)
                SetEntityAsMissionEntity(finalObj, true, true)
                SetEntityAlpha(finalObj, 255, false)

                DeleteEntity(propObj)

                table.insert(createdProps, finalObj)

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

CreateThread(function()
    local ticks = 800
    while true do 
        local playerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(createdProps) do 
            local propCoords = GetEntityCoords(v)
            local distance = #(playerCoords - propCoords)

            if distance < 1.5 then
                -- left corner notify 
                SetTextComponentFormat("STRING")
                AddTextComponentString("Press ~INPUT_PICKUP~ to remove this prop.")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                
                ticks = 1
                DrawMarker(0, (propCoords + vector3(0.0, 0.0, 1.7)), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 50, true, true, 2, nil, nil, false)
                if IsControlJustPressed(0, 38) then
                    DeleteEntity(v)
                    table.remove(createdProps, k)
                    ticks = 800
                end
            end
        end

        Wait(ticks)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(createdProps) do 
            DeleteEntity(v)
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