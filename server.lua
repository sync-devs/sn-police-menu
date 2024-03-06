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

RegisterCommand(config.command, function(source)
  if config.hasAccess() then
    TriggerClientEvent("sync-script:polmenu:open", source, config.props)
  else 
    TriggerClientEvent("sync-script:polmenu:notify", source, config.noAccessMessage)
  end
end)

local props = {}

RegisterNetEvent('ax:server:addProp',function (propData)
  if type(propData) ~= 'table' then return end

  props[#props+1] = propData
  TriggerClientEvent('ax:client:syncProps', -1, props)
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

