local api = require("api")

-- First up is the addon definition!
-- This information is shown in the Addon Manager.
-- You also specify "unload" which is the function called when unloading your addon.
local hoa_addon = {
  name = "HoA Helper",
  author = "Delarme",
  desc = "Staff Tracker",
  version = "0.2"
}

--Note, Hyu HoA group was sacrificed to the instance gods RIP Hyu, Elzo, Egress, Waifublaster

local staffrechargetime = 5000
local staffdisappeartime = 10000

local staffbuffid = 15404
--local staffbuffid = 127 -- for testing
local helper
local step = 0
local timerms = 0

local dungeonChannel = "Heart of Ayanad"

timerstarted = false


local function StopTimerEvent()
    if timerstarted == true then
        timerstarted = false
        helper:ReleaseHandler("OnUpdate")
    end

end

local function OnUpdate(dt)
    
    local currtime = api.Time:GetUiMsec() + 0
    local remainingtime = (timerms - currtime)
    --api.Log:Info(remainingtime)
    if remainingtime > 0 then
    
        helper.timerLabel:SetText(string.format("%.0f", remainingtime / 1000))
        return
    end
    helper.timerLabel:SetText("0")
    if step == 1 then
        step = 2
        helper.childIcon:Show(true)
        helper.childIconRecharge:Show(false)
        timerms = staffdisappeartime + api.Time:GetUiMsec()
        failedkey = timerms
      return
    end
    if step == 2 then
        step = 0
        StopTimerEvent()
        helper:Show(false)
        return
    end
   
end
local function StartTimerEvent()
    if timerstarted == false then
        timerstarted = true
        helper:SetHandler("OnUpdate", OnUpdate)
    end
end



local function CheckStaffBuff()

    local buffCount = api.Unit:UnitBuffCount("player")

   -- local lbuff = api.Unit:UnitBuff("player", buffCount)
    --api.Log:Info(lbuff.buff_id)
    for i = 1, buffCount do 
        local buff = api.Unit:UnitBuff("player", i)
        if buff.buff_id == staffbuffid then
            helper:Show(true)
            helper.childIcon:Show(true)
            helper.childIconRecharge:Show(false)
            timerms = buff.timeLeft + api.Time:GetUiMsec()
            if timerstarted == false then
                StartTimerEvent()
                --api.Log:Info("aaa")
            end
            step = 0
        end
    end
    --api.Log:Info(buff.buff_id)
end


local function FailedToPickupStaff()

end


local function StaffReadyToPickup()

    --3 seconds after drop

    --api.DoIn(5000, FailedToPickupStaff)
end

local function CheckIfStaffDrop()
    
    if step ~= 0 then
        return
    end

    local buffCount = api.Unit:UnitBuffCount("player")

    for i=1, buffCount do
        local buff = api.Unit:UnitBuff("player", i)
        if buff.buff_id == staffbuffid then
            return
        end
    end

    step = 1
    helper.childIcon:Show(false)
    helper.childIconRecharge:Show(true)
    timerms = staffrechargetime + api.Time:GetUiMsec()
    --api.DoIn(3000, StaffReadyToPickup)
    --helper:Show(false)
end






local function RefreshBuffs(action)
    -- should only need to look at the last buff
      --api.Log:Info(action )
    if action == "create" then
        CheckStaffBuff()
        return
    end
    CheckIfStaffDrop()
    --for i=1
end


local function ProcessBuff(action, target)
  --api.Log:Info(action)
  if target == "character" then
     
     RefreshBuffs(action)
  end

end

local function OnEvent(this, event, ...)

   -- api.Log:Info(event)
  if event == "BUFF_UPDATE" then
    ProcessBuff(...)
  end 
    --HudUpdate()
end




-- The Load Function is called as soon as the game loads its UI. Use it to initialize anything you need!
local function Load() 
    api.Log:Info("Loading hoa helper...")
    helper = api.Interface:CreateEmptyWindow("Staff Tracker", "UIParent")
    helper:AddAnchor("TOP", "UIParent", 0, 250)
    helper:SetExtent(44, 44)
    
    helper.childIcon = CreateItemIconButton("Item", helper)
    F_SLOT.ApplySlotSkin(helper.childIcon, helper.childIcon.back, SLOT_STYLE.BUFF)
    F_SLOT.SetIconBackGround(helper.childIcon, "Game\\ui\\icon\\quest/icon_item_quest219.dds")
    helper.childIcon:AddAnchor("CENTER", helper, "CENTER", 0,0)
    
    helper.childIconRecharge = CreateItemIconButton("Item", helper)
    F_SLOT.ApplySlotSkin(helper.childIconRecharge, helper.childIconRecharge.back, SLOT_STYLE.BUFF)
    F_SLOT.SetIconBackGround(helper.childIconRecharge, "Game\\ui\\icon\\icon_buff_buff.dds")
    helper.childIconRecharge:AddAnchor("CENTER", helper, "CENTER", 0,0)
    helper.childIconRecharge:Show(false)

    helper.timerLabel = helper:CreateChildWidget("label", "timerLabel", 0, true)
    helper.timerLabel.style:SetShadow(true)
    helper.timerLabel.style:SetAlign(ALIGN.RIGHT)
    helper.timerLabel:AddAnchor("TOPRIGHT", helper, "BOTTOMRIGHT", -5, -10)
    helper.timerLabel.style:SetFontSize(FONT_SIZE.LARGE)
    helper.timerLabel:SetText("0.0")

    helper:SetHandler("OnEvent", OnEvent)
    helper:RegisterEvent("BUFF_UPDATE")
    
    helper:Show(false)
end





-- Unload is called when addons are reloaded.
-- Here you want to destroy your windows and do other tasks you find useful.
local function Unload()
    if helper ~= nil then
    StopTimerEvent()
    helper:Show(false)
    helper:ReleaseHandler("OnEvent")
    helper = nil
  end
end

-- Here we make sure to bind the functions we defined to our addon. This is how the game knows what function to use!
hoa_addon.OnLoad = Load
hoa_addon.OnUnload = Unload

return hoa_addon
