-- Init local variables.
local _, hf = ...;

local MyHealthBar = nil;
local MyHealthBar2 = nil;

function HF_GroupFrame_StartDrag(frame)
    local parent = frame:GetParent();
    parent:StartMoving();
end;

function HF_GroupFrame_StopDrag(frame)
    local parent = frame:GetParent();
    parent:StopMovingOrSizing();
end;

function HF_GroupFrame_Initialize(frame)
    MyHealthBar = CreateFrame('StatusBar', 'My_Health', frame, 'HF_UnitFrame');
    MyHealthBar2 = CreateFrame('StatusBar', 'My_Health2', frame, 'HF_UnitFrame');
    
    MyHealthBar:SetPoint('CENTER', frame, 'CENTER');
    MyHealthBar2:SetPoint('TOP', frame);
end;
