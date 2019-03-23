-- Defaults for an HF_Unit class instance.
HF_Unit = {
    frame = nil;
    name = nil;
    maxHealth = 100;
    currentHealth = 100;
    spellSlots = {};
    hasIncomingHeals = false;
};
HF_Unit.__index = HF_Unit;

-- Update health for an HF_Unit class instance.
local function UpdateHealth(_self)
    _self.maxHealth = UnitHealthMax(_self.name);
    _self.currentHealth = UnitHealth(_self.name);
    _self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, _self.currentHealth), _self.maxHealth);
    _self.frame.HealthBar_Button.HealthBar:SetValue(_self.currentHealth);
    
    if _self.hasIncomingHeals then
        _self:UpdateHealPrediction();
    end;
end;

local function UpdateHealPrediction(_self)
    local incomingHealAmount = UnitGetIncomingHeals(_self.name);

    if (incomingHealAmount > 0) then
        _self.hasIncomingHeals = true;
        _self.frame.HealthBar_Button.HealPredictBar:SetMinMaxValues(math.min(0, _self.currentHealth), _self.maxHealth);
        _self.frame.HealthBar_Button.HealPredictBar:SetValue(_self.currentHealth + incomingHealAmount);
    else
        _self.hasIncomingHeals = false;
        _self.frame.HealthBar_Button.HealPredictBar:SetValue(0);
    end;
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
    self.frame.HealthBar_Button.HealPredictBar:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame.HealthBar_Button.HealPredictBar:SetValue(0);

    -- Set class level functions.
    self.UpdateHealth = UpdateHealth;
    self.UpdateHealPrediction = UpdateHealPrediction;

    -- Create initial spell buttons.
    for i, spell in pairs(HF_SpellBook) do
        local newButton = HF_SpellButton.new(spell.name, self.frame, _unitName);
        newButton.frame:SetPoint('BOTTOMLEFT', (i - 1) * 32, 0);

        -- When a spell slot is created, it must be able to be re-used.
        -- Register it in the table for this purpose only.
        table.insert(self.spellSlots, newButton);
    end;

    return self;
end;

-- When the healthbar is clicked, cast it's associated spell.
function HF_HealthbarClicked(_frame)
    print(_frame.unitName);
end;
