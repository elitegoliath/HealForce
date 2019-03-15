-- Init local variables.
local _, hf = ...;

-- Defaults for an HF_Unit class instance.
HF_Unit = {
    frame = nil;
    name = nil;
    maxHealth = 100;
    currentHealth = 100;
};
HF_Unit.__index = HF_Unit;

-- Update health for an HF_Unit class instance.
local function HF_UpdateHealth(self)
    self.maxHealth = UnitHealthMax(self.name);
    self.currentHealth = UnitHealth(self.name);
    self.frame:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame:SetValue(self.currentHealth);
end;

-- Constructor for the HF_Unit class.
function HF_Unit.new(unitName, parentFrame)
    local self = setmetatable({}, HF_Unit);

    -- Generate the unit frame.
    self.frame = CreateFrame('StatusBar', unitName .. 'UnitFrame', parentFrame, 'HF_UnitFrame');

    -- Set initial stats.
    self.name = unitName;
    self.maxHealth = UnitHealthMax(unitName);
    self.currentHealth = UnitHealth(unitName);

    -- Set the frame to match.
    self.frame:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame:SetValue(self.currentHealth);

    -- Set class level functions.
    self.UpdateHealth = HF_UpdateHealth;

    return self;
end;
