-- Init local variables.
local _, hf = ...;

HF_SpellBook = {};

-- Gift of Naaru = Spell_Holy_HolyProtection

local function HF_SetSpell(spellName, iconPath)
    HF_SpellBook[spellName] = {
        name = spellName;
        iconPath = iconPath;
    };
end;

function HF_SetSpells()
    --  TODO: Add race detection for special race buffs.

    local playerClass = UnitClass('player');
    local playerSpec = GetSpecialization();

    -- If a Holy Paladin...
    if (playerClass == 'Paladin') and (playerSpec == 1) then
        HF_SetSpell('Flash of Light', 'Interface\\ICONS\\Spell_Holy_Flashheal');
        HF_SetSpell('Holy Shock', 'Interface\\ICONS\\Spell_Holy_SearingLight');
    end;
end;
