function HF_GetGroupFramePosition(_groupFrame)
    return _groupFrame.point, _groupFrame.relTo, _groupFrame.relPoint, _groupFrame.posX, _groupFrame.posY;
end;

function HF_SetGroupFramePosition(_frameName, ...)
    if (savedSettings.groupFrames[_frameName] == nil) then
        savedSettings.groupFrames[_frameName] = {};
    end;

    local frame = savedSettings.groupFrames[_frameName];
    local _point, _relTo, _relPoint, _posX, _posY = ...;

    frame.point = _point;
    frame.relTo = _relTo;
    frame.relPoint = _relPoint;
    frame.posX = _posX;
    frame.posY = _posY;
end;

function HF_GetGroupFrame(_frameName)
    return savedSettings.groupFrames[_frameName];
end;

function HF_CreateDefaultGlobalSettings()
    savedSettings = {
        groupFrames = {}
    }
end;