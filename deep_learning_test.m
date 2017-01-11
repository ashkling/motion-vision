% Install and compile MatConvNet (needed once).
untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta23.tar.gz') ;
cd matconvnet-1.0-beta23
run matlab/vl_compilenn ;

% Download a pre-trained CNN from the web (needed once).
urlwrite(...
  'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
  'imagenet-vgg-f.mat') ;

% Setup MatConvNet.
run matlab/vl_setupnn ;

% Load a model and upgrade it to MatConvNet current version.
net = load('imagenet-vgg-f.mat') ;
net = vl_simplenn_tidy(net) ;

% Obtain and preprocess an image.
im = imread('1.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;

im2 = imread('6.jpg') ;
im_2 = single(im2) ; % note: 255 range
im_2 = imresize(im_2, net.meta.normalization.imageSize(1:2)) ;
im_2 = im_2 - net.meta.normalization.averageImage ;

im3 = imread('11.jpg') ;
im_3 = single(im3) ; % note: 255 range
im_3 = imresize(im_3, net.meta.normalization.imageSize(1:2)) ;
im_3 = im_3 - net.meta.normalization.averageImage ;
% Run the CNN.
res = vl_simplenn(net, im_) ;
res2 = vl_simplenn(net, im_2) ;
res3 = vl_simplenn(net, im_3) ;

featureVector = res(16).x;
featureVector2 = res2(16).x;
featureVector3 = res3(16).x;
concats the layers into a 6x6x768 file
testcat = cat(3,featureVector,featureVector2);
testcat = cat(3,testcat,featureVector3);


% Show the classification result.
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
   net.meta.classes.description{best}, best, bestScore)) ;