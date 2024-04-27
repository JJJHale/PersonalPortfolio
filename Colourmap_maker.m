%% Colourmap maker
% J.Hale 11/2023
clear all; close all
%% 
% Select image you want to base your map on.
testfiledir = uigetdir;
ImType = '.jpg'; %Change to the type of image you want to read. from google photos is usually jpg
matfilescor = dir(fullfile(testfiledir, ['*' ImType]));
ImName = ((fullfile(testfiledir, matfilescor(1).name))); %Takes image name
IM = imread(ImName);
figure();
hold on 
imshow(IM);

dlg_title = 'User Question';
prompt = ('How many points do you want to base this cmap on?');
NTq = inputdlg(prompt,dlg_title);
n = str2double(NTq{1,1});

xr = [];yr = [];
Colours = [];
for i = 1:n
   h = drawpoint; 
   x = round(h.Position(1)); y = round(h.Position(2));
   xr = [xr,x]; yr = [yr,y];
   
   %take mean of surrounding pixels
   R = mean(mean(double(IM([y-2 y-1 y y+1 y+2],[x-2 x-1 x x+1 x+2],1))))/256;
   G = mean(mean(double(IM([y-2 y-1 y y+1 y+2],[x-2 x-1 x x+1 x+2],2))))/256;
   B = mean(mean(double(IM([y-2 y-1 y y+1 y+2],[x-2 x-1 x x+1 x+2],3))))/256;
   RGB = [R,G,B];
   
   HH = drawpoint('Position',h.Position,'Color',RGB,'MarkerSize',20); %Just for show
   Colours = [Colours;RGB];
end
%% Order based on similarity
% Calculate pairwise Euclidean distances
distances = pdist2(Colours, Colours);

% Display the distance matrix
disp('Pairwise Euclidean distances between colors:');
disp(distances);

% Find the order based on similarity (smaller distance means more similar)
[~, order] = sort(mean(distances, 'omitnan'));

% Order the colors based on similarity
orderedColours = Colours(order, :);

%% Darkest to brightest
% Calculate darkness metric (sum of RGB values)
darknessMetric = sum(Colours, 2);

% Find the order based on darkness (smaller sum means darker color)
[~, order] = sort(darknessMetric, 'ascend');

% Order the colors based on darkness
orderedColours2 = Colours(order, :);
%% 

% Interpolate to create colourmap
Rint = []; Gint = []; Bint = [];
npts = n*20;
for i = 1:n-1
    Rintnew = linspace(orderedColours2(i,1),orderedColours2(i+1,1),npts);
    Gintnew = linspace(orderedColours2(i,2),orderedColours2(i+1,2),npts);
    Bintnew = linspace(orderedColours2(i,3),orderedColours2(i+1,3),npts);
    Rint = [Rint;Rintnew']; Gint = [Gint;Gintnew']; Bint = [Bint;Bintnew'];
end
RGB_FULL = [Rint Gint Bint];

%% Trial plot
[X,Y,Z] = peaks(50);
figure, subplot(1,4,1), imshow(IM)
subplot(1,4,2:3),
surf(X,Y,Z)
axis off; grid off
colormap(RGB_FULL)
colorbar
title('Colour trial 3D')
subplot(1,4,4),
for i = 1:n
   bar(i,rand(),'FaceColor',[orderedColours(i,:)])
   grid on; box on
   hold on
   title('Colour trial 2D')
end

%% IF HAPPY, HERE ARE THE FINAL PARAMETERS

prompt = ('Map complete. Would you like to save this map?');
SaveData = questdlg(prompt,dlg_title,'YES','NO ', 'NO ');  
if SaveData == 'YES'
    prompt = ('What would you like to name this cmap?');
    CmapName = inputdlg(prompt,dlg_title);
    filename_full = join([CmapName{1,1},'_full.mat']);
    filename_cols = join([CmapName{1,1},'_cols.mat']);
    save(filename_full,'RGB_FULL')
    save(filename_cols,'Colours')
end

%% FINISHED
