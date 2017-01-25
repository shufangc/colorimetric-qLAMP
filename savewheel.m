function savewheel(hsv_image_temp, path, save_file_name)

format long g;
format compact;
fontSize = 20;

% Let's compute and display the histogram.
figure('Visible','off');
numberOfBins = 120;
step = 360/numberOfBins;
h = hsv_image_temp(:,:,1);
% Display the original color image.
scaledHue = 360*h;
[pixelCount, grayLevels] = hist(scaledHue(:), 1:step:360);
subplot(2, 1, 1); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Hue Channel', 'FontSize', fontSize);
xlim([0 360]); % Scale x axis manually.

subplot(2, 1, 2); 
cmap = hsv(length(1:step:360));
r = pixelCount / max(pixelCount(:));
drawWheel(r,cmap);
saveas(gcf,fullfile(path,save_file_name),'png');
%figure('Visible','on')
%=============================================================
function drawWheel(r, cmap)
if (any(r > 1) || any(r < 0))
	error('R must be a vector of values between 0 and 1')
end

if numel(r) ~= size(cmap,1)
	error('Length of r and cmap must be the same')
end

n = numel(r);
innerRadius =  250;
outerRadius = 300;

angles = linspace(0,2*pi,n+1);
newR = innerRadius*(1-r);
% Draw the hue in the annulus.
for k = 1:n
%	newR(k);
	drawSpoke(innerRadius, outerRadius, angles(k), angles(k+1), cmap(k,:));
    drawSpoke(newR(k), innerRadius, angles(k), angles(k+1), cmap(k,:));
end

% Draw circle at the center.
line(0,0,'marker','o');
% Draw outer black ring.
line(cos(angles)*outerRadius, sin(angles)*outerRadius, 'LineWidth', 2, 'Color', 'k');
% Draw inner black ring.
line(cos(angles)*innerRadius, sin(angles)*innerRadius, 'LineWidth', 2, 'Color', 'k');
axis equal;


%=============================================================
function h = drawSpoke(ri,ro,thetaStart,thetaEnd,c)
xInnerLeft  = cos(thetaStart) * ri;
xInnerRight = cos(thetaEnd)   * ri;
xOuterLeft  = cos(thetaStart) * ro;
xOuterRight = cos(thetaEnd)   * ro;
yInnerLeft  = sin(thetaStart) * ri;
yInnerRight = sin(thetaEnd)   * ri;
yOuterLeft  = sin(thetaStart) * ro;
yOuterRight = sin(thetaEnd)   * ro;

X = [xInnerLeft, xInnerRight, xOuterRight xOuterLeft];
Y = [yInnerLeft, yInnerRight, yOuterRight yOuterLeft];

h = patch(X,Y,c);
set(h,'edgeColor', 'none');
