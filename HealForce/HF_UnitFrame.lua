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

local BUTTON_SIZE = 32; -- Square size in pixels.

-- Update health for an HF_Unit class instance.
local function UpdateHealth(_self)
    _self.maxHealth = UnitHealthMax(_self.name);
    _self.currentHealth = UnitHealth(_self.name);
    _self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, _self.currentHealth), _self.maxHealth);
    _self.frame.HealthBar_Button.HealthBar:SetValue(_self.currentHealth);
    
    -- If there are incoming heals, it's status bar needs to be updated to match.
    if _self.hasIncomingHeals then
        _self:UpdateHealPrediction();
    end;
end;

-- Manipulates the heal-prediction bar on the HF_Unit class instance.
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

local function CreateSpellSlot(_self, _slotNumber, _spellName, _target)
    local newButton = HF_SpellButton.new(_spellName, _self.frame, _target);
    newButton.frame:SetPoint('BOTTOMLEFT', (_slotNumber - 1) * BUTTON_SIZE, 0);

    -- When a spell slot is created, it must be able to be re-used.
    -- Register it in the table for this purpose only.
    table.insert(_self.spellSlots, newButton);
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
    self.CreateSpellSlot = CreateSpellSlot;

    return self;
end;

-- When the healthbar is clicked, cast it's associated spell.
function HF_HealthbarClicked(_frame)
    print(_frame.unitName);
end;
