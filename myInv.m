function x_inv = myInv(x)
% solve the inverse matrix of matrix x(square matrix)

[U, S1, V] = mySVD(x,size(x, 1));
S = zeros(size(S1));
for i = 1:size(S1,1)
    S(i, i) = 1/S1(i,i);
end
x_inv = V*S*U';

