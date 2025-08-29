--Trancar portas    
function trancarPorta(model, coords, locked)
    local doorHash = GetHashKey(model)
    AddDoorToSystem(doorHash, doorHash, coords.x, coords.y, coords.z, false, false, false)
    DoorSystemSetDoorState(doorHash, locked and 1 or 0) -- 1 = trancado, 0 = destrancado
end