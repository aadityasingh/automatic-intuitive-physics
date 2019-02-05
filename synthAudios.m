
for i = 1:3
    for j = 1:3
        a=4;
        for k = 1:3
            if k ~= j
                synthesizeShape(i, j, k, a, 0, 0);
%                 disp(i+" "+j+" "+k+" "+a);
                a = a + 1;
            end
        end
    end
end