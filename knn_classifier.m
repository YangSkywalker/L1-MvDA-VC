function AC = knn_classifier(W,x_train,y_train,x_test,y_test,k)

if nargin == 5
    k = 1;
end

x_train_prj = x_train'*W;
x_test_prj = x_test'*W;
[IDX,~] = knnsearch(x_train_prj,x_test_prj,'K',k);
pre_y_test = y_train(:,IDX);
AC = sum(pre_y_test == y_test)/numel(y_test);

end
