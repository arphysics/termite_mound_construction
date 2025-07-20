% CS 143 (Fall 2008) - Assignment 1 - normalizeImage
% Author: Sam Ocko
% Date:   


%A Helper Method, which given an image, returns a noramlized version


function [normalizedImage]  = normalizeImage(image)

maxValue = max(image(:));
minValue = min(image(:));
double_image = double(image)

normalizedImage = 255. *(double_image -minValue)/(maxValue-minValue);


