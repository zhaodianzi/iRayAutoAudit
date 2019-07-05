function [res] = verticalStripeSuppression(img)
window = 100;
[h, w] = size(img);
originalSum = sum(img, 1);
res = img;
for i = 1 : w
	left = max(1, i - window);
	right = min(w, i + window);
	
	verticalMean = mean(originalSum(left:right));
	delta = (originalSum(i) - verticalMean) / h;
	res(:, i) = res(:, i) - delta;
end

end