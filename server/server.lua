--original code at bottom
local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang
local RadialMenu = class("RadialMenu", vRP.Extension)
-- TUNNEL

function RadialMenu:__construct()
  vRP.Extension.__construct(self)
end


-- Give nearest player money
function RadialMenu:giveMoney()
  local user = vRP.users_by_source[source]
  local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source, 10)

  if nplayer then
    local nuser = vRP.users_by_source[nplayer]
    if nuser then
      -- Prompt for amount
      local amount = parseInt(user:prompt(lang.money.give.prompt(), "")) or 0
      if amount > 0 and user:tryPayment(amount) then
        nuser:giveWallet(amount)
        vRP.EXT.Base.remote._notify(user.source, lang.money.given({amount}))
        vRP.EXT.Base.remote._notify(nuser.source, lang.money.received({amount}))
      else
        vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source, lang.common.no_player_near())
    end
  else
    vRP.EXT.Base.remote._notify(user.source, lang.common.no_player_near())
  end
end

-- Call admin to submit a report.
function RadialMenu:callAdmin()
  local user = vRP.users_by_source[source]

  if not user:hasPermission("player.calladmin") then
    vRP.EXT.Base.remote._notify(user.source, "You do not have permission to call an admin.")
    return
  end

  local desc = user:prompt(lang.admin.call_admin.prompt(), "") or ""
  if desc == "" then
    vRP.EXT.Base.remote._notify(user.source, "You cannot create an empty ticket.")
    return
  end
  local answered = false

  local admins = {}
  for _, user in pairs(vRP.users) do
    if user:isReady() and user:hasPermission("admin.tickets") then
      table.insert(admins, user)
    end
  end

  for _, admin in pairs(admins) do
    async(function()
      local ok = admin:request(lang.admin.call_admin.request({user.id, htmlEntities.encode(desc)}), 60)
      if ok and not answered then
        answered = true
        vRP.EXT.Base.remote._notify(user.source, "An Admin has claimed your ticket.")
        vRP.EXT.Base.remote._teleport(admin.source, vRP.EXT.Base.remote.getPosition(user.source))
      elseif ok then
        vRP.EXT.Base.remote._notify(admin.source, "Ticket is already claimed.")
      end
    end)
  end
end

-- Check if player is police, and provide the menu if they are.
function RadialMenu:isPolice()
  local users = vRP.users
  local group = vRP.EXT.Group:getUsersByGroup("police")
  for k, v in pairs(group) do
    if v.source == source then
      return true
    else
      return false
    end
  end
end

-- repair vehicle
function RadialMenu:Repair()
  local user = vRP.users_by_source[source]

  -- anim and repair
  if user:tryTakeItem("repairkit",1) then
    vRP.EXT.Base.remote._playAnim(user.source,false,{task="WORLD_HUMAN_WELDING"},false)
    SetTimeout(15000, function()
      self.remote._fixNearestVehicle(user.source,7)
      vRP.EXT.Base.remote._stopAnim(user.source,false)
    end)
  end
end

-- Store weapons
function RadialMenu:store_weapons()
  local user = vRP.users_by_source[source]

  local weapons = vRP.EXT.PlayerState.remote.replaceWeapons(user.source, {})
  for k,v in pairs(weapons) do
    -- convert weapons to parametric weapon items
    user:tryGiveItem("wbody|"..k, 1)
    if v.ammo > 0 then
      user:tryGiveItem("wammo|"..k, v.ammo)
    end
  end
end

--get nearest owned vehicle
function RadialMenu:getNearestOwnedVehicle()
  local user = vRP.users_by_source[source]
  if user == nil or not user then return print('user is not initialized or not user') end
  local vehicle = vRP.EXT.Garage.remote.getNearestOwnedVehicle(user.source, 7)
  --print(tostring(vehicle))
  return vehicle
end

-- Get user identity data
function RadialMenu:getPlayerData()
  local user = vRP.users_by_source[source]
  if user == nil or not user then return print('user is not initialized or not user') end
  local identity = user.identity
  --print(json.encode(identity))
  local address = vRP.EXT.Home:getAddress(user.cid)
  print("' "..json.encode(address) .." '".. 'This is the address')
  return {identity, address}
end

function RadialMenu:stopMission()
  local user = vRP.users_by_source[source]
  if user then
    user:stopMission()
  end
end

RadialMenu.tunnel = {}

RadialMenu.tunnel.getNearestOwnedVehicle = RadialMenu.getNearestOwnedVehicle
RadialMenu.tunnel.isPolice = RadialMenu.isPolice
RadialMenu.tunnel.callAdmin = RadialMenu.callAdmin
RadialMenu.tunnel.giveMoney = RadialMenu.giveMoney
RadialMenu.tunnel.Repair = RadialMenu.Repair
RadialMenu.tunnel.store_weapons = RadialMenu.store_weapons
RadialMenu.tunnel.getPlayerData = RadialMenu.getPlayerData
RadialMenu.tunnel.stopMission = RadialMenu.stopMission

vRP:registerExtension(RadialMenu)
