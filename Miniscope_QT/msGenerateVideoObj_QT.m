function ms = msGenerateVideoObj_QT(dirName, filePrefix)
%MSGENERATEMS Summary of this function goes here
% modified to generate the information for QT version v1_10.

% modified by Xiang Zhang, 2021.

%   Detailed explanation goes here

    ms.dirName = dirName; % Added by GE to keep track of where the files were initially
    
    % MAXFRAMESPERFILE = 1000; %This is set in the miniscope control software
    
    % find avi and dat files
    aviFiles = dir([dirName filesep filePrefix '*.avi']);
    csvFiles = dir([dirName filesep filePrefix '*.csv']);
    
    ms.numFiles = 0;
    ms.numFrames = 0;
    ms.vidNum = [];
    ms.frameNum = [];
    ms.maxFramesPerFile = 0; % MAXFRAMESPERFILE;
    
    % find the total number of relevant video files;
        ms.numFiles = length(aviFiles);
    
    % generate a vidObj for each video file. Also calculate total frames;
    for i=1:ms.numFiles
%         [folder filesep num2str(filePrefix) num2str(i) '.avi']
        ms.vidObj{i} = VideoReader([dirName filesep filePrefix num2str(i-1) '.avi']);
        ms.vidNum = [ms.vidNum i*ones(1,ms.vidObj{i}.NumberOfFrames)];
        ms.frameNum = [ms.frameNum 1:ms.vidObj{i}.NumberOfFrames];
        if ms.vidObj{i}.NumberOfFrames > ms.maxFramesPerFile
            ms.maxFramesPerFile = ms.vidObj{i}.NumberOfFrames;
        end
        ms.numFrames = ms.numFrames + ms.vidObj{i}.NumberOfFrames;
    end
    ms.height = ms.vidObj{1}.Height;
    ms.width = ms.vidObj{1}.Width;
    ms.FPS = ms.vidObj{1}.FrameRate;
    
    for i=1:length(csvFiles)
        % read timestamp information;
        if strcmp(csvFiles(i).name, 'timeStamps.csv')
            timeStamps = readmatrix([dirName filesep csvFiles(i).name],'NumHeaderLines',1,'Delimiter',',');
            
            if size(timeStamps,1) ~= ms.numFrames
                disp('Wraning: timestamp does not match the video, videos may be damaged.');
            end
            
            ms.time = timeStamps(:,2);
            ms.time(1) = 0;
        % read head orientation;
        elseif strcmp(csvFiles(i).name, 'headOrientation.csv')
            headOrientation = readmatrix([dirName filesep csvFiles(i).name],'NumHeaderLines',1,'Delimiter',',');
            
            if size(headOrientation,1) ~= ms.numFrames
                disp('Wraning: head orientation does not match the video, videos may be damaged.');
            end
            
            ms.HeadOrientation = headOrientation(:,2:5);
        end
    end
    
    % read in and store animal name and other information;
    sessionDirName = dirName;
    if contains(sessionDirName,'My_V4_Miniscope')
        sInd = strfind(sessionDirName,filesep);
        sessionDirName = sessionDirName(1:sInd(end)-1);
    elseif contains(sessionDirName,'My_WebCam')
        sInd = strfind(sessionDirName,filesep);
        sessionDirName = sessionDirName(1:sInd(end)-1);
    else
        error('Error input of data folder.'); % disp('Error input of data folder.');
        % return;
    end

    % metaData of the session;
    jsonFiles = dir([sessionDirName filesep '*.json']);
    if ~isempty(jsonFiles)
        for i = 1:length(jsonFiles)
            if strcmp(jsonFiles(i).name, 'metaData.json')
                meta_data = jsondecode(fileread([sessionDirName filesep jsonFiles(i).name]));
                ms.meta_data_session = meta_data;
            end
        end
    end
    
    % metaData of the device;
    jsonFiles = dir([dirName filesep '*.json']);
    if ~isempty(jsonFiles)
        for i = 1:length(jsonFiles)
            if strcmp(jsonFiles(i).name, 'metaData.json')
                meta_data = jsondecode(fileread([dirName filesep jsonFiles(i).name]));
                ms.meta_data_device = meta_data;
            end
        end
    end
end