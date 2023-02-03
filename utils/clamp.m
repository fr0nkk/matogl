function M = clamp(M,minValue,maxValue)
% contraint M entre minValue et maxValue

M = min(max(M,minValue,'includenan'),maxValue,'includenan');

end

