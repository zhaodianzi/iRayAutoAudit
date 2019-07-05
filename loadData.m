function [img, img3sig] = loadData(filepath, h, w, hOffset, wOffset)
img = load(filepath);
img = img(hOffset:hOffset + h - 1, wOffset:wOffset + w - 1);
img = 255 - img;
img = img(end:-1:1, :);
% maxI = max(img(:));
% img = img / maxI * 255;

% if maxI < 4
% 	img = img / 3.6 * 255;
% end
img3sig = img;
ave = mean(img(:));
sigma = std(img(:));
lowBound = ave - 3 * sigma;
upBound = ave + 3 * sigma;
img3sig(img < lowBound) = lowBound;
img3sig(img > upBound) = upBound;
img3sig = (img3sig - lowBound) / (upBound - lowBound) * 255;
% imagesc(img, [ave - 3 * sigma, ave + 3 * sigma]);
end