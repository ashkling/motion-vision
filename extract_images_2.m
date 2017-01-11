
function extract_images

action_dir = '../hmdb51_sta';
%bb_dir = '../bb_file/HMDB51';
images_dir = '../action_images';

actions = dir(action_dir);

for action = actions'
    % ignore .rar folders and hidden folders
    if strfind(action.name, '.')
        continue
    end
    
    action_name = action.name;
    files = dir(strcat(action_dir, '/', action_name));
    
    % if the folder for that specific action doesn't exist yet in
    % action_images, make it
    if ~exist(strcat(images_dir, '/', action_name), 'dir')
        mkdir(strcat(images_dir, '/', action_name));
    end
    
    % go through each video in that action folder
    for file = files'
        
        % only look at the video files
        [pathstr,name,ext] = fileparts(file.name);

        if ~strcmp(ext,'.avi')
            continue
        end
        
        % if the video doesn't have a corresponding bounding_box file, skip
        % it
        video_filename = file.name;
        %bb_filename = strcat(video_filename(1:end-3),'bb');
        %if ~exist(strcat(bb_dir, '/', bb_filename), 'file')
        %    continue
        %end
        
        % converting video from avi to mp4 format so that VideoReader will
        % work. you may not have to do this is you have a Windows computer
        %bbs = fileread(strcat(bb_dir, '/', bb_filename));
        %bb_array = strsplit(bbs, '\n');
        video_avi_name = strcat(action_dir, '/', action_name, '/', video_filename);
        video_mp4_name = strcat(video_avi_name(1:end-3), 'mp4');
        if ~exist(video_mp4_name, 'file')
        	system(['ffmpeg -i ', video_avi_name, ' ', video_mp4_name]);
        end
        
        % sometimes converting it won't work, so we'll just skip it
        if ~exist(video_mp4_name, 'file')
            continue
        end
        
        % the video where you can extract frames by doing read(video, i),
        % where i is the frame number
        video = VideoReader(video_mp4_name);
        
        % create a folder for that specific video, where all the images
        % will be in it. if we want to create multiple folders for a video
        % that has multiple actions in it, this part will need to be
        % modified
        image_folder = strcat(images_dir, '/', action_name, '/', name);
        if ~exist(image_folder, 'dir')
            mkdir(image_folder);
        end
        
        % counter is just the name of the image: counter.jpg
        counter = 0;
        % iterate through the bb_file. had to do a lot of weird string to
        % num conversion stuff here
        %for i=1:length(bb_array)
        while hasFrame(video)
            %values = strsplit(char(bb_array(i)));
            %frame_num = str2num(char(values(1)));
            % ignore the line if there's not action, or if the frame number
            % is 0 (since frames start at 1? might be 1 off here), or if
            % the frame number given in bb exceeds the actual number of
            % frames
            %if length(values) <= 1 | frame_num == 0 | frame_num >= video.NumberOfFrames
            %    continue;
            %end

            frame = readFrame(video);
            % get the cropped image and write it to the folder
            %cropped_frame = imcrop(frame, [str2num(char(values(2))) str2num(char(values(3))) ...
            %    str2num(char(values(4)))-str2num(char(values(2))) ...
            %    str2num(char(values(5)))-str2num(char(values(3)))]);
            imwrite(frame, strcat(image_folder, '/', num2str(counter), '.jpg'));
            counter = counter + 1;
        end
        
        % removes folders that are empty, ie. where the bounding box file
        % didn't actually contain any actions, or did but were beyond the
        % actual frame number
        [stat, mess, id]=rmdir(image_folder);

    end
    
end

end