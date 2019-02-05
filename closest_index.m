function ind = closest_index(val,arr)
%Given a value (val) and an array (arr), returns the index (ind) s.t.
%   arr[ind] is closest to val
mindist = 10000;
ind = -1;
for i = 1:length(arr)
    if abs(arr(i) - val) < mindist
        mindist = abs(arr(i) - val);
        ind = i;
    end
end
end

