
%Initialises the varibales for the Algorithm
fxy = im2double(imread('barbara_face.png'));    %Imports the original image
[m,n] = size(fxy);                              %Receives the size from the original image
nxy = (1/255)*randn(size(fxy));                 %Randomly generates noise for the original image
h = fspecial('motion',15,45);                   %Creates linear operator as the blur convultion with original image
blur = imfilter(fxy,h,'circular');              % 
g = blur + nxy;                                 %Adds the noise and blur for the degraded image 

%Equations
Huv = fft2(h,m,n);                    % H(u,v) - fourier transform of linear operator
Guv = fft2(g);                        % G(u,v) - fourier transform of degraded image
k = sum(nxy(:).^2)/sum(g(:).^2);       % Estimated noise-to-signal ratio

%Implementation for Wiener Filter     
H_conj = conj(Huv);                   % Numerator of fraction, conjugate of H(u,v)
frac = H_conj./((abs(Huv).^2)+k);     % entire fraction sen in equation 1 from lab sheet                     
restore = abs(ifft2(Guv.*frac));      % gets restored image from inverse transform and take absolute value

%Plotted Outputs for Original Image
figure;
subplot(1,3,1),
imshow(fxy, []), 
title("Original Image");

%Plotted Outputs for Corrupted Image
subplot(1,3,2),
imshow(g, []), 
title("Corrupted Image")

%Plotted Outputs for Restored Image
subplot(1,3,3),
imshow(restore,[]), 
title("Restored Image")
