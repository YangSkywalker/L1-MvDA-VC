function [Xtrain, Ytrain, Xtest, Ytest] = randomSplit(data_path, train_ratio, noiseImg_ratio, noiseDensity,model, imgL, imgW)
% function: split train set and test set by the given ratio

load(data_path)
V = length(X);
num = length(Y{1,1});
Ind = cell(length(unique(Y{1,1})),1);

%%% choose the index of train set and test set 
for i = 1:num
    Ind{Y{1,1}(i)}(length(Ind{Y{1,1}(i)}) + 1) = i;  
end
% choose trianInd and testInd
trainInd = cell(1, V);
testInd = cell(1, V);
for i = 1:length(unique(Y{1,1}))
    train_Ind = randperm(length(Ind{i}),round(length(Ind{i})*train_ratio));
    train_Ind  = sort(train_Ind);
    trainInd{1,1}((length( trainInd{1,1})+1):(length(trainInd{1,1})+length(train_Ind)))=Ind{i}(train_Ind);
end
testInd{1,1} = 1:num; testInd{1,1}(trainInd{1,1}) = [];
for v = 2:V
    trainInd{1,v} = trainInd{1,1};
    testInd{1,v} = testInd{1,1};
end
%%% train set and test set
Xtrain = cell(1,V); Ytrain = cell(1,V); 
Xtest = cell(1,V);  Ytest = cell(1,V);
for v = 1:V
    Xtrain{1,v} = X{1,v}(:,trainInd{1,v}); Ytrain{1,v} = Y{1,v}(:,trainInd{1,v});
    Xtest{1,v} = X{1,v}(:,testInd{1,v});   Ytest{1,v} = Y{1,v}(:,testInd{1,v});
end

switch model
    case 1
        %%% choose parts of images from Xtrain to add 'salt & pepper' noise 
        Xtrain = addNoise(Xtrain, Ytrain, noiseImg_ratio, noiseDensity);
    case 2
        %%% choose parts of images from Xtrain to add 'salt & pepper' noise 
        Xtrain = addNoise1(Xtrain, Ytrain, noiseImg_ratio, noiseDensity);
    case 3
        %%% choose parts of images from Xtrain to add 'salt & pepper' noise 
        Xtrain = addNoise2(Xtrain, Ytrain, noiseImg_ratio, noiseDensity);
    case 0 % no operation
end








