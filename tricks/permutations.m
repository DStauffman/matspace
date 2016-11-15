A = 1:2;
B = 3:6;
C = 7:9;
D = 10:11;

% method 1
x = cell(length(A),length(B),length(C),length(D));
for i=1:numel(x)
    x{i} = zeros(4,1);
end

for i = 1:length(A)
    for j = 1:length(B)
        for k = 1:length(C)
            for m = 1:length(D)
                x{i,j,k,m}(1,:) = A(i);
                x{i,j,k,m}(2,:) = B(j);
                x{i,j,k,m}(3,:) = C(k);
                x{i,j,k,m}(4,:) = D(m);
            end
        end
    end
end
x1 = [x{:}]';

% method 2
fullA = repmat(A,[1         length(B) length(C),length(D)]);
fullB = repmat(B,[length(A) 1         length(C) length(D)]);
fullC = repmat(C,[length(A) length(B) 1         length(D)]);
fullD = repmat(D,[length(A)*length(B)*length(C) 1        ]);

x2 = [fullA(:),fullB(:),fullC(:),fullD(:)];

y1 = sortrows(x1)
y2 = sortrows(x2)
y1 - y2
assert(all(all(y1 == y2)));