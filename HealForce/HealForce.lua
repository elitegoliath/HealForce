local _, hf = ...;

print('HealForce.lua loaded.')

hf.isLocked = false;

local TestFrame = CreateFrame('Frame', 'Test_Frame', UIParent, 'HF_GroupFrame');

TestFrame:SetSize(300, 300);
TestFrame:SetPoint('CENTER', UIParent, 'CENTER');

function StartDrag()
    TestFrame:StartMoving();
end;

function StopDrag()
    TestFrame:StopMovingOrSizing();
end;