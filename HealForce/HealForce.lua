HF_GroupCollection = {};
HF_UnitCollection = {};

local GROUP_ME = 'Me';

-- Register the events we care about in this mod.
local function RegisterEvents(_frame)
    _frame:RegisterEvent('UNIT_HEALTH_FREQUENT');
    _frame:RegisterEvent('UNIT_MAXHEALTH');
    -- _frame:RegisterEvent('PLAYER_REGEN_DISABLED');
    _frame:RegisterEvent('UNIT_HEAL_PREDICTION');
    _frame:RegisterEvent('SPELLS_CHANGED');
    _frame:RegisterEvent('GROUP_ROSTER_UPDATE');
    _frame:RegisterEvent('UNIT_SPELLCAST_START');
    _frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
    _frame:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED');
    _frame:RegisterEvent('UNIT_SPELLCAST_FAILED');
end;

local function UpdateRoster()
    if IsInRaid('player') then
        -- Do raid things.
    elseif IsInGroup('player') then
        -- Do party things.
        -- print(UnitGroupRolesAssigned('player'));
    else
        -- Is by one's lonely self.
        HF_GroupCollection[GROUP_ME] = HF_Group.new(GROUP_ME, {'player'});
    end;
end;

-- All of the event actions are registered here.
local function EventActions(_self, _event, ...)
    local arg1 = select(1, ...);
    local arg2 = select(2, ...);
    local arg3 = select(3, ...);

    -- When a player's health or maximum health is changed...
    if (_event == 'UNIT_HEALTH_FREQUENT') or (_event == 'UNIT_MAXHEALTH') then
        local unitName = arg1;
        local unit = HF_UnitCollection[unitName];

        if unit then
            unit:UpdateHealth();
        end;
    -- elseif (_event == 'PLAYER_REGEN_DISABLED') then
    --     local unit = HF_UnitCollection['player'];

    --     if unit then
    --         unit:UpdateHealth();
    --     end;
    elseif (_event == 'UNIT_HEAL_PREDICTION') then
        local unitName = arg1;
        local unit = HF_UnitCollection[unitName];

        if unit then
            unit:UpdateHealPrediction();
        end;
    elseif (_event == 'SPELLS_CHANGED') then
        -- Set or re-set the player's list of regsitered spells.
        HF_SetSpells();
    elseif (_event == 'GROUP_ROSTER_UPDATE') then
        print('Update Roster.');
    elseif (_event == 'UNIT_SPELLCAST_START') and (arg1 == 'player') then
        HF_CastingSpell(arg3);
    elseif (_event == 'UNIT_SPELLCAST_SUCCEEDED') and (arg1 == 'player') then
        HF_CastingSpellSuccess(arg3);
    elseif (_event == 'UNIT_SPELLCAST_INTERRUPTED' or _event == 'UNIT_SPELLCAST_FAILED') and (arg1 == 'player') then
        HF_CancelCooldowns();
    elseif (_event == 'PLAYER_LOGIN') then
        -- Register the events the mod needs to start listening to.
        RegisterEvents(_self);

        -- Check if globals exist. If not, make the default.
        if (savedSettings == nil) then
            HF_CreateDefaultGlobalSettings();
        end;

        -- Initialize the group, whatever that is currently comprised of.
        UpdateRoster();
    end;
end;

-- Initialize the mod by listening only to the enter world event.
-- ll other events don't matter until after this.
function HF_HealForce_Initialize(_frame)
    _frame:RegisterEvent('PLAYER_LOGIN');
    _frame:SetScript('OnEvent', EventActions);
end;
