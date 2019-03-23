-- This table of spells can be accessed either by Spell Name or ID.
-- Due to the variety of ways spells need to be accessed, this is necessary.
HF_SpellBook = {};
local spellbookMeta = {
    __index = function(_table, _key)
        local filter = function(_prop, _value)
            for i = 1, #_table do
                local spell = _table[i];
                if spell[_prop] == _value then
                    return spell;
                end;
            end;
            return nil;
        end;

        local foundInId = filter('id', _key);
        if foundInId then
            return foundInId;
        else
            return filter('name', _key);
        end;
    end;
};
setmetatable(HF_SpellBook, spellbookMeta);

local ButtonList = {}; -- A flatter list of UnitFrame spell button references.
local SpellsOnCooldown = {}; -- Tracks which spells were on cooldown and when.
local cooldownsActive = false;
local isCastingSpell = false;
local spellBeingCast = nil; -- Used to cancel this spells cooldown and not ones with longer ones when interuptions occur.
local globalCooldown = 1.5;

-- Extracts information about a spell and adds it to the table of known spells: HF_SpellBook;
local function SetSpell(_spellName)
    local sName, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(_spellName);
    local icon = GetSpellTexture(sName);

    if sName and spellId and icon then
        local newSpell = {
            name = sName,
            id = spellId,
            icon = icon,
            minRange = minRange,
            maxRange = maxRange,
        };

        table.insert(HF_SpellBook, newSpell);
    end;
end;

-- Iterates over all of the spell slots and clears them out.
local function ClearSpellSlots()
    -- This is so that we don't need extra check layers for doing things
    -- such as cooldowns for button frames that aren't being used.
    wipe(ButtonList);

    for i, unitFrame in pairs(HF_UnitCollection) do
        for ii, slot in pairs(unitFrame.spellSlots) do
            slot:ClearSlot();
        end;
    end;
end;

-- Iterates over through each spell in the spell list, and adds them to
-- each active unit frame.
-- Done like this instead of with the ButtonList because of when new slots are needed.
-- When that happens, we need to know which unit frames to attach them to.
local function SetSpellSlots()
    for i, spell in pairs(HF_SpellBook) do
        for ii, unitFrame in pairs(HF_UnitCollection) do

            --  TODO: Add checker here for whether a unit frame is active.


            local unitSpellSlot = unitFrame.spellSlots[i];

            -- If a spell slot has been created, re-use it.
            if (unitSpellSlot and not unitSpellSlot.name) then
                unitSpellSlot:UpdateSlot(spell.name, unitFrame.name);
            else
                -- Else, make a new one.
                unitFrame:CreateSpellSlot(i, spell.name, unitFrame.name);
            end;
        end;
    end;
end;

-- Resets the entire spell list for the character.
function HF_SetSpells()
    -- TODO: Add race detection for special race buffs.

    -- Clear the spellbooks and cooldowns.
    wipe(HF_SpellBook);
    wipe(SpellsOnCooldown);
    ClearSpellSlots();

    -- Get the player's information.
    local playerClass = UnitClass('player');
    local playerSpec = GetSpecialization();

    -- Check the player's loadout.
    if (playerClass == 'Paladin') and (playerSpec == 1) then
        -- If a Holy Paladin...
        SetSpell('Flash of Light');
        SetSpell('Holy Shock');
        SetSpell('Holy Light');
    elseif (playerClass == 'Paladin') and (playerSpec == 3) then
        -- If Ret Paladin...
        SetSpell('Flash of Light');
    end;

    -- Set spell slots.
    SetSpellSlots();
end;

-- Used to keep track of each button for each spell.
-- Useful for cooldown triggering.
function HF_SetSpellButtonRef(_frame, _spellName)
    -- If the table doesn't exist, make it.
    if not ButtonList[_spellName] then
        ButtonList[_spellName] = {};
    end;

    table.insert(ButtonList[_spellName], _frame);
end;

-- Any spell with a cooldown longer than the global cooldown that is currently active
-- will return true.
local function GetIsOnLongCooldown(_spellName)
    local cd = SpellsOnCooldown[_spellName];
    local isOnLongCooldown = false;
    
    if (cd and cd.start > 0) then
        local timeLeft = (cd.start + cd.duration) - GetTime();
        if (timeLeft > globalCooldown) then isOnLongCooldown = true end;
    end;

    return isOnLongCooldown;
end;

-- Begins cooldowns. Takes into consideration anything already on a Long Cooldown.
-- Also factors in if the spell just cast has a Long Cooldown.
-- All other spells get a global cooldown.
local function StartCooldowns(_spellOnCooldown)
    local spellName = GetSpellInfo(_spellOnCooldown);
    local _, globalCD = GetSpellBaseCooldown(_spellOnCooldown);
    
    if not globalCD then return end;

    globalCooldown = globalCD / 1000;

    if globalCooldown <= 0 or not spellName then return end;

    -- Iterate over the categories of Spell Buttons on UnitFrames.
    for i, spellCat in pairs(ButtonList) do
        local spellCooldown = GetSpellBaseCooldown(i);
        local startTime, _, onCooldown = GetSpellCooldown(i);

        if (spellCooldown > 0) then
            spellCooldown = spellCooldown / 1000;
        end;

        -- If the current category is the one that was just cast...
        -- Consider if it has a Long Cooldown or to just use GCD.
        if i == spellName then
            -- Because blizzard can't give me this info in a nice easy to get way...
            local trueCooldown = globalCooldown;
            if (spellCooldown > globalCooldown) then 
                trueCooldown = spellCooldown ;
            end;

            SpellsOnCooldown[spellName] = {
                start = startTime,
                duration = trueCooldown,
            };

            for ii, spellButton in pairs(spellCat) do
                spellButton.cooldown:SetCooldown(startTime, trueCooldown);
            end;
        else
            -- Otherwise just throw on the GCD unless it's already on a Long Cooldown.
            local isOnLongCooldown = GetIsOnLongCooldown(i);

            if not isOnLongCooldown then
                SpellsOnCooldown[i] = {start = 0, duration = 0}
                for ii, spellButton in pairs(spellCat) do
                    spellButton.cooldown:SetCooldown(startTime, globalCooldown);
                end;
            end;
        end;
    end;
end;

-- Interruptions happen, and when they do, any cooldowns activated by the spell...
-- global or otherwise, need to be cancelled.
local function InteruptCooldowns()
    if globalCooldown <= 0 then return end;

    local currentSpellName = GetSpellInfo(spellBeingCast);
    local registeredSpell = HF_SpellBook[_spellOnCooldown];

    if currentSpellName and registeredSpell and SpellsOnCooldown[currentSpellName] then
        SpellsOnCooldown[currentSpellName] = {start = 0, duration = 0};
    end;

    for i, spellCat in pairs(ButtonList) do
        local isOnLongCooldown = GetIsOnLongCooldown(i);
        if not isOnLongCooldown then
            for i, spellButton in pairs(spellCat) do
                spellButton.cooldown:SetCooldown(GetTime(), 0);
            end;
        end;
    end;
end;

-- If casting a non-instant cast spell...
function HF_CastingSpell(_spellID)
    isCastingSpell = true;
    cooldownsActive = true;
    spellBeingCast = _spellID;

    StartCooldowns(_spellID);
end;

-- When a spell succeeds in being cast, whether it was an instant cast or
-- a spell with a cast time, it needs to be handled.
function HF_CastingSpellSuccess(_spellID)
    cooldownsActive = true;
    
    -- If the spell that succeeded was actually an instant cast spell...
    if not isCastingSpell then
        StartCooldowns(_spellID);
    else
        -- Otherwise, reset the flags and variables we track for spellcasting.
        isCastingSpell = false;
        spellBeingCast = nil;
    end;
end;

-- When a spell has been interrupted, cancel associated cooldowns.
function HF_CancelCooldowns()
    if cooldownsActive and isCastingSpell then
        cooldownsActive = false;
        isCastingSpell = false;

        InteruptCooldowns();
    end;
end;
