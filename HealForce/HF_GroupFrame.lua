-- Init local variables.
local _, hf = ...;

-- local MyHealthBar = nil;
-- local MyHealthBar2 = nil;

HF_Group = {
    frame = nil;
    units = {};
};
HF_Group.__index = HF_Group;

function HF_Group.new(frameName, unitNames)
    local self = setmetatable({}, HF_Group);

    -- Create the group frame.
    self.frame = CreateFrame('Frame', frameName, UIParent, 'HF_GroupFrame');
    self.frame.isLocked = false;
    self.frame:SetSize(300, 300);
    self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    
    -- Create all the units for the new frame.
    for i, unitName in ipairs(unitNames) do
        self.units[unitName] = HF_Unit.new(unitName, self.frame);
    end;

    return self;
end;

function HF_GroupFrame_StartDrag(frame)
    local parent = frame:GetParent();
    parent:StartMoving();
end;

function HF_GroupFrame_StopDrag(frame)
    local parent = frame:GetParent();
    parent:StopMovingOrSizing();
end;

-- function HF_GroupFrame_Initialize(frame)
--     MyHealthBar = CreateFrame('StatusBar', 'My_Health', frame, 'HF_UnitFrame');
--     MyHealthBar2 = CreateFrame('StatusBar', 'My_Health2', frame, 'HF_UnitFrame');
    
--     MyHealthBar:SetPoint('CENTER', frame, 'CENTER');
--     MyHealthBar2:SetPoint('TOP', frame);
-- end;
