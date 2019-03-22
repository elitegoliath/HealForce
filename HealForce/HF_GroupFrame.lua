-- Defaults for an HF_Group class instance.
HF_Group = {
    frame = nil;
    units = {};
};
HF_Group.__index = HF_Group;

-- Constructor for the HF_Group class.
function HF_Group.new(_frameName, _unitNames)
    local self = setmetatable({}, HF_Group);

    -- Create the group frame.
    self.frame = CreateFrame('Frame', _frameName, UIParent, 'HF_GroupFrame');
    self.frame.isLocked = false;
    self.frame.name = _frameName;
    self.frame:SetSize(300, 300);
    self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    
    -- Check to see if this frame has a global setting.
    local groupSettings = HF_GetGroupFrame(_frameName);
    if (groupSettings) then
        self.frame:ClearAllPoints();
        self.frame:SetPoint(HF_GetGroupFramePosition(groupSettings));
    else
        self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    end;
    
    -- Create all the units for the new frame.
    for i, unitName in pairs(_unitNames) do
        self.units[unitName] = HF_Unit.new(unitName, self.frame);
    end;

    return self;
end;

-- Drag-to-move controller for the group frame.
function HF_GroupFrame_StartDrag(_frame)
    local parent = _frame:GetParent();
    parent:StartMoving();
end;

-- Drag-to-move controller for the group frame.
function HF_GroupFrame_StopDrag(_frame)
    local parent = _frame:GetParent();
    parent:StopMovingOrSizing();
    HF_SetGroupFramePosition(parent.name, parent:GetPoint());
end;
