local wantedOpen = false
local wantedBlips = {}
local wantedPlayers = {}
local serverPlayerPedId

Citizen.CreateThread(function()
    local isBounty = false
    while true do
        Citizen.Wait(0)
        serverPlayerPedId = GetPlayerServerId(PlayerId())

        if IsEntityDead(PlayerPedId()) then

            --Citizen.Trace(tostring(wantedPlayers[serverPlayerPedId]) .. ' == ' .. tostring(serverPlayerPedId))

            if wantedPlayers[serverPlayerPedId] ~= serverPlayerPedId then
                
                Citizen.Wait(500)
                local PedKiller = GetPedSourceOfDeath(PlayerPedId())
    
                if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
                    Killer = NetworkGetPlayerIndexFromPed(PedKiller)
                end                
                
                if (Killer ~= PlayerId()) then
                    if (isBounty == false) then
                        TriggerServerEvent('addz_karmasystem:server_playerBounty',GetPlayerServerId(Killer))
                        isBounty = true
                    end
                    
                else
                    Citizen.Trace('Commited Suicide')
                end
            
                
            else
                Wait(60000) -- wait for a minute to wait for wanted player revive, please change according to your respawn time, or else the killer will be bounty
                wantedPlayers[serverPlayerPedId] = nil
            end
--[[     for entity, entityid in pairs(wantedPlayers) do
		if entity == killerid then
			wantedBlips[entity] = nil
        else
            Citizen.Trace('Entity : ' .. entity .. ' | ' .. 'KILLER PED ' .. entityid)
		end
	end ]]

        else
            
            isBounty = false
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('addz_karmasystem:client_setWantedBlip')
AddEventHandler('addz_karmasystem:client_setWantedBlip', function(killerid)

    Citizen.Trace('SERVER ID :' .. killerid)

    local killerPlayer = GetPlayerFromServerId(killerid)
    local killerPed = GetPlayerPed(killerPlayer)

    AddWantedPlayer(killerid, killerid)

    local blip = AddBlip(wantedBlips, killerPed, -700928964)

    SetBlipNameFromPlayerString(blip, 'Wanted Player ID ' .. killerid)
end)

RegisterNetEvent('addz_karmasystem:client_removeWantedBlip')
AddEventHandler('addz_karmasystem:client_removeWantedBlip', function(killerid)

    local killerPlayer = GetPlayerFromServerId(killerid)
    local killerPed = GetPlayerPed(killerPlayer)

    for entity, blip in pairs(wantedBlips) do
		if entity == killerPed then
			RemoveBlip(blip)
			wantedBlips[entity] = nil
        else
            Citizen.Trace('Entity : ' .. entity .. ' | ' .. 'KILLER PED ' .. killerPed)
		end
	end

end)

RegisterNetEvent('addz_karmasystem:client_setKarma')
AddEventHandler('addz_karmasystem:client_setKarma', function()
    Citizen.CreateThread(function()
        local bountyValue = ' BOUNTY : $' .. Config.Bounty
        wantedOpen = true
        SendNUIMessage({
            action = "setWanted",
            bounty  = bountyValue
        })
        --Citizen.Trace('WANTED OPEN')
        local timer = Config.Timer

        while (timer > 0) do
            Citizen.Wait(0)
            --Citizen.Trace('TIMER : ' .. timer)
            if IsEntityDead(PlayerPedId()) then
    
                Citizen.Wait(500)
                local PedBountyHunter = GetPedSourceOfDeath(PlayerPedId())
                local bountyHuntername = GetPlayerName(PedBountyHunter)
    
                if IsEntityAPed(PedBountyHunter) and IsPedAPlayer(PedBountyHunter) then
                    bountyHunter = NetworkGetPlayerIndexFromPed(PedBountyHunter)
                end
    
                if (bountyHunter ~= PlayerId()) then

                    timer = timer - timer
                    TriggerServerEvent('addz_karmasystem:server_bountyReward',GetPlayerServerId(bountyHunter), 1)

                    SendNUIMessage({
                        action = "wantedClose"
                    })
                    wantedOpen = false
                    wantedPlayers[PlayerPedId()] = nil
                else
                    Citizen.Trace('Commited Suicide')
                end
            else

                Citizen.Wait(1000)
                timer = timer - 1000
            end
        end
        
        if(timer < 1) then

            SendNUIMessage({
                action = "wantedClose"
            })
            wantedOpen = false
            wantedPlayers[PlayerPedId()] = nil

            TriggerServerEvent('addz_karmasystem:server_bountyReward',0, 2)
        end
    end)
    
end)

RegisterCommand('wanted', function(source, args, rawCommand)
    TriggerEvent('addz_karmasystem:client_setKarma')
end)

function AddWantedPlayer(playerid)

    if not wantedPlayers[playerid] or not DoesBlipExist(wantedPlayers[playerid]) then
		wantedPlayers[playerid] = playerid
		return playerid
    else
        return nil
	end
	
end

function AddBlip(table, entity, blipHash)
	if not table[entity] or not DoesBlipExist(table[entity]) then
		local blip = AddBlipForEntity(blipHash, entity)
		table[entity] = blip
        SetBlipSprite(blip, Config.WantedPlayerBlip, 1)
		return blip
    else
        return nil
	end
	
end

function AddBlipForEntity(blip, entity)
	return Citizen.InvokeNative(0x23f74c2fda6e7c61, blip, entity)
end

function SetBlipNameFromPlayerString(blip, playerString)
	Citizen.InvokeNative(0x9CB1A1623062F402 , blip, playerString)
end