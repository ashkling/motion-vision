function net = action_net_init(varargin)

opts.batchNormalization = true;
opts.networkType = 'simplenn' ;
opts = vl_argparse(opts, varargin) ;

%play with the learning rate. Increased it to make it learn more with this
%new data
lr = [.3 6] ;

% Define network action_net
net.layers = {} ;



f=1/100 ;

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,768,100, 'single'), zeros(1, 100, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,100,100, 'single'), zeros(1, 100, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,100,50, 'single'), zeros(1, 50, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,50,50, 'single'), zeros(1, 50, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(3,3,50,4, 'single'), zeros(1, 4, 'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;

net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 3, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

%Loss layer
net.layers{end+1} = struct('type', 'softmaxloss') ;

% Meta parameters
%net.meta.normalization.imageSize = [244 244 3 10] ;
net.meta.inputSize = [7 7 768] ;

% net.meta.trainOpts.learningRate = [0.05*ones(1,30) 0.005*ones(1,10) 0.0005*ones(1,5)] ;
% net.meta.trainOpts.weightDecay = 0.0001 ;
% net.meta.trainOpts.batchSize = 100 ;
% net.meta.trainOpts.numEpochs = numel(net.meta.trainOpts.learningRate) ;

% Fill in default values
net = vl_simplenn_tidy(net) ;

% % Switch to DagNN if requested
% switch lower(opts.networkType)
%   case 'simplenn'
%     % done
%   case 'dagnn'
%     net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;
%     net.addLayer('error', dagnn.Loss('loss', 'classerror'), ...
%              {'prediction','label'}, 'error') ;
%   otherwise
%     assert(false) ;
end

