-- Init local variables.
-- local _, hf = ...;

-- Defaults for an HF_Unit class instance.
HF_Unit = {
    frame = nil;
    name = nil;
    -- spellButtons = {};
    maxHealth = 100;
    currentHealth = 100;
};
HF_Unit.__index = HF_Unit;

-- Update health for an HF_Unit class instance.
local function HF_UpdateHealth(_self)
    _self.maxHealth = UnitHealthMax(_self.name);
    _self.currentHealth = UnitHealth(_self.name);
    _self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, _self.currentHealth), _self.maxHealth);
    _self.frame.HealthBar_Button.HealthBar:SetValue(_self.currentHealth);
end;

-- Constructor for the HF_Unit class.
function HF_Unit.new(_unitName, _parentFrame)
    local self = setmetatable({}, HF_Unit);

    -- Generate the unit frame.
    self.frame = CreateFrame('Frame', _unitName .. 'UnitFrame', _parentFrame, 'HF_UnitFrame');
    self.frame.unitName = _unitName;

    -- Initialize healthbar spell.
    self.frame.HealthBar_Button:SetAttribute('spell', 'Flash of Light');

    -- Set initial stats.
    self.name = _unitName;
    self.maxHealth = UnitHealthMax(_unitName);
    self.currentHealth = UnitHealth(_unitName);

    -- Set the frame to match.
    self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame.HealthBar_Button.HealthBar:SetValue(self.currentHealth);

    -- Set class level functions.
    self.UpdateHealth = HF_UpdateHealth;

    -- Create initial spell buttons.\
    for i, spell in pairs(HF_SpellBook) do
        local newButton = HF_SpellButton.new(spell.name, self.frame, _unitName);
        newButton.frame:SetPoint('BOTTOMLEFT', (i - 1) * 32, 0);
    end;
    return self;
end;

function HF_HealthbarClicked(_frame)
    print(_frame.unitName);
end;
