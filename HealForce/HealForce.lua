-- Init local variables.
local _, hf = ...;
local MyHealthBar = nil;

hf.isLocked = false;

function StartDrag()
    TestFrame:StartMoving();
end;

function StopDrag()
    TestFrame:StopMovingOrSizing();
end;

local TestFrame = CreateFrame('Frame', 'Test_Frame', UIParent, 'HF_GroupFrame');
local MyHealthBar = CreateFrame('StatusBar', 'My_Health', TestFrame, 'HF_UnitFrame');

MyHealthBar:RegisterEvent('UNIT_HEALTH');
MyHealthBar:SetScript('OnEvent', function (self)
    local currentHealth = UnitHealth('player');
    local maxHealth = UnitHealthMax('player');

    self:SetMinMaxValues(math.min(0, currentHealth), maxHealth);
    self:SetValue(currentHealth);

    print('updated');
end);

TestFrame:SetSize(300, 300);
TestFrame:SetPoint('CENTER', UIParent, 'CENTER');
