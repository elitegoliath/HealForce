-- Init local variables.
local _, hf = ...;

-- local MyHealthBar = nil;
-- local MyHealthBar2 = nil;

local counter = 1;

HF_Group = {
    units = nil;
    msg = nil;
};
HF_Group.__index = HF_Group;

function HF_Group.new(units)
    local self = setmetatable({}, HF_Group);
    self.units = units;
    self.msg = counter;
    counter = counter + 1;
    return self;
end;

function HF_Group.sendMessage(self)
    print(self.msg);
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
