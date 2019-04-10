clc;                 
close all;
clear

I0 = imread('Lab2.png');    %Reading the image downoladed in system.
I  = rgb2gray(I0);          %Converting the image into grayscale
hist(I(:), 1:255)           %Plotting histogram for grayscale image to visually inspect the threshold
xlabel('Image Intensity - Gray Scale');      
ylabel('Number of repititions');

%Global Thresholding method for finding the threshold value by trial and
%error method.

count =0;
T = mean2(I);
D = false;
while ~D
    count = count+1;
    g = I>T;
    Tnext = 0.5*(mean(I(g))+ mean (I(~g)));
    D = abs(T-Tnext)< 0.5;
    T=Tnext;
end
g=im2bw(I,T/255);
Th_value_by_global_thresholding = T                     %It gives output as Value of threshold 
imshow(I)
figure(2)
imhist(I)

I_gray_scale=I;
Th = 178;                       % Identifying the threshold value by visual inspection
I_gray_scale(I_gray_scale<Th)=0;       %Converting into gray scale by sending all the values lower than threshld to black

I_gray_scale(I_gray_scale>=Th)=255;         %And higher values of intensity to white
figure(3);
imshow(I_gray_scale,[]);
title('Gray-Scale of the actual image');

%Number of objects 
items = bwconncomp(255-I_gray_scale,4);           % Detecting Cluster of points which has more than 4 connected neighbors
Obj_L =  zeros(items.NumObjects,1); % Creating a zero vector for saving the length of each clusters

for i=1:items.NumObjects
    Obj_L(i)= length(items.PixelIdxList{i});    %finding the number of connected points in each cluster and saving in Obj_L
end

figure(4);                                         % visual inspection for distinguishing the clusters from noise
plot(Obj_L);
xlabel('Number of pixels');                     
ylabel('Cluster ID')
obj_id = find(Obj_L>2000);                      % It is clear that any cluster with less than 500pnt is a noise
M = 0*I_gray_scale(:);                          % creating a new mask (we start with a vector and reshaping it into a 2D MASK)

for i  = 1:length(obj_id)
    id = items.PixelIdxList{obj_id(i)};         % Pixel ids belonging to the ith cluster(or object)
    M(id)= 255; % set the id of the pixels associated with the members of main clusters equal to 1
end

% M is a vector which reshapes the image to it's size. The size of the image is stored in items.ImageSize
M = reshape(M,items.ImageSize(1),items.ImageSize(2));                   
figure(5);
imshow(M);
title('clustered objects');

%Now, to detect all the green objects from image

green_detect = imsubtract(I0(:,:,2),I);
green_vec = green_detect(:);
figure(6);
hist(green_detect(:),0:255) ;                  % histogram of a Gray Scale
title('Applying filter to obtain gray scale for green layer');

for h = 1:length(green_vec)
    if green_vec(h) < 20                      % Threshold was found from visually inspecting the histogram
        green_obj(h) = 0 ;
    else
        green_obj(h) = green_vec(h) ;
    end
end

green_obj = reshape(green_obj,491,891) ;
items_green = bwconncomp(green_obj,4) ;                  % finding the cluster of points with more than 4 connected neighbors

figure(7);
imshow(green_obj)
title('Green Objects');


%To detect how many circles are there in image, we make the computer count
%them by comparing the diameter values which are equal all round the circles. 
items = bwconncomp(M,4);

[X, Y] = meshgrid(1:891,1:491);    % X gives the number of columns of image, Y gives the number of rows of image
X = X(:);       
Y = Y(:);       

circles = 0 ;  %Initial count
for k=1:items.NumObjects  %loop to be run for all the objects
    
    id = items.PixelIdxList{k};
      
    x_x = X(id);
    y_y = Y(id);
    x_mean = mean(x_x);         %Center component in x finding 
    y_mean = mean(y_y);         %Center component in y finding 
    
    x1 = min(x_x);                             
    y1 = min(y_y);     
                                   
    figure(8)
    hold on
         d_x = x_mean-x1 ;
         d_y = y_mean-y1 ;
        d_overall = d_x/d_y ;
                  
            if (0.90 < d_overall)&& (d_overall < 1.15)
            circles = circles + 1 ;
                 for l=1:0.08:3.*pi
                 plot(x_mean+d_x.*cos(l),y_mean+d_x.*sin(l),'m.');
                 end
             plot(x_mean,y_mean,'go')  %Circle Center detection       
            end      
end   
   

fprintf('Our image consists of %d shapes',length(obj_id));
fprintf('\n Image consists of %d circles',circles);
fprintf('\n And the image consists of %d green objects\n',items_green.NumObjects);

