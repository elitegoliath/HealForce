-- Defaults for an HF_Unit class instance.
HF_Unit = {
    frame = nil;
    name = nil;
    role = nil;
    maxHealth = 100;
    currentHealth = 100;
    spellSlots = {};
    hasIncomingHeals = false;
};
HF_Unit.__index = HF_Unit;

local BUTTON_SIZE = 32; -- Square size in pixels.

-- Update health for an HF_Unit class instance.
function HF_Unit.updateHealth(_self)
    local maxHealth = UnitHealthMax(_self.name);
    local currentHealth = UnitHealth(_self.name);
    _self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(0, maxHealth);
    _self.frame.HealthBar_Button.HealthBar:SetValue(currentHealth);
    
    -- If there are incoming heals, it's status bar needs to be updated to match.
    if _self.hasIncomingHeals then
        _self:UpdateHealPrediction();
    end;
end;

-- Manipulates the heal-prediction bar on the HF_Unit class instance.
function HF_Unit.updateHealPrediction(_self)
    local incomingHealAmount = UnitGetIncomingHeals(_self.name);

    if (incomingHealAmount > 0) then
        local maxHealth = UnitHealthMax(_self.name);
        local currentHealth = UnitHealth(_self.name);
        _self.hasIncomingHeals = true;
        _self.frame.HealthBar_Button.HealPredictBar:SetMinMaxValues(0, maxHealth);
        _self.frame.HealthBar_Button.HealPredictBar:SetValue(currentHealth + incomingHealAmount);
    else
        _self.hasIncomingHeals = false;
        _self.frame.HealthBar_Button.HealPredictBar:SetValue(0);
    end;
end;

-- Creates a new spell slot for use under each UnitFrame.
function HF_Unit.createSpellSlot(_self, _slotNumber, _spellName, _target)
    -- local newButton = HF_SpellButton.new(_spellName, _self.frame, _target);
    -- newButton.frame:SetPoint('BOTTOMLEFT', (_slotNumber - 1) * BUTTON_SIZE, 0);

    -- When a spell slot is created, it must be able to be re-used.
    -- Register it in the table for this purpose only.
    -- table.insert(_self.spellSlots, newButton);
end;


function HF_Unit.clear(_self)
    _self.frame:Hide();
    _self.name = nil;
    _self.role = nil;
    _self.maxHealth = 100;
    _self.currentHealth = 100;
    _self.hasIncomingHeals = false;

    -- for i, slot in pairs(_self.spellSlots) do
    --     slot:ClearSlot();
    -- end;
end;

function HF_Unit.update(_self, _unitName, _unitRole)
    local characterDisplayName = GetUnitName(_unitName, false);

    _self.frame.unitName = _unitName;
    _self.frame.HealthBar_Button.HealthBar.unitName:SetText(characterDisplayName);
    _self.name = _unitName;
    _self.role = _unitRole;
    _self:UpdateHealth();
end;


-- Constructor for the HF_Unit class.
function HF_Unit.new(_unitName, _unitRole, _parentFrame)
    print('New Unit Frame');
    local self = setmetatable({}, HF_Unit);
    local characterDisplayName = GetUnitName(_unitName, false);

    -- Generate the unit frame.
    self.frame = CreateFrame('Frame', _unitName .. 'UnitFrame', _parentFrame, 'HF_UnitFrame');
    self.frame.unitName = _unitName;
    self.frame.HealthBar_Button.HealthBar.unitName:SetText(characterDisplayName);

    -- Initialize healthbar spell.
    self.frame.HealthBar_Button:SetAttribute('spell', 'Flash of Light');
    self.frame.HealthBar_Button:SetAttribute('unit', _unitName);

    -- Set initial stats.
    self.name = _unitName;
    self.role = _unitRole;

    -- Set the frame to match.
    local maxHealth = UnitHealthMax(_unitName);
    local currentHealth = UnitHealth(_unitName);
    self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(0, maxHealth);
    self.frame.HealthBar_Button.HealthBar:SetValue(currentHealth);
    self.frame.HealthBar_Button.HealPredictBar:SetMinMaxValues(0, maxHealth);
    self.frame.HealthBar_Button.HealPredictBar:SetValue(0);

    return self;
end;
