-- HF_GroupCollection = {};
-- HF_UnitCollection = {}; -- Must be stored as a character name from GetUnitName(_unitName, false);

-- All groups will be have their key named after Unit Role, except for Me for quick unit finds.
-- Will adapt as this become more feature rich.
local GROUP_ME = 'Me';
local GroupPool = HF_ObjectPool.new(HF_Group); -- Group keys will be by unit role for now.

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
        -- If the meGroup exists, shut it down.
        local meGroup = GroupPool:getInstance(GROUP_ME);
        if (meGroup) then
            meGroup:clearAll();
            GroupPool:clearInstance(GROUP_ME);
        end;

        -- When getting the unit name, we need to know whether to check with party or raid.
        local g = 'party';
        if (groupSize > 4) then g = 'raid' end;

        -- Pass 1: Check to see if there are any units that are no longer in the group.
        -- For every group in the pool...
        for k, v in pairs(GroupPool:getAll()) do
            -- For every unit in the group...
            for kk, vv in pairs(v.unitPool:getAll()) do
                local isInParty = UnitInParty(vv.name);
                local isInRaid = UnitInRaid(vv.name);

                -- If the unit is not listed in party or raid, they're gone.
                if not (isInParty) and not (isInRaid) then
                    v.unitPool:clearInstance(kk);
                end;
            end;

            -- If the final unit of a group has been removed, clear the group.
            if not (#v > 0) then
                print('Clear group pool');
                GroupPool:clearInstance(k);
            end;
        end;

        -- Pass 2: Add or shift units that belong to the group.
        for i = 1, groupSize do
            -- local unitName, unitRank, unitSubgroup, unitLevel,
            --     unitClass, _, zone, isOnline, isDead, _, _, unitRole = GetRaidRosterInfo(i);
            local unitName = UnitName(g..i);
            local unitRole = UnitGroupRolesAssigned(unitName);
            -- local unitClass = UnitClass(unitName); -- To be used later.
            print('Unit: ', unitName, unitRole);

            local foundUnit = GroupPool:findInAll('unitPool', unitName, true);
            local group = GroupPool:getOrCreateInstance(unitRole);

            -- If unit exists and their role has changed, shift them to the proper frame.
            if (foundUnit) and not (foundUnit.role == unitRole) then
                print('Unit Swapping Roles');
                local oldUnitGroup = GroupPool:getInstance(foundUnit.role);
                if (oldUnitGroup) then
                    oldUnitGroup:removeUnit(unitName);
                end;

                group:addUnit(unitName, unitRole);
            elseif not (foundUnit) then
                print('New Unit in Group', unitName);
                -- Otherwise, add the fresh boi to the roster.
                group:addUnit(unitName, unitRole);
            end;

            

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
        local meName = UnitName('player');
        local meRole = UnitGroupRolesAssigned('player');
        local meGroup = GroupPool:getOrCreateInstance(GROUP_ME);
        meGroup:addUnit(meName, meRole);

        -- print('My lone group.', meName);

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

-- All of the event actions are registered here.
local function EventActions(_self, _event, ...)
    local arg1 = select(1, ...);
    local arg2 = select(2, ...);
    local arg3 = select(3, ...);

    -- When a player's health or maximum health is changed...
    if (_event == 'UNIT_HEALTH_FREQUENT') or (_event == 'UNIT_MAXHEALTH') then
        local unitName = UnitName(arg1);
        local unit = GroupPool:findInAll('unitPool', unitName, true);

        if unit then
            unit:updateHealth();
        end;
    elseif (_event == 'SPELL_ACTIVATION_OVERLAY_GLOW_SHOW') then
        HF_ShowSpellProc(HF_SpellBook[arg1]);
    elseif (_event == 'SPELL_ACTIVATION_OVERLAY_GLOW_HIDE') then
        HF_HideSpellProc(HF_SpellBook[arg1]);
    elseif (_event == 'UNIT_HEAL_PREDICTION') then
        local unitName = UnitName(arg1);
        local unit = GroupPool:findInAll('unitPool', unitName, true);

        if unit then
            unit:updateHealPrediction();
        end;
    elseif (_event == 'SPELLS_CHANGED') then
        -- Set or re-set the player's list of regsitered spells.
        HF_SetSpells();
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
-- All other events don't matter until after this.
function HF_HealForce_Initialize(_frame)
    _frame:RegisterEvent('PLAYER_LOGIN');
    _frame:SetScript('OnEvent', EventActions);
end;
