-- Init local variables.
local _, hf = ...;

-- Defaults for an HF_SpellButton class instance.
HF_SpellButton = {
    frame = nil;
    spellName = nil;
    target = nil;
    spellSlot = nil;
};
HF_SpellButton.__index = HF_SpellButton;

-- Constructor for the HF_Unit class.
function HF_SpellButton.new(spellName, parentFrame, target)
    local self = setmetatable({}, HF_SpellButton);

    -- Set spell button properties.
    self.spellName = spellName;
    self.target = target;

    -- Generate the spell button frame.
    self.frame = CreateFrame('Button', spellName .. '_SpellButtonFrame', parentFrame, 'HF_SpellButtonFrame');

    -- Set the icon.
    self.frame.icon:SetTexture(HF_SpellBook[spellName].icon);

    -- Set the spell properties.
    self.frame:SetAttribute('spell', spellName);
    self.frame:SetAttribute('unit', target);

    return self;
end;
