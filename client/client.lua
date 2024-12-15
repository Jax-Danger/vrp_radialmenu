-- --##########	VRP Main	##########--
-- init vRP server context
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
local cvRP = module("vrp", "client/vRP")
vRP = cvRP()
local pvRP = {}
-- load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)
-- I don't know if above is needed :/
local RadialMenu = class("RadialMenu", vRP.Extension)

local focus = false
local active = false

function RadialMenu:__construct()
  vRP.Extension.__construct(self)
  self.isPolice = false
  -- General Items in Menu.
  self.isNearVehicle = false

  -- Test command for UI (WIP)
  RegisterCommand('testingui', function()
    SetDisplay(true)
    SetNuiFocus(true, true)
  end, false)

  --[[Functions]]--
  -- This function loads the police actions in the radial menu when user is police.
  local function PoliceItems(self)
    exports["ox_lib"]:addRadialItem({
      {
        id = "police",
        label = "Police Actions",
        icon = "shield", -- Corrected typo here
        menu = "police_menu"
      }
    })

    exports["ox_lib"]:registerRadial({
      id = "police_menu",
      items = {
        {
          label = "Handcuff",
          icon = "handcuffs",
          onSelect = function()
            --self.remote._HandCuff(self)
            print("Handcuffing player.")
          end
        }
      }
    })
  end

  -- This function loads the vehicle actions in the radial menu when user is near an owned vehicle.
  local function VehicleMenu(self, nvehicle)
    local isEngineOn = true
    local isLocked = false
    local driverDoorOpen = false
    local passengerDoorOpen = false
    local rearLeftDoorOpen = false
    local rearRightDoorOpen = false
    local hoodOpen = false
    local trunkOpen = false

    exports["ox_lib"]:addRadialItem({
      {
        id = "vehicle",
        label = "Vehicle Actions",
        icon = "car",
        menu = "vehicle_menu"
      }
    })

    exports["ox_lib"]:registerRadial({
      id = "vehicle_menu",
      items = {
        {
          label = "Lock/Unlock",
          icon = "lock",
          onSelect = function()
            isLocked = not isLocked
            vRP.EXT.Garage:vc_toggleLock(nvehicle)
            if isLocked then
              vRP.EXT.Base:notify("Vehicle is now locked.")
            else
              vRP.EXT.Base:notify("Vehicle is now unlocked.")
            end
          end
        },
        {
          label = "Engine On/Off",
          icon = "power-off",
          onSelect = function()
            isEngineOn = not isEngineOn
            vRP.EXT.Garage:vc_toggleEngine(nvehicle)
            if isEngineOn then
              vRP.EXT.Base:notify("Engine is now on.")
            else
              vRP.EXT.Base:notify("Engine is now off.")
            end
          end
        },
        {
          id = "doors",
          label = "Doors",
          icon = "door-open",
          menu = "door_menu"
        },
        {
          id = "repairvehicle",
          label = "Repair Vehicle",
          icon = "wrench",
          onSelect = function()
            self.remote._Repair()
          end
        },
      }
    })

    exports["ox_lib"]:registerRadial({
      id = "door_menu",
      items = {
        {
          label = "Driver Door",
          icon = "door-open",
          keepOpen = true,
          onSelect = function()
            driverDoorOpen = not driverDoorOpen
            if driverDoorOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 0)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 0)
            end
          end
        },
        {
          label = "Passenger Door",
          icon = "door-open",
          keepOpen = true,
          onSelect = function()
            passengerDoorOpen = not passengerDoorOpen
            if passengerDoorOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 1)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 1)
            end
          end
        },
        {
          label = "Rear Left Door",
          icon = "door-open",
          keepOpen = true,
          onSelect = function()
            rearLeftDoorOpen = not rearLeftDoorOpen
            if rearLeftDoorOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 2)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 2)
            end
          end
        },
        {
          label = "Rear Right Door",
          icon = "door-open",
          keepOpen = true,
          onSelect = function()
            rearRightDoorOpen = not rearRightDoorOpen
            if rearRightDoorOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 3)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 3)
            end
          end
        },
        {
          label = "Hood",
          icon = "car",
          keepOpen = true,
          onSelect = function()
            hoodOpen = not hoodOpen
            if hoodOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 4)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 4)
            end
          end
        },
        {
          label = "Trunk",
          icon = "suitcase",
          keepOpen = true,
          onSelect = function()
            trunkOpen = not trunkOpen
            if trunkOpen then
              vRP.EXT.Garage:vc_closeDoor(nvehicle, 5)
            else
              vRP.EXT.Garage:vc_openDoor(nvehicle, 5)
            end
          end
        }
      }
    })
  end

  -- This is the default actions seen when first opening the menu.
  exports["ox_lib"]:addRadialItem({
    {
      id = "calladmin",
      label = "Call Admin",
      icon = "exclamation-triangle",
      onSelect = function()
        self.remote._callAdmin()
      end
    },
    {
      id = "givemoney",
      label = "Give Money",
      icon = "money-bill-wave",
      onSelect = function()
        self.remote._GiveMoney()
      end
    },
    {
      id = "storeweapons",
      label = "Store Weapons",
      icon = "shield",
      onSelect = function()
        self.remote._store_weapons()
      end
    },
    {
      id = "getidentity",
      label = "ID Card",
      icon = "id-card",
      onSelect = function()
        if active then
          SetDisplay(false)
          SetNuiFocus(false, false)
          active = false
        else
          active = true
          print("Getting ID Card.")

          SendNUIMessage({
            action = "setVisible",
            data = true,
          })

          local pldata = self.remote.getPlayerData()
          SendNUIMessage({
            action = "setID",
            data = pldata
          })

          local ped = PlayerPedId()
          local pedHeadshot = RegisterPedheadshot(ped)

          Citizen.CreateThread(function()
            while not IsPedheadshotReady(pedHeadshot) or not IsPedheadshotValid(pedHeadshot) do
              Citizen.Wait(100)
            end

            local headshotTexture = GetPedheadshotTxdString(pedHeadshot)

            SendNUIMessage({
              action = "setHeadshot",
              headshot = headshotTexture
            })

            Citizen.CreateThread(function()
              while active do
                Citizen.Wait(0)
                -- Draw the ped headshot
                DrawSprite(
                  headshotTexture, headshotTexture,
                  -4, 5, -- Center of screen
                  0.1, 0.1, -- Width, Height
                  0.0, -- Rotation
                  255, 255, 255, 255 -- Color
                )
              end
              UnregisterPedheadshot(pedHeadshot)
            end)
          end)
        end
      end
    }
  })

  -- This is a check to see if the player is police, and if so, it'll call the function to give the nessessary actions in the menu.
  Citizen.CreateThread(function()
    while true do
      --print("Checking police status...")
      local isPolice = self.remote.isPolice()
      if isPolice and not self.isPolice then
        --print("Player is police.")
        PoliceItems(self)
        self.isPolice = true
      elseif not isPolice and not self.isPolice then
        --print("Player is not police.")
        self.isPolice = false
      elseif not isPolice and self.isPolice then
        exports["ox_lib"]:removeRadialItem("police")
        self.isPolice = false
        --print("Player is no longer police.")
      end
      Citizen.Wait(2500)
    end
  end)

  -- This is a check to see if the player is near any owned vehicles, and if so, it'll call the function to give the nessessary actions in the menu.
  Citizen.CreateThread(function()
    while true do
      --print("Checking if player is near any owned vehicles...")
      local nVehicle = self.remote.getNearestOwnedVehicle()
      --print('nvehicle is '..tostring(nVehicle))
      if nVehicle ~= nil and not self.isNearVehicle then
        --print("Player is near an owned vehicle.")
        VehicleMenu(self, nVehicle)
        self.isNearVehicle = true
      elseif nVehicle == nil and not self.isNearVehicle then
        --print("Player is not near any owned vehicles.")
        self.isNearVehicle = false
      elseif nVehicle == nil and self.isNearVehicle then
        --print("Player is no longer near any owned vehicles.")
        exports["ox_lib"]:removeRadialItem("vehicle")
        self.isNearVehicle = false
      end
      Citizen.Wait(2500)
    end
  end)
end

-- [[UI FUNCTIONS]] --
-- toggle off ui
RegisterNUICallback("exit", function(_, cb)
  print('exit')
  SetDisplay(false)
  SetNuiFocus(false, false)
end)

-- toggle ui
function SetDisplay(bool)
  display = bool
  SendNUIMessage({
    action = "setVisible",
    data = bool,
  })
end

--[[TUNNELS]]--
function RadialMenu:fixNearestVehicle(radius)
  local veh = vRP.EXT.Garage:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end


RadialMenu.tunnel = {}
RadialMenu.tunnel.fixNearestVehicle = RadialMenu.fixNearestVehicle
vRP:registerExtension(RadialMenu)
