function obj = MvObj(X_multiview, Y_multiview, Wj)
% compute the objective value of optimization problem

% acquire the struct information of input data
V = size(X_multiview, 2);                   % V views
N = size(X_multiview{1}, 2);                % N samples
c_name = unique(Y_multiview{1});            % the labels of c classes
c = length(unique(Y_multiview{1}));         % c classes
di = [];                                    % the dimensions of v views
for i = 1:V
    di(i) = size(X_multiview{i}, 1);        
end

% compute the mean and number of jth view, ith calss
% initialization
uij = cell(c, V);
Nij = zeros(c, V);
for j = 1:V
    for i = 1:c
        uij{i,j} = zeros(di(j),1);
        Nij(i,j) = length(find(Y_multiview{j} == c_name(i)));
    end
end
% compute the mean of jth view, ith class
for j = 1:V
    for i = 1:c
        for k = find(Y_multiview{j} == c_name(i))
            uij{i,j} = uij{i,j} + X_multiview{j}(:,k);
        end
        uij{i,j} = uij{i,j}/Nij(i,j);
    end
end
% compute the total mean
u = size(Wj, 2);
for j = 1:V
    for i = 1:c
        u =u + Nij(i,j) * Wj{j}' * uij{i,j}; 
    end
end
u = u/(N * V);

% compute the numerator anf denominator of optimization problem,
% leading to the value of objective funtion
numerator = 0; numerator_fir = 0; numerator_sec = 0;
denominator = 0;
% compute the numerator 
% compute the numerator_fir
for j = 1:V
    for i = 1:c
        for k = find(Y_multiview{j} == c_name(i))
            numerator_fir = numerator_fir + norm(Wj{j}'*(X_multiview{j}(:,k) - uij{i,j}),1);
        end
    end
end
% compute the numerator_sec
for j = 1:V
    for l = 1:V
        numerator_sec = numerator_sec + norm(pinv(X_multiview{j}' * X_multiview{j}) * X_multiview{j}' * Wj{j} -...
            pinv(X_multiview{l}' * X_multiview{l}) * X_multiview{l}' * Wj{l}, 2)^2;
    end
end
numerator =  numerator_fir + numerator_sec;

% compute the denominator
for j = 1:V
    for i = 1:c
        denominator = denominator + Nij(i, j) * norm(Wj{j}'*uij{i,j} - u, 1);
    end
end

obj = numerator/denominator;





