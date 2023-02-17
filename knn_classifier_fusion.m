function AC = knn_classifier_fusion(W,d,x_train,y_train,x_test,y_test,k)

if nargin == 6
    k = 1;
end

V = length(x_train);
x_train_prj = zeros(size(x_train{1,1}'*W{1,1}(:,1:d)));
x_test_prj = zeros(size(x_test{1,1}'*W{1,1}(:,1:d)));
for v = 1:V
    x_train_prj = x_train_prj + x_train{1,v}'*W{1,v}(:,1:d);
    x_test_prj = x_test_prj + x_test{1,v}'*W{1,v}(:,1:d);
end
y_train = y_train{1,1};
y_test = y_test{1,1};

[IDX,~] = knnsearch(x_train_prj,x_test_prj,'K',k);
pre_y_test = y_train(:,IDX);
AC = sum(pre_y_test == y_test)/numel(y_test);

end
