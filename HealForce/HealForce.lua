-- Init local variables.
local _, hf = ...;

local HF_GroupCollection = {};

-- Returns a group class instance or nil.
local function HF_GetGroupCollection(groupName)
    return HF_GroupCollection[groupName];
end;

-- Returns a unit class instance or nil.
local function HF_GetUnit(groupName, unitName)
    local group = HF_GetGroupCollection(groupName);
    local unit = nil;

    -- If the group exists, find the unit.
    if group then 
        unit = group.units[unitName];
    end;

    return unit;
end;

-- All of the event actions are registered here.
local function HF_EventActions(self, event, ...)
    local arg1 = select(1, ...);

    -- When a player's health or maximum health is changed...
    if (event == 'UNIT_HEALTH') or (event == 'UNIT_MAXHEALTH') then
        local unitName = arg1;
        local unit = HF_GetUnit('healer', unitName);

        if unit then
            unit:UpdateHealth();
        end;
    elseif (event == 'ADDON_LOADED') and (arg1 == 'HealForce') then
        -- Create the initial group frame containing the player.
        HF_GroupCollection['healer'] = HF_Group.new('myGroupFrame', {'player'});
    end;
end;

-- Register the events we care about in this mod.
local function HF_RegisterEvents(frame)
    frame:RegisterEvent('ADDON_LOADED');
    frame:RegisterEvent('UNIT_HEALTH');
    frame:RegisterEvent('UNIT_MAXHEALTH');
    frame:SetScript('OnEvent', HF_EventActions);
end;

-- Initialize the mod. Create the first frame, and establish the event listeners.
function HF_HealForce_Initialize(frame)
    HF_RegisterEvents(frame);
end;
