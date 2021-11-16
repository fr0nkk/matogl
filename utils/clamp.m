function M = clamp(M,minValue,maxValue)
% contraint M entre minValue et maxValue

if ~isempty(minValue)
    M(M<minValue)=minValue;
end

if ~isempty(maxValue)
    M(M>maxValue)=maxValue;
end

end

