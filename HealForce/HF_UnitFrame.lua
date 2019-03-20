-- Init local variables.
-- local _, hf = ...;

-- Defaults for an HF_Unit class instance.
HF_Unit = {
    frame = nil;
    name = nil;
    spellButtons = {};
    maxHealth = 100;
    currentHealth = 100;
};
HF_Unit.__index = HF_Unit;

-- Update health for an HF_Unit class instance.
local function HF_UpdateHealth(self)
    self.maxHealth = UnitHealthMax(self.name);
    self.currentHealth = UnitHealth(self.name);
    self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame.HealthBar_Button.HealthBar:SetValue(self.currentHealth);
end;

-- Constructor for the HF_Unit class.
function HF_Unit.new(unitName, parentFrame)
    local self = setmetatable({}, HF_Unit);

    -- Generate the unit frame.
    self.frame = CreateFrame('Frame', unitName .. 'UnitFrame', parentFrame, 'HF_UnitFrame');
    self.frame.unitName = unitName;

    -- Initialize healthbar spell.
    self.frame.HealthBar_Button:SetAttribute('spell', 'Flash of Light');

    -- Set initial stats.
    self.name = unitName;
    self.maxHealth = UnitHealthMax(unitName);
    self.currentHealth = UnitHealth(unitName);

    -- Set the frame to match.
    self.frame.HealthBar_Button.HealthBar:SetMinMaxValues(math.min(0, self.currentHealth), self.maxHealth);
    self.frame.HealthBar_Button.HealthBar:SetValue(self.currentHealth);

    -- Set class level functions.
    self.UpdateHealth = HF_UpdateHealth;

    -- Create initial spell buttons.
    local spellSlot = 1;
    for i, spell in pairs(HF_SpellBook) do


        -- TODO: Use spell order class property to place them properly.
        -- It's currently arbitrary. The slots must be defined somehow.


        local newButton = HF_SpellButton.new(i, self.frame, unitName);
        newButton.frame:SetPoint('BOTTOMLEFT', (spellSlot - 1) * 32, 0);
        
        self.spellButtons['Spell'..spellSlot] = newButton;

        spellSlot = spellSlot + 1;
    end;
    return self;
end;

function HF_HealthbarClicked(frame)
    print(frame.unitName);
end;
