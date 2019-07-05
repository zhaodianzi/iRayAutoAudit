function [res] = horizontalStripeSuppression(img)
window = 100;
[h, w] = size(img);
originalSum = sum(img, 2);
res = img;
for i = 1 : h
	top = max(1, i - window);
	bottom = min(h, i + window);

	verticalMean = mean(originalSum(top:bottom));
	delta = (originalSum(i) - verticalMean) / w;
	res(i, :) = res(i, :) - delta;
end

end