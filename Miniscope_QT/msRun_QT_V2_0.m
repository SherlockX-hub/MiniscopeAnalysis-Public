%% msRun2018
% Version 1.0 GE
% Updated version of the msRun script originally proposed by Daniel B
% Aharoni to analyse miniscope 1p calcium imaging data.
% This version is build on top of the original package to maximize compatibility.
% It includes NormCorre for image registration, CNMF-E for source extraction,
% and CellReg for chronic registration across sessions. It also includes
% custom written scripts to explore the data (eg spatial firing, transients
% properties visualization)

% Copyright (C) 2017-2018 by Guillaume Etter
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or any
% later version.
% Contact: etterguillaume@gmail.com

%% msRun_QT_V2_0.m
% This script is modified to analyze the data recorded by
% Miniscope-DAQ-Software_build_v2 program.
%
% Modified by Xiang Zhang, November, 2026.

clear;

%% Codes path;
% addpath(genpath('G:\ZX\Miniscope_Analysis_2021'));

%% Parameters
spatial_downsampling = 1; % (Recommended range: 2 - 4. Downsampling significantly increases computational speed, but verify it does not
isnonrigid = true; % If true, performs non-rigid registration (slower). If false, rigid alignment (faster).

% Generate timestamp to save analysis
script_start = tic;
analysis_time = strcat(date,'_', num2str(hour(now)),'-',num2str(minute(now)),'-',num2str(floor(second(now))));

%% 1 - Create video object and save into matfile
disp('Step 1: Create video object');
dirName = input('Enter the path: ', 's'); % pwd; % 
if ~contains(dirName,'Miniscope')
    destination_path = strcat(dirName,filesep,'Miniscope');
else
    destination_path = dirName;
end
ms = msGenerateVideoObj_QT(destination_path,'');
ms.analysis_time = analysis_time;
ms.ds = spatial_downsampling;
mkdir(strcat(ms.dirName, filesep, analysis_time));
save([ms.dirName filesep analysis_time filesep 'ms.mat'],'ms');

%% 2 - Perform motion correction using NormCorre
disp('Step 2: Motion correction');
ms = msNormCorre_QT(ms,isnonrigid);
ms = rmfield(ms,'vidObj');
save([ms.dirName filesep 'ms.mat'],'ms');

%% 3 - Perform CNMFE
disp('Step 3: CNMFE');
ms = msRunCNMFE_large_QT(ms);
msExtractSFPs(ms); % Extract spatial footprints for subsequent re-alignement.
saveas(gcf, strcat(ms.dirName, filesep, 'ms.fig'));
close();

analysis_duration = toc(script_start);
ms.analysis_duration = analysis_duration;

save([ms.dirName filesep 'ms.mat'], 'ms', '-v7.3');
disp(['Data analyzed in ' num2str(analysis_duration) 's']);

%% 4 - Cleanup temporary files
% rmdir([ms.dirName separator ms.analysis_time], 's');
