-- Init local variables.
-- local _, hf = ...;

-- Defaults for an HF_SpellButton class instance.
HF_SpellButton = {
    frame = nil;
    spellName = nil;
    spellId = nil;
    target = nil;
    -- spellSlot = nil;
};
HF_SpellButton.__index = HF_SpellButton;

-- Constructor for the HF_Unit class.
function HF_SpellButton.new(_spellName, _parentFrame, _target)
    local self = setmetatable({}, HF_SpellButton);

    -- Set spell button properties.
    self.spellName = _spellName;
    self.target = _target;

    -- Generate the spell button frame.
    self.frame = CreateFrame('Button', _spellName .. '_SpellButtonFrame', _parentFrame, 'HF_SpellButtonFrame');
    HF_SetSpellButtonRef(self.frame, _spellName);

    -- Set the icon.
    self.frame.icon:SetTexture(HF_SpellBook[_spellName].icon);

    -- Set the spell properties.
    self.frame:SetAttribute('spell', _spellName);
    self.frame:SetAttribute('unit', _target);

    return self;
end;
