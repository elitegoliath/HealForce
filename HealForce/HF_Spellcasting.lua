-- Init local variables.
local _, hf = ...;

HF_SpellBook = {};

-- Gift of Naaru = Spell_Holy_HolyProtection

local function HF_SetSpell(spellName, iconPath)

    -- Check if the spell is in the player's spellbook by check for nil. If nil, don't add.

    local name, arg2, icon = GetSpellInfo(spellName);
    local icon = GetSpellTexture(name);

    if name and icon then
        HF_SpellBook[spellName] = {
            name = name;
            icon = icon;
        };
    end;
end;

function HF_SetSpells()
    --  TODO: Add race detection for special race buffs.

    local playerClass = UnitClass('player');
    local playerSpec = GetSpecialization();

    -- If a Holy Paladin...
    if (playerClass == 'Paladin') and (playerSpec == 1) then
        HF_SetSpell('Flash of Light');
        HF_SetSpell('Holy Shock');
        HF_SetSpell('Holy Light');
    end;
end;
