config = {}

config.debug = false
config.command = 'polmenu' -- EDIT THIS TO CHANGE THE COMMAND NAME
config.removeCommand = 'axremove'
config.removeThreadTimeout = 30 -- in seconds

-- EDIT THIS TO CHANGE THE ACCESS TO THE COMMAND
config.hasAccess = function(source)
    return true  ---- note: if its true, everyone can use the command
end

config.noAccessMessage = "You do not have access to this command." -- EDIT THIS TO CHANGE THE NO ACCESS MESSAGE

config.spikesCode = "p_ld_stinger_s"

-- EDIT THIS LIST TO ADD OR REMOVE PROPS
config.props = {
    ["prop_roadcone01a"] = "Cone 1",
    ["prop_barrier_work04a"] = "Barrier 1",
    ["prop_barrier_work01a"] = "Barrier 2",
    ["prop_barrier_work06a"] = "Barrier 3",
    ["p_ld_stinger_s"]       = "Spikes"
}
config.rotationSpeed = 2.0 -- EDIT THIS TO CHANGE THE ROTATION SPEED OF THE PROPS
config.disableAiming = true -- EDIT THIS TO DISABLE AIMING WHILE PLACING PROPS
config.placeMessage = "You have placed a prop. Go near it and press E to remove it." -- EDIT THIS TO CHANGE THE MESSAGE THAT APPEARS WHEN YOU PLACE A PROP

-- EDIT THIS TO CHANGE THE BUTTONS TEXT AND KEYBINDS
config.buttons = {
    [1] = {buttonName = "Place prop", key = 24}, 
    [2] = {buttonName = "Cancel", key = 200},
    [3] = {buttonName = "Rotate right", key = 16},
    [4] = {buttonName = "Rotate left", key = 17},
}
