function [W, Wj] = L1MvDAVC(X_multiview, Y_multiview, d, sig, lr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alg1: Robust multi-view discriminant analysis with view consistency.
%
% Useage: [W, Wj] = L1MvDAVC(X_multiview, Y_multiview, d, sig, lr)
% 
% Input: X_multiview - v views data
%        Y_multiview - label
%        d - the dimension of projected space
%        sigma - penalty parameter
%
% Output: W - projected matrix
%
% Author: Yang Xiangfei (Email: yxf9011@163.com);  Date: 2020/11/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 4
    lr = 0.1;   % learining rate
end

% acquire the struct information of input data
V = size(X_multiview, 2);                   % V views
N = size(X_multiview{1}, 2);                % N samples
c_name = unique(Y_multiview{1});            % the labels of c classes
c = length(unique(Y_multiview{1}));         % c classes
dii = [];                                   % the dimensions of v views
for i = 1:V
    dii(i) = size(X_multiview{i}, 1);        
end

% stop criterion 
maxIter = 100;
tol = 1e-6;

X = X_multiview;
Tj = cell(1, V);
for j = 1:V
    Tj{j} = eye(dii(j));
end

W = []; Wj = cell(1, V);
%%% compute d PCs
for dd = 1:d
    % 每个视角下数据转换 Xj = Tj' * X_multiview{j}
    for j = 1:V
        X{j} = Tj{j}' * X_multiview{j};  
    end
    
    % 计算di
    di = [];                                    % the dimensions of v views
    for j = 1:V
        di(j) = size(X{j}, 1);        
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
    % compute the mean 
    for j = 1:V
        for i = 1:c
            for k = find(Y_multiview{j} == c_name(i))
                uij{i,j} = uij{i,j} + X{j}(:,k);
            end
            uij{i,j} = uij{i,j}/Nij(i,j);
        end
    end
    
    % initialize W0 and separate the W0 by views
    rand('seed', dd)
    W0 = rand(sum(di), 1); W0 = W0/norm(W0);
    W0j = cell(1, V);
    for v = 1:V
        W0j{1, v} = W0((sum(di(1:(v-1))) + 1):sum(di(1:v)), :);
    end
    
    iter = 0;
%     fprintf('===== 第 %d 主成分=====  \n', dd);
%     fprintf('%d, %f \n', iter, MvObj(X, Y_multiview, W0j));
    while 1      
        %%% compute the gradient
        % compute P(t)
        P = zeros(sum(di), sum(di));
        for j = 1:V
            Pj = zeros(di(j));
            for i = 1:c
                % compute Sj, the scatter matrix of jth view, ith class
                for k = find(Y_multiview{j} == c_name(i))
                    Pj = Pj + (X{j}(:,k) - uij{i,j}) * (X{j}(:,k) - uij{i,j})'/...
                        norm(W0j{j}' * (X{j}(:,k) - uij{i,j}), 1);
                end
            end
            % compute S
            P((sum(di(1 : (j - 1))) + 1) : sum(di(1 : j)), (sum(di(1 : (j - 1))) + 1) : sum(di(1 : j))) = Pj;
        end
        % compute M, the view consistency matrix
        M = zeros(sum(di), sum(di));
        for j = 1:V
            for l = 1:V
                if j == l
                    M((sum(di(1 : (j - 1))) + 1) : sum(di(1 : j)), (sum(di(1 : (l - 1))) + 1) : sum(di(1 : l))) = ...
                        2*(V - 1) * X{j} * myInv(X{j}' * X{j}) * myInv(X{j}' * X{j}) * X{j}';
                else
                    M((sum(di(1 : (j - 1))) + 1) : sum(di(1 : j)), (sum(di(1 : (l - 1))) + 1) : sum(di(1 : l))) = ...
                        2*(V - 1) * X{j} * myInv(X{j}' * X{j}) * myInv(X{l}' * X{l}) * X{l}';
                end      
            end
        end
        % compute the sum of |a_ijk(t)|
        a_sum = 0;
        for j = 1:V
            for i = 1:c
                for k = find(Y_multiview{j} == c_name(i))
                    a_sum = a_sum + norm(W0j{j}' * (X{j}(:, k) - uij{i, j}));
                end
            end
        end
        % compute B(t)
        B_tidle = zeros(sum(di), 1); B = cell(1, V); 
        Sij = zeros(c, V);      % compute the sign
        temp1 = 0;    % compute temp variable, sum_sum_N*w(t)'*u
        % compute temp1 variable, sum_sum_N*w'*u
        for j =1:V
            for i = 1:c
                temp1 = temp1 +  Nij(i, j) * W0j{j}' * uij{i, j};
            end
        end
        % compute the sign
        for j =1:V
            for i = 1:c
                Sij(i, j) = sign(W0j{j}' * uij{i, j} - (1/(N * V)) * temp1);
            end
        end
        %  compute temp2 variable, sum_sum_N*S(t)
        temp2 = 0;
        for j = 1:V
            for i =1:c
                temp2 = temp2 + Nij(i, j) * Sij(i, j);
            end
        end
        % B(t)
        % initialization
        for j = 1:V
            B{j} = zeros(di(j), 1);
        end
        for j = 1:V
            for i = 1:c
                 B{j} = B{j} + Nij(i, j) * Sij(i, j) * uij{i, j} - (1/(N * V)) * temp2 * Nij(i, j) * uij{i, j};
            end
            B_tidle((sum(di(1 : (j - 1))) + 1) : sum(di(1 : j))) = B{j};
        end    
        
        % compute gradient g(.)
        g = zeros(sum(di), 1);
        g = g + 2 * (P + sig * M + sig * M') * W0/(W0' * (P + 2 * sig * M) * W0 + a_sum) -...
                B_tidle/(W0' * B_tidle);
        
        %%% compute W(t+1)
        W1 = zeros(sum(di), 1);
        W1 = W0 - lr * g;
        W1j = cell(1, V);
        for v = 1:V
            W1j{1, v} = W1((sum(di(1:(v-1))) + 1):sum(di(1:v)), :);
        end
        
        iter = iter + 1;
%         fprintf('%d, %f \n', iter, MvObj(X, Y_multiview, W1j));
        %%% stop criterion 
        if (MvObj(X, Y_multiview, W1j) - MvObj(X, Y_multiview, W0j) > -tol) || (iter >= maxIter)
            if MvObj(X, Y_multiview, W1j) > MvObj(X, Y_multiview, W0j)
                W1j = W0j;
                W1 = W0;
%                 fprintf('%d, %f \n', iter, MvObj(X, Y_multiview, W1j))
            end
            break;
        end
        %%% update next W
        W0 = W1;
        W0j = W1j;
    end
    
    % transfer Wj to original space
    % compute Wj, Tj
    for j = 1:V
        W1j{j} = Tj{j} * W1j{j};
        Wj{j} = [Wj{j}, W1j{j}];
        Tj{j} = null(Wj{j}');
    end
    W11 = zeros(sum(dii), 1);
    for j = 1:V
        W11((sum(dii(1:(j - 1))) + 1):sum(dii(1:j)), :) = W1j{j};
    end
    % compute W
    W = [W, W11];
end

end





