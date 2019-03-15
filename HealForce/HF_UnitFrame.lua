-- Init local variables.
local _, hf = ...;

HF_Unit = {
    frame = nil;
    maxHealth = 100;
    currentHealth = 100;
};
HF_Unit.__index = HF_Unit;

-- Update health for the HF_Unit class
local function UpdateHealth(self)
    self.maxHealth = UnitHealthMax(unitName);
    self.currentHealth = UnitHealth(unitName);
    self.frame:SetMinMaxValues(math.min(0, currentHealth), maxHealth);
    self.frame:SetValue(currentHealth);

    print('Update Health');
end;

function HF_Unit.new(unitName, parentFrame)
    local self = setmetatable({}, HF_Unit);

    -- Generate the unit frame.
    self.frame = CreateFrame('StatusBar', unitName .. 'UnitFrame', parentFrame, 'HF_UnitFrame');

    -- Set initial stats.
    self.maxHealth = UnitHealthMax(unitName);
    self.currentHealth = UnitHealth(unitName);

    -- Set the frame to match.
    self.frame:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame:SetValue(self.currentHealth);

    self.updateHealth = UpdateHealth;

    return self;
end;

-- function HF_UnitFrame_Initialize(frame)
--     frame:RegisterEvent('UNIT_HEALTH');
--     frame:RegisterEvent('UNIT_MAXHEALTH');
--     frame:SetScript('OnEvent', function (self, event)
--         if (event == 'UNIT_HEALTH') then
--             UpdateHealth(self);
--         elseif (event == 'UNIT_MAXHEALTH') then
--             SetMaxHealth();
--         end;
--     end);
-- end;
