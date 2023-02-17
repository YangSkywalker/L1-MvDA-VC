%% ===== MNIST-USPS =====
clear all; clc

load('E:\MatLab2019a\work\RMvDA\Data\MNIST-USPS.mat'); 
data_path = 'E:\MatLab2019a\work\RMvDA\Data\MNIST-USPS.mat';

V = length(X);

% set parameter
train_ratio = 0.7;             % the ratio of train and test
noiseImg_ratio = 0.7;          % the ratio of noisy images in the training set
noiseDensity = 8;             % block noise   ; noise_model = 2

iterations=10;           % repeat 15 times
pcomp=80;                % the number of principal component
maxDim=400;              % maximal dimension 
space=linspace(5,maxDim,pcomp); 
interval=5;

%%% store accuracy, 3 views 
% RMvDA-vc
RMvDAvc_acc_view = cell(1,V);
RMvDAvc_acc =  [];

fprintf('Processing...... \n');
for i = 1:iterations
    % prepare the dataset of train and test
    noise_model = 0; % 1 - salt&pepper nosie, 2 - block nosie, 3 - black block, 0 - without noise 
    [Xtrain, Ytrain, Xtest, Ytest] = randomSplit(data_path, train_ratio ,noiseImg_ratio, noiseDensity, noise_model);
    
    % compute principal components of RMvDA-VC(sig = 1)
    start_time = clock;
    sig = 1; lr = 0.1;
    [W_RMvDA, Wj_RMvDA] = L1MvDAVC(Xtrain, Ytrain, maxDim, sig, lr);
    % acc
    for j = space
        for v = 1:V
            RMvDAvc_acc_view{1,v}(i,j/interval) = knn_classifier(Wj_RMvDA{1,v}(:,1:j), Xtrain{1,v}, Ytrain{1,v}, Xtest{1,v}, Ytest{1,v});
        end
        RMvDAvc_acc(i,j/interval) = knn_classifier_fusion(Wj_RMvDA,j,Xtrain,Ytrain,Xtest,Ytest); 
    end
    end_time = clock;
    fprintf('This is the %d-th iteration of L1-MvDA-VC(sig = 1) on MNIST-USPS with original data, the elapsed time is %f s \n',i,etime(end_time,start_time));     
end

save('E:\MatLab2019a\work\RMvDA\result\MNIST-USPS_original','RMvDAvc_acc','RMvDAvc_acc_view');






