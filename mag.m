function mask = mag(im, mask0)

% Segmentation parameters:
sigma   = 0.8;  %std of smoothing gaussian filter
n       = 25;   %number of gray levels

% Smoothing filter
h = gausswin(5*sigma+1);

% Intensity levels
imin = min(im(mask0));
imax = max(im(mask0));
ivalues = linspace(imin, imax, n);

% Compute morphological area curve
area = zeros(n, 1);
for k = 1:n
    seg = (im>=ivalues(k))&mask0;
%     seg = bwareafilt(seg, 1);
    area(k) = sum(seg(:));
end
 
% Compute first morphological area gradient (MAG)
mag = diff(area);

% Smooth MAG to remove noise
% mag = conv(mag, h, 'same');
 
% Minimize MAG
[~, i] = min(mag);

% Segment image
mask = (im>=ivalues(i+1))&mask0;
% se = strel('disk', 7);
% mask = imopen(mask, se);

% roi = getROI(mask0);
% mask = bwareafilt(mask&roi, 1);
