-- Init local variables.
local _, hf = ...;
local TestFrame = nil;

-- hf.isLocked = false;

-- hf:RegisterEvent('GROUP_ROSTER_UPDATE');

-- hf:SetScript('OnEvent', function(self, event)
--     script('On Event Firing: ' .. event);
-- end);

function HF_HealForce_Initialize(frame)
    -- Create the first and currently only group frame.
    TestFrame = CreateFrame('Frame', 'Test_Frame', UIParent, 'HF_GroupFrame');
    TestFrame:SetSize(300, 300);
    TestFrame:SetPoint('CENTER', UIParent, 'CENTER');
    TestFrame.isLocked = false;
end;
