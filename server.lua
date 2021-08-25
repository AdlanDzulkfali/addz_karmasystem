
if (Config.Framework == 'vorp') then
    local VorpCore = {}

    TriggerEvent("getCore",function(core)
        VorpCore = core
    end)
end


RegisterServerEvent('addz_karmasystem:server_playerBounty')
AddEventHandler('addz_karmasystem:server_playerBounty',function(killer)

    local wantedPlayerName = ''

    if (Config.Framework == 'redemrp') then

        TriggerEvent('redemrp:getPlayerFromId', killer, function(wantedPlayer)
            wantedPlayerName = wantedPlayer.getFirstname() .. ' ' .. wantedPlayer.getLastname()           
        end)

    elseif (Config.Framework == 'vorp') then

        local User = VorpCore.getUser(killer)
        local Character = User.getUsedCharacter
        wantedPlayerName = Character.firstname .. ' ' .. Character.lastname
    end
    
    -- to alert every player
    for i, playerId in ipairs(GetPlayers()) do

        local plyrId = tonumber(playerId)
        local targetPlayer = {}

        if (Config.Framework == 'redemrp') then
            TriggerClientEvent("redemrp_notification:start", plyrId, "BOUNTY : " .. wantedPlayerName .. " | ID :" .. killer, 8, "warning")
        elseif (Config.Framework == 'vorp') then
            TriggerClientEvent("vorp:NotifyLeft", plyrId, "BOUNTY STARTED", wantedPlayerName .. " | ID :" .. killer, "generic_textures", "tick", 8000) -- from server side
        end

        TriggerClientEvent('addz_karmasystem:client_setWantedBlip', plyrId, killer)
        
    end

    TriggerClientEvent('addz_karmasystem:client_setKarma', killer)

end)

RegisterServerEvent('addz_karmasystem:server_bountyReward')
AddEventHandler('addz_karmasystem:server_bountyReward',function(bountyHunterId, type)
    local wantedPlayerId = source
    local bountyHunterName = ''
    local wantedPlayerName = ''

    if (type == 1) then
        if (Config.Framework == 'redemrp') then

            TriggerEvent('redemrp:getPlayerFromId', bountyHunterId, function(bountyHunter)
                bountyHunterName = bountyHunter.getFirstname() .. ' ' .. bountyHunter.getLastname()
                bountyHunter.addMoney(Config.Bounty)
            end)
    
            TriggerEvent('redemrp:getPlayerFromId', wantedPlayerId, function(wantedPlayer)
                wantedPlayerName = wantedPlayer.getFirstname() .. ' ' .. wantedPlayer.getLastname()           
                wantedPlayer.removeMoney(Config.Bounty)
            end)
    
        elseif (Config.Framework == 'vorp') then
    
            local bHunter = VorpCore.getUser(bountyHunterId)
            local bhCharacter = User.getUsedCharacter
            bountyHunterName = bhCharacter.firstname .. ' ' .. bhCharacter.lastname
            bhCharacter.addCurrency(0, Config.Bounty)
    
            local wPlayer = VorpCore.getUser(wantedPlayerId)
            local wpCharacter = User.getUsedCharacter
            wantedPlayerName = wpCharacter.firstname .. ' ' .. wpCharacter.lastname
            wpCharacter.removeCurrency(0, Config.Bounty)
    
        end
    
        -- to alert every player
        for i, playerId in ipairs(GetPlayers()) do
    
            local plyrId = tonumber(playerId)
            local targetPlayer = {}
        
            if (Config.Framework == 'redemrp') then
                TriggerClientEvent("redemrp_notification:start", plyrId, bountyHunterName .. " has claim bounty ID : " .. wantedPlayerId , 8, "warning")
                
            elseif (Config.Framework == 'vorp') then
                TriggerClientEvent("vorp:NotifyLeft", plyrId, "BOUNTY CLAIM !", bountyHunterName .. " has claim bounty " .. wantedPlayerId, "generic_textures", "tick", 8000)
            end  
            
            TriggerClientEvent('addz_karmasystem:client_removeWantedBlip', plyrId, wantedPlayerId)
        end
    
    elseif (type == 2) then
        -- to alert every player
        for i, playerId in ipairs(GetPlayers()) do
            local plyrId = tonumber(playerId)
            local targetPlayer = {}
        
            if (Config.Framework == 'redemrp') then
                TriggerClientEvent("redemrp_notification:start", plyrId, "bounty ID : " .. wantedPlayerId .. " has been removed" , 8, "warning")
                
            elseif (Config.Framework == 'vorp') then
                TriggerClientEvent("vorp:NotifyLeft", plyrId, "BOUNTY REMOVED !", "bounty ID : " .. wantedPlayerId .. " has been removed", "generic_textures", "tick", 8000)
            end  
            
            TriggerClientEvent('addz_karmasystem:client_removeWantedBlip', plyrId, wantedPlayerId)
        end
    end


end)