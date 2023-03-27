clear all; close all; clc; 


image_path = "images/chromosome.tif"; % Path to the original image
discard_coefficients = 100; % Number of Fourier coefficients to discard
rotation_angle = 0; % Angle of rotation in degrees
translation = [0, 0]; % Translation coordinates
scaling_factor = 1; % Scaling factor

% Load the image
Im = im2double(imread(image_path));

% Display the original image
subplot(1,2,1), imshow(Im), title("Original Image");

% Apply Fourier descriptors to the image
mod_img = four_desc(Im, discard_coefficients, rotation_angle, translation, scaling_factor);

% Display the modified image
subplot(1,2,2), imshow(mod_img), title("FD Image");

% Fourier Descriptor Function
function mod_img = four_desc(original_image, nodiscard, rotate, translate, scaling)
    % Get the size of the image
    [rows, cols] = size(original_image);

    % Create a blurred and binarized version of the image
    image_binary = imgaussfilt(original_image, 5);
    image_binary = imbinarize(image_binary);

    % Get the boundaries of the binary image
    img_boundary = bwboundaries(image_binary);
    img_boundary = img_boundary{1};

    % Shift the image to the center for rotation and scaling
    img_boundary(:, 1) = img_boundary(:, 1) - floor(rows / 2);
    img_boundary(:, 2) = img_boundary(:, 2) - floor(cols / 2);

    % Convert the boundary coordinates to complex numbers
    x = img_boundary(:, 1);
    y = img_boundary(:, 2);
    sk = x + 1i*y;

    % Apply the Fourier transform to the boundary
    au = fft(sk);

    % Loop through the Fourier coefficients
    for i = 1 : size(au)
        % Discard coefficients outside of the specified range
        if i > nodiscard & i < (size(au, 1) - nodiscard)
            au(i) = 0;
        else
            % Apply rotation
            if rotate ~= 0
                au(i) = au(i) * exp(1i*deg2rad(rotate));
            end

            % Apply scaling
            if scaling ~= 1
                au(i) = au(i) * scaling;
            end
        end
    end

    % Apply translation
    if ~isequal(translate, [0, 0])
        au(1) = au(1) - size(au, 1)*(translate(2) - 1i*translate(1));
    end

    % Apply the inverse Fourier transform to get the modified boundary
    sk_approx = ifft(au);

    % Reconstruct the image using the modified boundary
    mod_img = zeros(rows, cols);
    for i = 1 : size(sk_approx)
        x = round(real(sk_approx(i)));
        y = round(imag(sk_approx(i)));

        % Shift the image back to its original position
        x = x + floor(rows / 2);
        y = y + floor(cols / 2);

        % Check if the reconstructed image is within the bounds of the original image
        if x >= 1 & x <= rows & y >= 1 & y <= cols
            mod_img(x, y) = 1;
        end
    end
end