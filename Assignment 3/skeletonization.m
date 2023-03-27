% Read in the image and convert it to a double matrix
image = im2double(imread('images/Fig1116(leg_bone).tif'));

% Apply Gaussian filtering to the image with a standard deviation of 2 for
% noisy images
image_filtered = imgaussfilt(image, 1.5);

% Binarize the filtered image for non binary images
image_binarized = not(imbinarize(image));

% Initialize the skeleton matrix with the binarized image
skeleton = image;

% Initialize a flag to enter the while loop
state = true;

% Get the dimensions of the binarized image
[rows, columns] = size(image_binarized);

% Initialize the delete_pixels matrix with ones
delete_pixels = ones(rows, columns);

% Start the while loop
while state
    % Set the flag to false
    state = false;
    
    % Loop through each pixel in the image except the border pixels
    for i = 2 : rows - 1
        for j = 2 : columns -1
            
            % Create a 3x3 kernel centered at the current pixel
            kernel = [skeleton(i,j) skeleton(i-1,j) skeleton(i-1,j+1)...
                skeleton(i,j+1) skeleton(i+1,j+1) skeleton(i+1,j)...
                skeleton(i+1,j-1) skeleton(i,j-1) skeleton(i-1,j-1)...
                skeleton(i-1,j)];
            
            % If the current pixel is white 
            if (skeleton(i,j) == 1)
                % If the sum of the non-center pixels in the kernel is less
                % than or equal to 6 and greater than or equal to 2
                if(sum(kernel(2:end-1))<=6 && sum(kernel(2:end-1)) >=2)
                    % If the pixels in the kernel at indices 2, 4, and 6 are
                    % not all white
                    if(kernel(2)*kernel(4)*kernel(6)==0)
                        % If the pixels in the kernel at indices 4, 6, and 8
                        % are not all white
                        if(kernel(4)*kernel(6)*kernel(8)==0)
                            % Initialize a counter variable T to 0
                            T=0;
                            % Loop through the kernel pixels
                            for k = 2 : size(kernel,2)-1
                                % If a 0 followed by a 1 is found in the
                                % kernel, increment T
                                if kernel(k) == 0 && kernel(k+1)==1
                                    T= T+1;
                                end
                            end
                            % If T equals 1, set the delete_pixels matrix
                            % to 0 at the current pixel location
                            if (T == 1)
                                delete_pixels(i,j)=0;
                                
                            end
                        end
                    end
                end
            end
        end
    end
    % Remove the pixels flagged for deletion from the skeleton image
    skeleton = skeleton.*delete_pixels;
    for i=2:rows-1                % iterates the rows of image
        for j = 2:columns-1       % iterates the columns of image
            
            kernal = [skeleton(i,j) skeleton(i-1,j) skeleton(i-1,j+1) ... 
                 skeleton(i,j+1) skeleton(i+1,j+1) skeleton(i+1,j)...
                 skeleton(i+1,j-1) skeleton(i,j-1) skeleton(i-1,j-1) ... 
                 skeleton(i-1,j)]; % Create the kernal in order of transitions
             
            if (skeleton(i,j) == 1) % checks if the current pixel is white
                if(sum(kernal(2:end-1))<=6 && sum(kernal(2:end-1)) >=2) % condtion (a)
                    if(kernal(2)*kernal(4)*kernal(8)==0) % condition (c)
                        if(kernal(2)*kernal(6)*kernal(8)==0) % condtion (d)
                            % condition (b)
                            T = 0; % initialise the variable at 0 for each iteration
                            for k = 2:size(kernal,2)-1  % iterates over kernal in order
                                if kernal(k) == 0 && kernal(k+1)==1 % checks for 0 to 1 transitions
                                    T = T+1;
                                end
                            end
                            if (T==1)
                                state = true;   % 
                                delete_pixels(i,j)=0;  % once all conditions have been met then delete current pixel
                            end
                        end
                    end
                end
            end
        end
    end
    skeleton = skeleton.*delete_pixels; % after all layers have been checked, deletion step occurs
end

% Display the original image and the skeletonized image side by side
figure
subplot(1,2,1),imshow(image),title('Original Image');
subplot(1,2,2),imshow(skeleton),title('Skeletonized Image');