-- Defaults for an HF_Group class instance.
HF_Group = {
    frame = nil;
    units = {};
    unitCount = 0;
};
HF_Group.__index = HF_Group;

local UNIT_HEIGHT = -64;

-- Adds a new unit to the frame. Recycles one if one exists but was nilled out.
local function AddUnitFrame(_self, _unitName)
    if _self.unitCount == 0 then
        _self.frame:Show();
    end;

    local newUnit = _self.units[_self.unitCount];

    if newUnit then
        newUnit:UpdateSelf(_unitName);
    else
        newUnit = HF_Unit.new(_unitName, _self.frame);
    end;

    -- Position the unit frame and adjust the count tracker.
    newUnit.frame:SetPoint('TOPLEFT', 0, (UNIT_HEIGHT * _self.unitCount));
    _self.unitCount = _self.unitCount + 1;

    -- Store the new unit.
    _self.units[_unitName] = newUnit;

    -- Also store a reference to the new unit in a flat table list.
    -- Due to the way that events seem to work, this naming format is needed.
    local characterName = GetUnitName(_unitName, false);
    HF_UnitCollection[characterName] = newUnit;
end;

local function ClearUnitFrames(_self)
    _self.frame:Hide();
    _self.unitCount = 0;

    for i, unitFrame in pairs(_self.units) do
        unitFrame:ClearSelf();
    end;
end;

-- Constructor for the HF_Group class.
function HF_Group.new(_frameName)
    local self = setmetatable({}, HF_Group);

    -- Create the group frame.
    self.frame = CreateFrame('Frame', _frameName, UIParent, 'HF_GroupFrame');
    self.frame.isLocked = false;
    self.frame.name = _frameName;
    self.frame:SetSize(300, 300);
    self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    self.frame.dragBar.groupName:SetText(_frameName);
    
    -- Check to see if this frame has a global setting.
    local groupSettings = HF_GetGroupFrame(_frameName);
    if (groupSettings) then
        self.frame:ClearAllPoints();
        self.frame:SetPoint(HF_GetGroupFramePosition(groupSettings));
    else
        self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    end;

    -- Set class level functions.
    self.AddUnitFrame = AddUnitFrame;
    self.ClearUnitFrames = ClearUnitFrames;

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
