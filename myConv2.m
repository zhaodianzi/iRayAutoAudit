function [features] = myConv2(data, kernel, step)
[h, w] = size(data);
[m, n] = size(kernel);
a = length(1 : step : h - m + 1);
b = length(1 : step : w - n + 1);
features = zeros(a, b);
ii = 1;
for i = 1 : step : h - m + 1
	jj = 1;
	for j = 1 : step : w - n + 1
		box = data(i : i + m - 1, j : j + n - 1);
		res = box .* kernel;
		features(ii, jj) = sum(res(:));
		jj = jj + 1;
	end
	ii = ii + 1; 
end
end