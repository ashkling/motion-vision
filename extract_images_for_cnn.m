
function extract_images_for_cnn

% setenv('PATH', [getenv('PATH') ':/usr/local/bin/ffmpeg:/bin/bash/ffmpeg']);
% getenv('PATH')

action_dir = '../hmdb51_sta';
bb_dir = '../bb_file/HMDB51';
images_dir = '../action_images';

sizeOfImage = 244;       
sizeOfClip = 15;
sizeOfBatch = 3;
        
actions = dir(action_dir);

label_names = {};
data = zeros(sizeOfImage, sizeOfImage, 3, 0, sizeOfBatch, 'single');
labels = single([]);
set = uint8([]);
dataMean = zeros(sizeOfImage, sizeOfImage, 3, 'single');

for action = actions'
    % ignore .rar folders and hidden folders
    if strfind(action.name, '.')
        continue
    end

    label_names = [label_names action.name];
end

label_names = label_names';

image_counter = 1;

for action = actions'
    
    if strfind(action.name, '.')
        continue
    end
    
    action_name = action.name;
    action_name
    [truefalse, action_index] = ismember(action_name, label_names);
    files = dir(strcat(action_dir, '/', action_name));
    
    % go through each video in that action folder
    for file = files'
        
        % only look at the video files
        [pathstr,name,ext] = fileparts(file.name);
        if ~strcmp(ext,'.avi')
            continue
        end
        
        video_filename = file.name;
        video_filename
        
        % converting video from avi to mp4 format so that VideoReader will
        % work. you may not have to do this is you have a Windows computer
        video_avi_name = strcat(action_dir, '/', action_name, '/', video_filename);
        video_mp4_name = strcat(video_avi_name(1:end-3), 'mp4');
        if ~exist(video_mp4_name, 'file')
        	system(['/usr/local/bin/ffmpeg -i ', video_avi_name, ' ', video_mp4_name]);
        end
        
        % sometimes converting it won't work, so we'll just skip it
        if ~exist(video_mp4_name, 'file')
            continue
        end
        
        % the video where you can extract frames by doing read(video, i),
        % where i is the frame number
        video = VideoReader(video_mp4_name);

        numFrames = video.NumberOfFrames;
        numBatches = uint8(floor(numFrames/sizeOfClip));
        counter = 0;
        
        while counter < numBatches

            batchNum = 0;
            while batchNum < sizeOfBatch

                frame_number = (1 + (batchNum*(sizeOfClip/sizeOfBatch)) + (sizeOfClip * counter));
                frame = read(video, frame_number);
                frame = imresize(frame, [sizeOfImage sizeOfImage]);
                if size(frame,3) == 1
                    frame = cat(3, frame, frame, frame);
                end
                
                batchNum = batchNum + 1;
                data(:,:,:,image_counter,batchNum) = im2single(frame);
                
                labels = [labels action_index];
                rand_num = randi([0 101]);
                current_set = 3;
                if rand_num < 65
                    current_set = 1;
                elseif rand_num < 81
                    current_set = 2;
                end
                set = [set current_set];
                frame = double(frame);
                dataMean = dataMean + frame;

            end
            
            image_counter = image_counter + 1;
            counter = counter + 1;

        end

    end
    
end

dataMean = dataMean ./ ((image_counter-1) * batchNum);
imdb.images.data = data ;
imdb.images.labels = labels ;
imdb.images.set = set;
imdb.meta.sets = {'train', 'val', 'test'} ;
imdb.meta.classes = label_names;
imdb.meta.dataMean = dataMean;

save imdb.mat imdb

end