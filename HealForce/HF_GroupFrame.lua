-- Defaults for an HF_Group class instance.
HF_Group = {
    frame = nil;
    unitPool = nil;
    unitCount = 0;
};
HF_Group.__index = HF_Group;

local UNIT_HEIGHT = -64;

-- Adds a new unit to the frame. Recycles one if one exists but was nilled out.
function HF_Group.addUnitFrame(_self, _unitName)



    -- if _self.unitCount == 0 then
    --     _self.frame:Show();
    -- end;

    -- local newUnit = _self.units[_self.unitCount];

    -- if newUnit then
    --     newUnit:UpdateSelf(_unitName);
    -- else
    --     newUnit = HF_Unit.new(_unitName, _self.frame);
    -- end;

    -- -- Position the unit frame and adjust the count tracker.
    -- newUnit.frame:SetPoint('TOPLEFT', 0, (UNIT_HEIGHT * _self.unitCount));
    -- _self.unitCount = _self.unitCount + 1;

    -- -- Store the new unit.
    -- _self.units[_unitName] = newUnit;

    -- -- Also store a reference to the new unit in a flat table list.
    -- -- Due to the way that events seem to work, this naming format is needed.
    -- local characterName = GetUnitName(_unitName, false);
    -- HF_UnitCollection[characterName] = newUnit;
end;

function HF_Group.clearUnitFrames(_self)
    _self.frame:Hide();
    _self.unitCount = 0;

    for i, unitFrame in pairs(_self.units) do
        unitFrame:ClearSelf();
    end;
end;

function HF_Group.update(_self, _frameName)
    print('Existing Group Frame');
    _self.frame:Show();
    _self.frame.name = _frameName;
    _self.frame.dragBar.groupName:SetText(_frameName);
    _self.unitCount = 0;
end;

function HF_Group.clear(_self)
    print('Clearing Group Frame');
    _self.frame:Hide();
    _self.frame.name = nil;
    _self.unitCount = nil;

    -- TODO: Clear Units when a pool is set up for that.
end;

-- Constructor for the HF_Group class.
function HF_Group.new(_frameName)
    print('New Group Frame');
    local self = setmetatable({}, HF_Group);

    -- Create the group frame.
    self.frame = CreateFrame('Frame', _frameName, UIParent, 'HF_GroupFrame');
    self.frame.isLocked = false;
    self.frame.name = _frameName;
    self.frame:SetSize(300, 300);
    self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    self.frame.dragBar.groupName:SetText(_frameName);
    
    -- Check to see if this frame has a global setting.
    local groupSettings = HF_GetGroupFrameSettings(_frameName);
    if (groupSettings) then
        self.frame:ClearAllPoints();
        self.frame:SetPoint(HF_GetGroupFrameSettings_Position(groupSettings));
    else
        self.frame:SetPoint('CENTER', UIParent, 'CENTER');
    end;

    -- Generate a unit pool for this group.
    self.unitPool = HF_ObjectPool.new(HF_Unit);

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
    HF_SetGroupFrameSettings_Position(parent.name, parent:GetPoint());
end;
