% % Install and compile MatConvNet (needed once).
%run matlab/vl_compilenn ;
% 
% % Download a pre-trained CNN from the web (needed once).
% urlwrite(...
% 'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
% 'imagenet-vgg-f.mat') ;
% % 
% % % Setup MatConvNet.
% run matlab/vl_setupnn ;
% 
% % Load a model and upgrade it to MatConvNet current version.
% net = load('imagenet-vgg-f.mat') ;
% net = vl_simplenn_tidy(net) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain and preprocess an image.

new_data = zeros(7, 7, 768, size(imdb.images.data,4), 'single');
dataMean = zeros(7, 7, 768, 'single');



for img_folders = 1: size(imdb.images.data,4)
    
    size(imdb.images.data)
    img_folders
    
    im_ = imdb.images.data(:,:,:,img_folders,1);
    im_ = im_ - imdb.meta.dataMean ;

    im_2 = imdb.images.data(:,:,:,img_folders,2);
    im_2 = im_2 - imdb.meta.dataMean ;

    im_3 = imdb.images.data(:,:,:,img_folders,3);
    im_3 = im_3 - imdb.meta.dataMean ;

  
    % Run the CNN.
    res = vl_simplenn(net, im_) ;
    res2 = vl_simplenn(net, im_2) ;
    res3 = vl_simplenn(net, im_3) ;

    featureVector = res(16).x;
    featureVector2 = res2(16).x;
    featureVector3 = res3(16).x;
    %concats the layers into a 6x6x768 file
    testcat = cat(3,featureVector,featureVector2);
    testcat = cat(3,testcat,featureVector3);
    
    dataMean = dataMean + testcat;
    
    new_data(:,:,:,img_folders) = testcat;
    

    
end

dataMean = dataMean ./ size(imdb.images.data,4);
new_imdb.images.data = new_data ;
new_imdb.images.labels = imdb.images.labels ;
new_imdb.images.set = imdb.images.set;
new_imdb.meta.sets = imdb.meta.sets ;
new_imdb.meta.classes = imdb.meta.classes;
new_imdb.meta.dataMean = dataMean;

save new_imdb.mat new_imdb -v7.3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Show the classification result.
% scores = squeeze(gather(res(end).x)) ;
% [bestScore, best] = max(scores) ;
% figure(1) ; clf ; imagesc(im) ;
% title(sprintf('%s (%d), score %.3f',...
%    net.meta.classes.description{best}, best, bestScore)) ;