-- Init local variables.
-- local _, hf = ...;

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

local ButtonList = {};
local SpellsOnCooldown = {};
local cooldownsActive = false;
local isCastingSpell = false;
local spellBeingCast = nil; -- Used to cancel this spells cooldown and not ones with longer ones when interuptions occur.
local globalCooldown = 1.5;

-- Extracts information about a spell and adds it to the table of known spells: HF_SpellBook;
local function HF_SetSpell(_spellName)
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

-- Resets the entire spell list for the character.
function HF_SetSpells()
    -- TODO: Add race detection for special race buffs.
    -- TODO: Update spell buttons somehow too.

    wipe(HF_SpellBook);
    wipe(SpellsOnCooldown);

    local playerClass = UnitClass('player');
    local playerSpec = GetSpecialization();

    -- If a Holy Paladin...
    if (playerClass == 'Paladin') and (playerSpec == 1) then
        HF_SetSpell('Flash of Light');
        HF_SetSpell('Holy Shock');
        HF_SetSpell('Holy Light');
    end;
end;

-- Used to keep track of each button for each spell.
-- Useful for cooldown triggering.
function HF_SetSpellButtonRef(_frame, _spellName)
    if not ButtonList[_spellName] then
        ButtonList[_spellName] = {};
    end;

    table.insert(ButtonList[_spellName], _frame);
end;




local function HF_GetIsOnLongCooldown(_spellName)
    local cd = SpellsOnCooldown[_spellName];
    local isOnLongCooldown = false;
    
    if (cd and cd.start > 0) then
        local timeLeft = (cd.start + cd.duration) - GetTime();
        if (timeLeft > globalCooldown) then isOnLongCooldown = true end;
    end;

    return isOnLongCooldown;
end;


local function HF_StartCooldowns(_spellOnCooldown)
    local spellName = HF_SpellBook[_spellOnCooldown].name;
    local _, globalCD = GetSpellBaseCooldown(_spellOnCooldown);
    globalCooldown = globalCD / 1000;

    for i, spellCat in pairs(ButtonList) do
        local spellCooldown = GetSpellBaseCooldown(i);
        local startTime, _, onCooldown = GetSpellCooldown(i);

        if (spellCooldown > 0) then
            spellCooldown = spellCooldown / 1000;
        end;

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
            -- local cd = SpellsOnCooldown[i];
            -- local updateCd = true;

            -- if (cd and cd.start > 0) then
            --     local timeLeft = (cd.start + cd.duration) - startTime;
            --     if (timeLeft > globalCooldown) then updateCd = false end;
            -- end;

            local isOnLongCooldown = HF_GetIsOnLongCooldown(i);

            if not isOnLongCooldown then
                SpellsOnCooldown[i] = {start = 0, duration = 0}
                for ii, spellButton in pairs(spellCat) do
                    spellButton.cooldown:SetCooldown(startTime, globalCooldown);
                end;
            end;
        end;
    end;
end;


local function HF_InteruptCooldowns()
    local currentSpellName = GetSpellInfo(spellBeingCast);
    if currentSpellName and SpellsOnCooldown[currentSpellName] then
        SpellsOnCooldown[currentSpellName] = {start = 0, duration = 0};
    end;

    for i, spellCat in pairs(ButtonList) do
        local isOnLongCooldown = HF_GetIsOnLongCooldown(i);
        if not isOnLongCooldown then
            for i, spellButton in pairs(spellCat) do
                spellButton.cooldown:SetCooldown(GetTime(), 0);
            end;
        end;
    end;
end;


function HF_CastingSpell(_spellID)
    isCastingSpell = true;
    cooldownsActive = true;
    spellBeingCast = _spellID;

    HF_StartCooldowns(_spellID);
    -- print('Is casting '.._spellID);
end;

function HF_CastingSpellSuccess(_spellID)
    cooldownsActive = true;
    
    if not isCastingSpell then
        -- TODO: Set cooldown of spell on the spell itself in all slots.
        -- TODO: Set global cooldown on all other spells.
        HF_StartCooldowns(_spellID);
        -- print('Instant cast spell has been cast: '.._spellID);
    else
        isCastingSpell = false;
        spellBeingCast = nil;
        -- print(_spellID..(' succeeded.'));
    end;
end;

function HF_CancelCooldowns()
    if cooldownsActive and isCastingSpell then
        cooldownsActive = false;
        isCastingSpell = false;

        HF_InteruptCooldowns();
    end;
end;