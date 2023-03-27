close all; 
clear all; 
clc;

%Import the image file for the figure and converts into a double
im = im2double(imread('images\newborn.tif'));

[rows, cols] = size(im);
im1 = im;
im2 = zeros(rows, cols);

N = 100; % number of iterations
k = 50;    % positive constant value for calculating the gradient

for n = 1 : N % iterations (where you start at the iteration)
    
  %This iterates through each inner pixel
  for x = 2 : rows - 1;
    for y = 2 : cols - 1;
        SumWij = 0;
        for i = -1 : 1  
            for j = -1 : 1
                %Equation calculates the gradient 
                Wij = exp(-k*abs(im1(x,y) - im1(x+i,y+j)));
                %Adds up the gradient (denominator)
                SumWij = SumWij + Wij;
                %Sums the weights*inputs(numerator)
                im2(x,y) = im2(x,y) + Wij*im1(x+i,y+j);
            end 
        end
      %Divides the numerator by the denominator
      im2(x,y) = (im2(x,y)/SumWij);
    end
  end
  im1 = im2;
  im2 = zeros(rows, cols);
end

figure, imshow([im,im1]);

