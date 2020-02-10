local PathsUtil = {};

PathsUtil.imagePath_ = "";
PathsUtil.SetImagePath = function(v)
    PathsUtil.imagePath_ = v;
end

PathsUtil.ImagePath = function(p)
    return PathsUtil.imagePath_ .. p;
end

return PathsUtil;