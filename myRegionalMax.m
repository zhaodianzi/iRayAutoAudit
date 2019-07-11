function [lmax] = myRegionalMax(img, magThres)
win = 1;
[h, w] = size(img);
lmax = img >= magThres;
[r, c] = find(lmax == 1);
for i = 1 : length(r)
	row = r(i); col = c(i);
	up = max(1, row - win);
	down = min(h, row + win);
	left = max(1, col - win);
	right = min(w, col + win);
	box = img(up:down, left:right);
	if sum(box(:) >= img(row, col)) > 1
		lmax(row, col) = 0;
	end
end
end