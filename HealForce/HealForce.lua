-- Init local variables.
-- local _, hf = ...;

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

-- Register the events we care about in this mod.
local function HF_RegisterEvents(frame)
    frame:RegisterEvent('UNIT_HEALTH');
    frame:RegisterEvent('UNIT_MAXHEALTH');
    frame:RegisterEvent('SPELLS_CHANGED');
    frame:RegisterEvent('SPELL_UPDATE_COOLDOWN');
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
    elseif (event == 'SPELLS_CHANGED') then
        -- Change from set spells to update spells. This should trigger changes that
        -- create or archive spell buttons based on available spells.

        -- Set the player's spells.
        -- HF_SetSpells();

        print('Spells changed, yo.');
    elseif (event == 'SPELL_UPDATE_COOLDOWN') then
        -- Show global cooldown on all spells.
        -- Apply proper cooldown timing to anything else that has one longer than global.
        -- Account for spells with cast times. Interuptions cancel GCD.
        -- Instant cast spells are just GCD. Instant cast spells trigger 2 immediate event triggers.
        
        print('Spells on cooldown, yo.', arg1);
    elseif (event == 'PLAYER_LOGIN') then
        -- Register the events the mod needs to start listening to.
        HF_RegisterEvents(self);

        -- Check if globals exist. If not, make the default.
        if (savedSettings == nil) then
            HF_CreateDefaultGlobalSettings();
        end;



        -- Set the player's spells.
        HF_SetSpells(); -- This needs to go away once spell updates work in SPELLS_CHANGED.



        -- Create the initial group frame containing the player.
        HF_GroupCollection['healer'] = HF_Group.new('healer', {'player'});
    end;
end;

-- Initialize the mod by listening only to the enter world event.
-- ll other events don't matter until after this.
function HF_HealForce_Initialize(frame)
    frame:RegisterEvent('PLAYER_LOGIN');
    frame:SetScript('OnEvent', HF_EventActions);
end;
