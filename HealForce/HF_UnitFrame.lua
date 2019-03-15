-- Init local variables.
local _, hf = ...;

-- local maxHealth = 100;
-- local currentHealth = 100;

HF_Unit = {
    maxHealth = 100;
    currentHealth = 100;
};

local function SetMaxHealth()
    maxHealth = UnitHealthMax('player');
end;

local function UpdateHealth(frame)
        currentHealth = UnitHealth('player');
        frame:SetMinMaxValues(math.min(0, currentHealth), maxHealth);
        frame:SetValue(currentHealth);
        print('updated');
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
