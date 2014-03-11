% Name: Sundar Murugesan
% Date Submitted: Feb 28 2014
% Course: Ryerson - CPS843/CP8307 - Introduction to Computer Vision

% Input Parameters: 
% img = A string for the input image. Specify the name of the file, with the extension. The 
% images you can use for this assignment, is the test image, called 'bowl-of-fruit.jpg', and the image 
% of our own choosing, 'Lena.tiff'. Please ensure the image is in the same
% directory as the script. 
% sigma = standard deviation of Gaussian function.
% window_size = size of gaussian kernel. 
% threshold = for use after non maximum suppression. Default value is set
% to zero. If default value is set to zero - it means you don't want to do
% do the threshold step. If you want to use the threshold, set it to a specific value > 0. 

% Output Images:
% First image - smoothed image
% Second image - gradient magnitude of the smoothed image
% Third image - gradient direction of the smoothed image before gradient
% direction was rounded to 0, 45, 90, and 135 degrees. 
% Fourth image - gradient direction of the smoothed image after gradient
% direction was rounded to one of  0, 45, 90, and 135 degrees. 
% Fifth image - suppressed/non suppressed pixels image with or without
% threshold. If threshold is set to 0, it will be without threshold. 
% Sixth image - binary image with of suppressed/non suppressed pixels,
% including the threshold suppression, if the threshold was set to value
% greater than zero. 


img=imread('bowl-of-fruit.jpg');
sigma = 1.5; 
window_size = 5;
threshold = 0; 


% Resize the image if it is very large. 
% Convert to grayscale - in case input image was not grayscale. 
resized_img = imresize(img, [512 NaN]);
resized_img_db = im2double(resized_img);
resized_gray_image=rgb2gray(resized_img_db);

% Keep track of size of image, useful for non-maxima suppression step. 
[rows, cols] = size(resized_gray_image);

% Step 1: 
% Creating separable gaussian filters in the x and y direction. 
% And smooth the image with these gaussian filters.  
gaussian_x= fspecial('gaussian', [1 window_size], sigma);
gaussian_y= fspecial('gaussian', [window_size 1], sigma);
smoothed_image = conv2(gaussian_x, gaussian_y, resized_gray_image, 'same');
figure, imshow(smoothed_image)
pause;

% Step 2
% Find the gradient of the image in the x and y directions by using the
% sobel filter. Then we find the gradient magnitude and direction
sobel_filter = fspecial('sobel');   
img_dy = imfilter(smoothed_image, sobel_filter, 'conv');
img_dx = imfilter(smoothed_image, sobel_filter', 'conv'); 
grad_mag = sqrt(img_dx.^2+img_dy.^2);
grad_direction = atan2(img_dy, img_dx);

figure, imshow(grad_mag)
pause;

figure, imshow(grad_direction)
pause;

% Step 3
% Non max suppression has two parts, 3a and 3b.

% Step 3a
% First, we approximate each angle in the matrix grad_direction. 
% The angles of the grad_direction are rounded down or up to each of the
% following angles: 0, 45, 90, or 135. The angles are rounded to within
% 22.5 degrees, in the forward and reverse directions. 
grad_direction = (grad_direction * 180)/pi; 
approximated_grad_direction = zeros(rows, cols);
for row = 1:rows
    for col = 1:cols
        
        if((grad_direction(row,col) > -22.5 && grad_direction(row,col) < 22.5) || (grad_direction(row,col) > 157.5 && grad_direction(row,col) < -157.5))
            approximated_grad_direction(row,col) = 0;
        end
        if((grad_direction(row,col) > 22.5 && grad_direction(row,col) < 67.5) || (grad_direction(row,col) > -157.5 && grad_direction(row,col) < -112.5))
            approximated_grad_direction(row,col) = 45;
        end
        if((grad_direction(row,col) > 67.5 && grad_direction(row,col) < 112.5) || (grad_direction(row,col) > -112.5 && grad_direction(row,col) < -67.5))
            approximated_grad_direction(row,col) = 90;
        end
        if((grad_direction(row,col) > 112.5 && grad_direction(row,col) < 157.5) || (grad_direction(row,col) > -67.5 && grad_direction(row,col) < -22.5))
            approximated_grad_direction(row,col) = 135;
        end
    end
end

figure, imshow(approximated_grad_direction)
pause;

% Step 3b
% Here, this is where we do the actual non-maximum suppression. 
% Knowing the gradient direction of a pixel, the gradient magintude pixel is compared
% to the neighbors along a normal to the gradient direction. If the
% gradient magnitude is greater than both the neighbors, it is retained.
% Otherwise, if the gradient magnitude of the pixel is set to zero. 
local_maxima = zeros(rows,cols);
for row = 2:rows-1
    for col = 2:cols-1

        switch(approximated_grad_direction(row,col))
            
            case 0
                if(grad_mag(row,col) > grad_mag(row, col+1) && grad_mag(row,col) > grad_mag(row, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end 
            case 45
                if(grad_mag(row,col) > grad_mag(row+1, col+1) && grad_mag(row,col) > grad_mag(row-1, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
             
            case 90
                if(grad_mag(row,col) > grad_mag(row, col+1) && grad_mag(row,col) > grad_mag(row, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
                
            case 135
                if(grad_mag(row,col) > grad_mag(row-1, col+1) && grad_mag(row,col) > grad_mag(row+1, col-1))
                    local_maxima(row,col)=grad_mag(row,col);
                else
                    local_maxima(row,col)=0;
                end
            otherwise
                %do nothing
        end 
            
    end
end

% Step 4: Compare the suppressed/non suppressed image to a threshold. 
% If the grad magnitude is greater than the threshold, then keep it,
% otherwise set it to zero.
local_maxima_with_threshold = local_maxima;
for row = 1:rows
    for col = 1: cols
       
        %Note: if the threshold given was zero, this won't do anything. 
        if(local_maxima_with_threshold(row,col) < threshold)
            local_maxima_with_threshold(row,col)=0;
        end
    end
end

figure, imshow(local_maxima_with_threshold)
pause;

%Convert the non-suppressed and suppressed pixels of the image to a binary
%image.
level=graythresh(local_maxima_with_threshold);
canny_image=im2bw(local_maxima_with_threshold,level);
figure, imshow(canny_image)



        
