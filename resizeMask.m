function [newMask] = resizeMask(mask, scale)
[h, w] = size(mask);
newMask = zeros(h * scale, w * scale);
for i = 1 : h
	for j = 1 : w
		if mask(i,j) > 0
			newMask((i-1)*scale+1:i*scale, (j-1)*scale+1:j*scale) = mask(i,j);
		end
	end
end
end