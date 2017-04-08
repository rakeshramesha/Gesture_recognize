close all
clear all
I=imread('gesture (12).jpg');
I=double(I);
[hue,s,v]=rgb2hsv(I);
t=rgb2ycbcr(I);
cb=t(:,:,2)+128;
cr=t(:,:,3)+128;

[w h]=size(I(:,:,1));  %preparing skin mask
for i=1:w
    for j=1:h            
        if  140<=cr(i,j) && cr(i,j)<=180 && 90<=cb(i,j) && cb(i,j)<=140 && 0.01<=hue(i,j) && hue(i,j)<=0.1     
            segment(i,j)=1;            
        else       
            segment(i,j)=0;    
        end    
    end
end
figure(1),imshow(segment);
im(:,:,1)=I(:,:,1).*segment;   
im(:,:,2)=I(:,:,2).*segment; 
im(:,:,3)=I(:,:,3).*segment; 
figure(2),imshow(uint8(im));
segment=imfill(segment,'holes');

stelement=strel('disk',12);
crop=imclose(segment,stelement);

labeledImage = bwlabel(crop);
measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
for k = 1 : length(measurements)
  thisBB = measurements(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
end
% extract the hand using area.
allAreas = [measurements.Area];
[sortedAreas, sortingIndexes] = sort(allAreas, 'descend');
handIndex = sortingIndexes(1); 
handImage = ismember(labeledImage, handIndex);
thisBB = measurements(handIndex).BoundingBox;
%% to check target region or use if need for croping the target
figure(5),imshow(handImage);
rect=rectangle('Position',thisBB,'EdgeColor','r','LineWidth',2 );
cropI=imcrop(I,thisBB);
figure(6),imshow(uint8(cropI));
%% enhancement if needed change all handImage after this to ensegment to use the enhanced image
stelement=strel('disk',15);
ensegment=imclose(handImage,stelement);
ensegment=imfill(ensegment,'holes');
enim(:,:,1)=I(:,:,1).*ensegment;   
enim(:,:,2)=I(:,:,2).*ensegment; 
enim(:,:,3)=I(:,:,3).*ensegment;

figure(8),imshow(uint8(enim));
%% contour plot

figure(9),cont=imcontour(ensegment);
%% convex hull image

CH = bwconvhull(handImage,'objects');%convex hull gives points(x,y) not a rectangle so requires connecting the points 
figure(3),imshow(CH);
%% finding centroid 

measure = regionprops(handImage,'Centroid');
centroid=measure(1).Centroid;
figure(10),imshow(handImage)
hold on
plot(centroid(1,1),centroid(1,2),'b*')
hold off
 %%  convex hull points
[y, x] = find(handImage);
k = convhull(x, y);
hold on
%plot(x, y, 'w.')
plot(x(k), y(k), 'r', 'LineWidth', 4)
plot(x(k), y(k), 'g*', 'LineWidth', 4)
hold off
%% point filtering and selection
for o=1:size(k)
    if(y(k(o))<centroid(1,2))
        p(o)=k(o);
    else
        p(o)=0;
    end
end
p(p == 0) = []
p=vec2mat(p,1);
%% recognition part based on area :D
for g=1:size(p)
  if g~=size(p)
         x1 = [x(p(g)),x(p(g+1)), centroid(1,1)];
         y1 = [y(p(g)),y(p(g+1)), centroid(1,2)];
         Area1(g)=polyarea(x1,y1);
  end
 end
 Area1(Area1<5500)=[];   %setting threshold of minimum area to be detected as a finger
 gesture=size(Area1);
 gesture(1,3)='N'
 % compensate middle for advanced gestures like \m/ etc upper thresholding 
 if size(Area1)>0
 for g=1:size(Area1)
     if Area1(g)>20000
       gesture(1,2)=gesture(1,2)+1 
       gesture(1,3)='A'
     end
 end
 end
 int2str(gesture(1,3))
 result= insertText(uint8(I),[0,0],gesture(1,2),'FontSize', 48, 'BoxColor', 'g', 'BoxOpacity', 0.4);
 result= insertText(result,[40,0],char(gesture(1,3)),'FontSize', 48, 'BoxColor', 'r', 'BoxOpacity', 0.4);
 figure(11),imshow(result);

% clear all