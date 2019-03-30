-- HF_GroupCollection = {};
-- HF_UnitCollection = {}; -- Must be stored as a character name from GetUnitName(_unitName, false);

-- All groups will be have their key named after Unit Role, except for Me for quick unit finds.
-- Will adapt as this become more feature rich.
local GROUP_ME = 'Me';
local GroupPool = HF_ObjectPool.new(HF_Group);

-- Register the events we care about in this mod.
local function RegisterEvents(_frame)
    _frame:RegisterEvent('UNIT_HEALTH_FREQUENT');
    _frame:RegisterEvent('UNIT_MAXHEALTH');
    _frame:RegisterEvent('UNIT_HEAL_PREDICTION');
    _frame:RegisterEvent('SPELLS_CHANGED');
    _frame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW');
    _frame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_HIDE');
    _frame:RegisterEvent('GROUP_ROSTER_UPDATE');
    _frame:RegisterEvent('UNIT_SPELLCAST_START');
    _frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
    _frame:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED');
    _frame:RegisterEvent('UNIT_SPELLCAST_FAILED');
end;

local function UpdateRoster()
    -- print('update roster');
    -- GetRaidRosterInfo()
    -- print(UnitGroupRolesAssigned('player'));
    local groupSize = GetNumGroupMembers();

    -- Clear out the current frames since I don't get informed of who left or joined. Start fresh.
    -- wipe(HF_UnitCollection);
    -- for i, group in pairs(HF_GroupCollection) do
    --     group:ClearUnitFrames();
    -- end;

    -- If the player is in a group, update the groups and units with them.
    if (groupSize > 0) then
        -- When getting the unit name, we need to know whether to check with party or raid.
        local g = 'party';
        if (groupSize > 4) then g = 'raid' end;

        for i = 1, groupSize do
            -- local unitName, unitRank, unitSubgroup, unitLevel,
            --     unitClass, _, zone, isOnline, isDead, _, _, unitRole = GetRaidRosterInfo(i);
            local unitName = UnitName(g..i);
            local unitRole = UnitGroupRolesAssigned(unitName);
            -- local unitClass = UnitClass(unitName); -- To be used later.
            print('Unit: ', unitName, unitRole);

            local foundUnit = GroupPool:findInAll('unitPool', unitName);

            -- If unit exists, make sure they didnt change spec, meaning we need to move them frames.

            local groupFrame = GroupPool:getOrCreateInstance(unitRole);

            -- local unitDisplayName = GetUnitName(unitName, false);
        





            -- First do a pass to see who is not in raid or party (both must be false for removal)
            -- Then do a second pass, checking who already exists, adding those who do not.
            -- TODO: Find a way to fill in gaps/re-organize the list if someone leaves.

            -- local unitName, unitRank, unitSubgroup, unitLevel,
            --       unitClass, _, zone, isOnline, isDead, _, _, unitRole = GetRaidRosterInfo(i);
            -- local groupFrame = HF_GroupCollection[unitRole];
            -- -- local unitDisplayName = GetUnitName(unitName, false);

            -- if not groupFrame then
            --     local newGroup = HF_Group.new(unitRole);
            --     newGroup:AddUnitFrame(unitName);
            --     HF_GroupCollection[unitRole] = newGroup;
            -- else
            --     groupFrame:AddUnitFrame(unitName);
            -- end;
        end;
    else

        -- ME Group here
        local meFrame = GroupPool:getOrCreateInstance(GROUP_ME);

        -- local meGroup = HF_GroupCollection[GROUP_ME];
        -- if not meGroup then
        --     meGroup = HF_Group.new(GROUP_ME);
        --     meGroup:AddUnitFrame('player');
        --     HF_GroupCollection[GROUP_ME] = meGroup;
        -- else
        --     meGroup.units['player'].frame:Show();
        -- end;
    end;

    -- TODO: Better way of handling spell slots needed. Set new spell slots only for new units.
    -- HF_SetSpells();
end;

-- All of the event actions are registered here.
local function EventActions(_self, _event, ...)
    local arg1 = select(1, ...);
    local arg2 = select(2, ...);
    local arg3 = select(3, ...);

    -- When a player's health or maximum health is changed...
    if (_event == 'UNIT_HEALTH_FREQUENT') or (_event == 'UNIT_MAXHEALTH') then
        local unitName = GetUnitName(arg1, false);
        local unit = HF_UnitCollection[unitName];

        if unit then
            unit:UpdateHealth();
        end;
    elseif (_event == 'SPELL_ACTIVATION_OVERLAY_GLOW_SHOW') then
        HF_ShowSpellProc(HF_SpellBook[arg1]);
    elseif (_event == 'SPELL_ACTIVATION_OVERLAY_GLOW_HIDE') then
        HF_HideSpellProc(HF_SpellBook[arg1]);
    elseif (_event == 'UNIT_HEAL_PREDICTION') then
        local unitName = GetUnitName(arg1, false);
        local unit = HF_UnitCollection[unitName];

        if unit then
            unit:UpdateHealPrediction();
        end;
    elseif (_event == 'SPELLS_CHANGED') then
        -- Set or re-set the player's list of regsitered spells.
        -- HF_SetSpells();
    elseif (_event == 'GROUP_ROSTER_UPDATE') then
        UpdateRoster();
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
