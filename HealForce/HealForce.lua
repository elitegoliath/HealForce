-- Init local variables.
local _, hf = ...;
-- local TestFrame = nil;

-- hf.isLocked = false;

-- hf:RegisterEvent('GROUP_ROSTER_UPDATE');

-- hf:SetScript('OnEvent', function(self, event)
--     script('On Event Firing: ' .. event);
-- end);

local HF_GroupCollection = {};

local function HF_EventActions(self, event)
    -- if (event == 'UNIT_HEALTH') then
    --     UpdateHealth(self);
    -- elseif (event == 'UNIT_MAXHEALTH') then
    --     SetMaxHealth();
    -- end;
    print(event);
end;

local function HF_RegisterEvents(frame)
    frame:RegisterEvent('UNIT_HEALTH');
    frame:RegisterEvent('UNIT_MAXHEALTH');
    frame:SetScript('OnEvent', HF_EventActions);
end;

function HF_HealForce_Initialize(frame)
    HF_RegisterEvents(frame);

    -- Create the initial group frame containing the player.
    HF_GroupCollection['healer'] = HF_Group.new('myGroupFrame', {'player'});



    -- local testFrame = HF_Group.new({});
    -- testFrame:sendMessage();

    -- local testFrame2 = HF_Group.new({});
    -- testFrame2:sendMessage();
    -- testFrame:sendMessage();


    -- Create the first and currently only group frame.
    -- TestFrame = CreateFrame('Frame', 'Test_Frame', UIParent, 'HF_GroupFrame');
    -- TestFrame:SetSize(300, 300);
    -- TestFrame:SetPoint('CENTER', UIParent, 'CENTER');
    -- TestFrame.isLocked = false;
end;
