

%{
Created on Fri Mar  3 2023: MATLAB Code
@author: Tsedeke Temesgen Habe            
%}

dir_name = 'bottle_crate_images/';

% Get a list of all the images in the directory
files = dir([dir_name '*.png']);

% Define the number of images to display per row and column
num_rows = 4;
num_cols = 6;

% Initialize variables to store processed images
original_imgs = cell(1, length(files));
gray_imgs = cell(1, length(files));
thresholded_imgs = cell(1, length(files));
opened_imgs = cell(1, length(files));
closed_imgs = cell(1, length(files));
labeled_imgs = cell(1, length(files));
num_bottles = zeros(1, length(files));

% Loop over each image and process it
for i = 1:length(files)
    % Load the image
    img = imread([dir_name files(i).name]);
    
    % Save the original image
    original_imgs{i} = img;
    
    % Convert the image to grayscale
    gray = im2double(img);
    
    % Save the grayscale image
    gray_imgs{i} = gray;
    
    % Perform thresholding
    level = graythresh(gray);
    bw = imbinarize(gray, level);
    
    % Save the thresholded image
    thresholded_imgs{i} = bw;
    
    % Perform opening to remove noise
    se = strel('square', 30);
    opening = imopen(bw, se);
    
    % Save the opened image
    opened_imgs{i} = opening;
    
    % Perform closing to fill gaps between bottles
    closing = imclose(opening, se);
    
    % Save the closed image
    closed_imgs{i} = closing;

    % Remove any objects that are too small to be bottles
    labeled_img = bwlabel(closing);
    stats = regionprops('table', labeled_img, 'Area');
    filtered_img = ismember(labeled_img, find([stats.Area] >= 250));

     % Remove small objects that are not circles
    filled_img = imfill(filtered_img, 'holes');
    circularity = 0.8; % Set circularity threshold
    stats = regionprops('table', filled_img, 'Area', 'Perimeter');
    circularity_indices = (4*pi*[stats.Area])./([stats.Perimeter].^2) > circularity;
    filtered_img = ismember(labeled_img, find(circularity_indices & [stats.Area] >= 250));
    % Use erosion and dilation to remove small dots and lines
    se_erode = strel('disk', 3);
    se_dilate = strel('disk', 3);
    filtered_img = imerode(filtered_img, se_erode);
    filtered_img = imdilate(filtered_img, se_dilate);

    % Count the number of bottles
    [L, num_bottles(i)] = bwlabel(filtered_img);


    % Save the labeled image with the number of bottles
    labeled_imgs{i} = label2rgb(L);
    % Get the properties of each bottle
    bottles = regionprops('table', filtered_img, 'Area');

end

% Display the original images
figure;
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(original_imgs{i});
    title(['Original Image: (', files(i).name, ') ']);
    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
end

% Display the grayscale images
figure;
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(gray_imgs{i});
    title(['Grayscale Image: (', files(i).name, ') ']);
    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
end

% % Display the thresholded images
figure;
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(thresholded_imgs{i});
    title(['Thresholded Image: (', files(i).name, ') ']);
    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
end

% % Display the opened images
figure;
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(opened_imgs{i});
    title(['Opened Image: (', files(i).name, ') ']);
    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
end
       
% % Display the closed images
figure;
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(closed_imgs{i});
    title(['Closed Image: (', files(i).name, ') ']);
    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
end
% Display the Labeled Image
figure;

disp(['FileName   ', '          |Number of Bottles']);
disp('_____________________________________________');
for i = 1:length(files)
    subplot(num_rows, num_cols, mod(i-1, 24) + 1);
    imshow(labeled_imgs{i});
    %title(['Labeled Image: ',files,' ', num2str(num_bottles(i)), ' bottles']);
    if num_bottles(i)==0
    title('No bottles found');
    else
       title([num2str(num_bottles(i)),' bottels found']);
    end 

    if mod(i, 24) == 0 || i == length(files)
        pause;
        close;
        figure;
    end
fprintf('%-20s | %d \n', files(i).name, num_bottles(i));
   % disp([files(i).name, ': Number of bottles: ', num2str(num_bottles(i))]);
end
