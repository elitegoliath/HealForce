HF_ObjectPool = {
    class = nil;
    available = {};
    inUse = {};
};
HF_ObjectPool.__index = HF_ObjectPool;


-- NOTE: Typically the _key passed into each function is also the first param
    -- passed into each "new" and "update" function for the class instance.
    -- This is so that the key of the instance is certain to be synced with
    -- the data within.


-- Checks the available pool for unused instances.
-- If none exist, creates a new one.
function HF_ObjectPool.createInstance(_self, _key, ...)
    local newInstance;

    if (#_self.available > 0) then
        -- If there are instances that can be recycled, do it.
        newInstance = _self.available.pop();
        newInstance:update(_key, ...);
    else
        -- Generate a new instance.
        newInstance = _self.class.new(_key, ...);
    end;
    
    -- Add the new instance to the inuse table.
    _self.inUse[_key] = newInstance;

    return newInstance;
end;


-- Calls the clear method on the instance class,
-- then puts the instance into the available table.
function HF_ObjectPool.clearInstance(_self, _key)
    local removedInstance = table.remove(_self.inUse, _key);

    if (removedInstance) then
        removedInstance:clear();
        table.push(_self.available, removedInstance);
    end;
end;

-- Clears all of the inUse objects in a pool.
function HF_ObjectPool.clearAll(_self)
    for k, v in pairs(_self.inUse) do
        _self:clearInstance(k);
    end;
end;

-- Gets a specific instance from the pool.
-- Returns nil if it doesn't exist.
function HF_ObjectPool.getInstance(_self, _key)
    return _self.inUse[_key];
end;

-- Returns the inUse table.
function HF_ObjectPool.getAll(_self)
    return _self.inUse;
end;

-- Attempts to get an existing instance of a pool object.
-- If none are found, it creates a new one.
function HF_ObjectPool.getOrCreateInstance(_self, _key, ...)
    local instance = _self:getInstance(_key);

    if not (instance) then
        -- If no matching instance is currently in use, get one from available or create a new one.
        instance = _self:createInstance(_key, ...);
    else
        -- If we are using a recycled instance, update it with the same values
        -- that would have been passed in if we were making a new one.
        instance:update(_key, ...);
    end;

    return instance;
end;


-- Searches through all instances in this pool for a specific prop or table value from inUse instances.
function HF_ObjectPool.findInAll(_self, _prop, _key, _isNestedPool)
    _isNestedPool = _isNestedPool or false;
    local foundValue = nil;

    for k, v in pairs(_self.inUse) do
        local foundProp = v[_prop];

        if (_key) and (foundProp) then
            -- If a key is provided, then we're looking inside a table for a value.
            if (_isNestedPool) then
                -- If the nested table is another pool...
                foundValue = foundProp:getInstance(_key);
            else
                foundValue = foundProp[_key];
            end;
        else
            -- The property IS the value.
            foundValue = foundProp;
        end;

        -- Exit the loop if the sought after value was found.
        if foundValue then break end;
    end;

    return foundValue;
end;

-- A function for finding properties inside of the table of inUse objects.
function HF_ObjectPool.findIn(_self, _poolKey, _prop, _key, _isNestedPool)
    _isNestedPool = _isNestedPool or false;
    local foundValue = nil;
    local pool = _self.inUse[_poolKey];

    -- If the desired instance exists in this pool, proceed...
    if pool then
        local foundProp = pool[_prop];
        
        if (_key) and (foundProp) then
            -- If a key is provided, then we're looking inside a table for a value.
            if (_isNestedPool) then
                -- If the nested table is another pool...
                foundValue = foundProp:getInstance(_key);
            else
                foundValue = foundProp[_key];
            end;
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
