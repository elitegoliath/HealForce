-- Init local variables.
local _, hf = ...;

-- Defaults for an HF_Group class instance.
HF_Group = {
    frame = nil;
    units = {};
};
HF_Group.__index = HF_Group;

-- Constructor for the HF_Group class.
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

-- Drag-to-move controller for the group frame.
function HF_GroupFrame_StartDrag(frame)
    local parent = frame:GetParent();
    parent:StartMoving();
end;

-- Drag-to-move controller for the group frame.
function HF_GroupFrame_StopDrag(frame)
    local parent = frame:GetParent();
    parent:StopMovingOrSizing();
end;
