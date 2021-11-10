function M = clamp(M,minValue,maxValue)
% contraint M entre minValue et maxValue
if ~isinf(minValue)
    M(M<minValue)=minValue;
end
if ~isinf(maxValue)
    M(M>maxValue)=maxValue;
end
end

