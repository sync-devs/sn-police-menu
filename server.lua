---@diagnostic disable: undefined-global
------------------------------------------------------
local debug <const> = function(...)
  if config.debug then
      local args = { ... }

      for i = 1, #args do
          local arg = args[i]
          args[i] = type(arg) == 'table' and json.encode(arg, { sort_keys = true, indent = true }) or tostring(arg)
      end

      print('^6[DEBUG] ^7', table.concat(args, '\t'))
  end
end
------------------------------------------------------
local props = {}

local findProp <const> = function (position)
  for index,v in pairs(props) do
    if #(v.position - position) < 0.1 then
      table.remove(props, index)
      return true
    end
  end

  return false
end

RegisterCommand(config.command, function(source)
  if config.hasAccess() then
    TriggerClientEvent("sync-script:polmenu:open", source, config.props)
  else 
    TriggerClientEvent("sync-script:polmenu:notify", source, config.noAccessMessage)
  end
end)


RegisterNetEvent('ax:server:addProp',function (propData)
  if type(propData) ~= 'table' then return end

  props[#props+1] = propData
  TriggerClientEvent('ax:client:syncProps', -1, props)
end)

RegisterNetEvent('ax:server:removeProp',function (propCoords)
  if findProp(propCoords) then
    TriggerClientEvent('ax:client:syncProps', -1, props)
  elseif config.debug then
    print("Unknown prop at coords: "..propCoords)
  end
end)

RegisterCommand(config.removeCommand,function (source)
  if config.hasAccess() then
    TriggerClientEvent('ax:client:giveRemoveAccess',source)
  else 
    TriggerClientEvent("sync-script:polmenu:notify", source, config.noAccessMessage)
  end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
    debug(props)
    TriggerClientEvent('ax:client:syncProps', source, props)
  end
end)

