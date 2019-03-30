HF_ObjectPool = {
    class = nil;
    available = {};
    inUse = {};
};
HF_ObjectPool.__index = HF_ObjectPool;



function HF_ObjectPool.createInstance(_self, _key, ...)
    local newInstance;

    if (#_self.available > 0) then
        newInstance = _self.available.pop();
        newInstance:update(_key, ...);
    else
        newInstance = _self.class.new(_key, ...);
    end;
    
    _self.inUse[_key] = newInstance;

    return newInstance;
end;



function HF_ObjectPool.clearInstance(_self, _key)
    local removedInstance = table.remove(_self.inUse, _key);

    if (removedInstance) then
        removedInstance:clear();
        table.push(_self.available, removedInstance);
    end;
end;



function HF_ObjectPool.getInstance(_self, _key)
    return _self.inUse[_key];
end;



function HF_ObjectPool.getOrCreateInstance(_self, _key, ...)
    local instance = _self:getInstance(_key);

    if not (instance) then
        instance = _self:createInstance(_key, ...);
    end;

    return instance;
end;


-- Searches through all instances in this pool for a specific prop or table value from inUse instances.
function HF_ObjectPool.findInAll(_self, _prop, _key)
    local foundValue = nil;

    for k, v in pairs(_self.inUse) do
        local foundProp = v[_prop];
    end;

    return foundValue;
end;

-- A function for finding properties inside of the table of inUse objects.
function HF_ObjectPool.findIn(_self, _poolKey, _prop, _key)
    local foundValue = nil;
    local pool = _self.inUse[_poolKey];

    -- If the desired instance exists in this pool, proceed...
    if pool then
        local foundProp = pool[_prop];
        
        if (_key) and (foundProp) then
            -- If a key is provided, then we're looking inside a table for a value.
            foundValue = foundProp[_key];
        else
            -- The property IS the value.
            foundValue = foundProp;
        end;
    end;

    return foundValue;
end;

-- Instantiates a new pool for a specific class.
-- This class will be used to generate new instances of objects from.
function HF_ObjectPool.new(_class)
    local self = setmetatable({}, HF_ObjectPool);
    self.class = _class;
    return self;
end;
