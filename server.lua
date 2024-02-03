RegisterCommand(config.command, function(source)
  if config.hasAccess() then
    TriggerClientEvent("sync-script:polmenu:open", source, config.props)
  else 
    TriggerClientEvent("sync-script:polmenu:notify", source, config.noAccessMessage)
  end
end)