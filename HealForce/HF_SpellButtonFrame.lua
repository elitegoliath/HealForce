-- Defaults for an HF_SpellButton class instance.
HF_SpellButton = {
    frame = nil;
    spellName = nil;
    -- spellId = nil;
    target = nil;
};
HF_SpellButton.__index = HF_SpellButton;

local function ClearSlot(_self)
    _self.frame:Hide();
    _self.spellName = nil;
    _self.target = nil;
end;

local function UpdateSlot(_self, _spellName, _target)
    _self.frame:Show();
    _self.spellName = _spellName;
    _self.target = _target;

    -- Re-register spell slot.
    HF_SetSpellButtonRef(_self.frame, _spellName);
end;

-- Constructor for the HF_Unit class.
function HF_SpellButton.new(_spellName, _parentFrame, _target)
    local self = setmetatable({}, HF_SpellButton);

    -- Set spell button properties.
    self.spellName = _spellName;
    self.target = _target;

    -- Generate the spell button frame.
    self.frame = CreateFrame('Button', _spellName .. '_SpellButtonFrame', _parentFrame, 'HF_SpellButtonFrame');
    
    -- Store the newly created frame's reference for spellcasting concerns.
    HF_SetSpellButtonRef(self.frame, _spellName);

    -- Set the icon.
    self.frame.icon:SetTexture(HF_SpellBook[_spellName].icon);

    -- Set the spell properties.
    self.frame:SetAttribute('spell', _spellName);
    self.frame:SetAttribute('unit', _target);

    -- Set class level functions.
    self.ClearSlot = ClearSlot;
    self.UpdateSlot = UpdateSlot;

    return self;
end;
