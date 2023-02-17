function nX = blockPollute(X, Y, noiseRatio, num, imgL, imgW)
% function£ºadd block noise to multi-view data
% X - multi-view data
% noiseRatio - the ratio of noise for every class
% typeNoise - the noise type. sp - salt & pepper, g - gaussian, b - block
% num - the size of block, noise density
% imgL - the length of image
% imgW - the width of image

V = 1;
viewType = cell(length(unique(Y)), V);

%%% choose the index added noise
for v = 1:V
    for i = 1:size(X,2)
        viewType{Y(i),v}(length(viewType{Y(i),v}) + 1) = i;  
    end
end

noiseIdx = cell(1, V);
for v = 1:V
    for i = 1:length(unique(Y))
        noise_Idx = randperm(length(viewType{i,v}),round(length(viewType{i,v})*noiseRatio));
        noise_Idx  = sort(noise_Idx);
        noiseIdx{1,v}((length(noiseIdx{1,v})+1):(length(noiseIdx{1,v})+length(noise_Idx)))=viewType{i,v}(noise_Idx);
    end
end
%%% add noise
nX = X;
for v = 1:V
    if nargin == 4
        imgL = sqrt(size(nX,1));  imgW = sqrt(size(nX,1));
    end
    for i = 1:length(noiseIdx{1,v})
        img = reshape(nX(:,noiseIdx{1,v}(i)),imgL,imgW);
        point_x = imgL - num + ;
        point_y = imgW  - num + 1;
%         noise_vector = sign(randn(num^2,1)); index = find(noise_vector<=0);
%         noise_vector(index) = 0;
        % give the left-up point of block noise
        start_point(1) = randperm(point_x,1);
        start_point(2) = randperm(point_y,1);
        img(start_point(1):start_point(1)+num-1,start_point(2):start_point(2)+num-1)=zeros(num,num);
%         img_noise = imnoise(img, 'salt & pepper', noiseDensity);
        nX(:,noiseIdx{1,v}(i)) = reshape(img, numel(img),1);
    end
end

