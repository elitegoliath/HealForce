-- Init local variables.
local _, hf = ...;

HF_SpellBook = {};

local function HF_SetSpell(spellFrame, spell)
    -- local spellInfo = GetSpellInfo(19750);
    -- print(HF_SpellBook[spell]);
    -- local icon = spellFrame:('Icon');
    -- icon:SetTexture('Interface\\ICONS\\Ability_Priest_Flashoflight');
    -- spellFrame:CreateTexture('Spell1_Icon', 'Icon');
    spellFrame:SetAttribute('spell', spell);
end;

function HF_SetSpells(frame)
    HF_SpellBook['Flash of Light'] = GetSpellInfo(19750);
    -- TODO: Update spell list so that this can be used when spells change from events.
    -- TODO: Count spells, map to frames. Manual for now.
    HF_SetSpell(frame.Spell1, 'Flash of Light');
end;
