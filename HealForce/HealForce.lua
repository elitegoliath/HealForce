local _, hf = ...;

hf.isLocked = false;

local TestFrame = CreateFrame('Frame', 'Test_Frame', UIParent, 'ArchitypeFrame');

TestFrame:SetSize(300, 300);
TestFrame:SetPoint('CENTER', UIParent, 'CENTER');