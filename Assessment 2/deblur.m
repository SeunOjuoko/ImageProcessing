close all; 
clear; 
clc;

h = double(imread('testkernel.png')); % motion blur
h = fspecial('gaussian', [15 15], 5); % Gaussian blur
h = h./sum(h(:));

%Assigns Blur
blur = @(im) imfilter(im,h,'conv','circular');

% Gaussian noise
noise_mean = 0;
noise_var = 0.00001; % 10^{-5}

f = im2double(imread('barbara_face.png'));
g = imfilter(f,h,'conv','circular'); % blur
g = imnoise(g,'gaussian',noise_mean,noise_var); % ading noise

H = psf2otf(h,size(g));

psnr0 = psnr(f,g);
psnrRL = psnr0;
psnrLw = psnr0;
psnrI = psnr0;

% Wiener deblurring
W = deconvwnr(g,h,0.0005);
figure,imshow([f,g,W]);title('Original Image, Corrupted Image, Wiener deblur');

RL = g;
Lw = g;
I = g;
G = fft2(g);
maxiter = 1000; 

%Iterates through the Richard-Lucy, Landweber and ISRA and presents the
%result in the terminal
for i = 1:maxiter
 % Richardson-Lucy iterations: RL = RL.*[h(-x)*(g./(RL*h(x)))]
 RL = RL.*ifft2(fft2(g./blur(RL)).*conj(H));
 psnr_RL = psnr(RL,f);
 psnrRL = [psnrRL; psnr_RL];
 
 % Landweber iterations: Lw = Lw + h(-x)*(Lw-Lw*h(x))
 Lw = Lw + ifft2(conj(H).*(fft2(g-blur(Lw))));
 psnr_Lw = psnr(Lw,f);
 psnrLw = [psnrLw; psnr_Lw];

 %ISRA iterations
 I = I.*ifft2(fft2(g).*conj(H))./ifft2(fft2(blur(I)).*conj(H));
 psnr_I = psnr(I,f);
 psnrI = [psnrI; psnr_I];

 %Presents the each iteration calcualtion to the terminal 
 fprintf('i = %d   psnr_RL = %f   psnr_Lw = %f\n    psnr_I = %f\n', i, psnr_RL, psnr_Lw, psnr_I);
end


psnrW = psnr(W,f)*ones(maxiter,1);

%Constructs each blurr scheme
figure,
imshow([Lw,RL,I]);
figure();
title('Landweber and Richardson-Lucy and ISRA');

%Then creates a graph for each blurr scheme
semilogy(psnrW,'LineWidth',1.5,'Color',[0,0,1]),axis([1 maxiter 0 30]); 
hold
semilogy(psnrLw,'LineWidth',1.5,'Color',[0,1,0]),axis([1 maxiter 0 35]);
semilogy(psnrRL,'LineWidth',1.5,'Color',[1,0,0]),axis([1 maxiter 0 30]);
semilogy(psnrI,'LineWidth',1.5,'Color',[1,0,1]),axis([1 maxiter 0 30]);
legend('Wiener', 'Landweber','Richardson-Lucy', 'ISRA');

