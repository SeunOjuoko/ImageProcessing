clear all;
close all;
clc;

%Imported the six multispectral satellite images 
I1 = imread('images\Fig1138(a)(WashingtonDC_Band1_564).tif');
I2 = imread('images\Fig1138(b)(WashingtonDC_Band2_564).tif');
I3 = imread('images\Fig1138(c)(WashingtonDC_Band3_564).tif');
I4 = imread('images\Fig1138(d)(WashingtonDC_Band4_564).tif');
I5 = imread('images\Fig1138(e)(WashingtonDC_Band5_564).tif');
I6 = imread('images\Fig1138(f)(WashingtonDC_Band6_564).tif');

N = size(I1,1);       
M = size(I1,2);
Nd = 6;                  %For the Six images
X = zeros(N,M,Nd);       %Assigns Vector of X
mx = zeros(Nd,1);        %Mean vector for the initial samples
Cx = zeros(Nd,Nd);       %Covariance Matrix for initial samples

%Iterations for the Mean Vector and Covariance Matrix
for i = 1:N
    for j = 1:M
        %Iterates through all the images
        X(i,j,:) = [I1(i,j); I2(i,j); I3(i,j); I4(i,j); I5(i,j); I6(i,j)];
        %Each iteration increments Mean Vector 
        mx = mx + squeeze(X(i,j,:));
        %Each iteration increments Covariance Matrix
        Cx = Cx + squeeze(X(i,j,:))*squeeze((X(i,j,:)))';
    end
end
%Calculates the Mean Vector equation 
mx = mx/(N*M); 
%Calculates the Covariance Matrix equation 
Cx = Cx/(N*M)-mx*mx';

 % Calculates the Eigen Values of Covariance Matrix
[Q,D] = eig(Cx);   
%Converts the diaganol values as vector
d_v = svd(D);
%Covariance Matrix for Y
Cy = diag(d_v);         

%Calculates matrix A through Eigen Vectors of Cx
A = fliplr(Q);                      
%Transposes Matrix A
A_tran = A';                        
%Receieves  Ak Matrix from k Eigen Vectors 
Ak = A_tran(1:2,:);                 

%Iterations finds reconstructed X Vector
Y = zeros(N,M,Nd);
for k= 1:Nd
for i = 1:N
    for j = 1:M
        %Iterates through all the images
        X(i,j,:) = [I1(i,j); I2(i,j); I3(i,j); I4(i,j); I5(i,j); I6(i,j)];
        Y(i,j,k) = A_tran(k,:)*(squeeze(X(i,j,:))-mx);
    end
end
end
%Reconstructed X_hat vector
X_hat = zeros(N,M,Nd);

%Iteration reconstructs X_hat vector by Ak Matrix
for i = 1:N
    for j = 1:M
        %Iterates through all the images
       X(i,j,:) = [I1(i,j); I2(i,j); I3(i,j); I4(i,j); I5(i,j); I6(i,j)];
       Y_hat(i,j,:) = Ak*(squeeze(X(i,j,:))-mx);
       %Reconstruced X_hat vector by Ak Matrix
       X_hat(i,j,:) = Ak'*squeeze(Y_hat(i,j,:))+mx;
    end
end

%Calculates Mean Square Errors and Peak Signal-to-Noises between X_hat and X
err1 = immse(X_hat(:,:,1),X(:,:,1));    
PSNR1 = 10*log10(255^2/err1);                 

err2 = immse(X_hat(:,:,2),X(:,:,2));    
PSNR2 = 10*log10(255^2/err2);           

err3 = immse(X_hat(:,:,3),X(:,:,3));    
PSNR3 = 10*log10(255^2/err3);           

err4 = immse(X_hat(:,:,4),X(:,:,4));    
PSNR4 = 10*log10(255^2/err4);

err5 = immse(X_hat(:,:,5),X(:,:,5));    
PSNR5 = 10*log10(255^2/err5);

err6 = immse(X_hat(:,:,6),X(:,:,6));    
PSNR6 = 10*log10(255^2/err6);

%-Display Variables and Values for Results Table
Variable1 = {'error 1'; 'error 2'; 'error 3'; 'error 4'; 'error 5'; 'error 6'};
values1 = [err1; err2; err3; err4; err5; err6];
Variable2 = {'PSNR 1'; 'PSNR 2'; 'PSNR 3'; 'PSNR 4'; 'PSNR 5'; 'PSNR 6'};
values2 = [PSNR1; PSNR2; PSNR3; PSNR4; PSNR5; PSNR6];
T = table(Variable1,values1,Variable2,values2);
disp(T);
