function [newData] = removeNUA(img)
winSize = 8;
padSize = 8;
% data = img;
data = padarray(img, [padSize, padSize], 'symmetric');
[h, w] = size(data);
newData = zeros(h, w);
weight = zeros(h, w);
% m = h / blockSize; n = w / blockSize;
for i = 1 : 4 : h
	for j = 1 : 4 : w
		up = max(1, i-winSize);
		down = min(h, i+winSize);
		left = max(1, j-winSize);
		right = min(w, j+winSize);
		up1 = max(1, i-winSize*3-1);
		down1 = min(h, i+winSize*3+1);
		left1 = max(1, j-winSize*3-1);
		right1 = min(w, j+winSize*3+1);
		block = data(up:down, left:right);
		background = data(up1:down1, left1:right1);
		weight(up:down, left:right) = weight(up:down, left:right) + 1;
		newData(up:down, left:right) = newData(up:down, left:right) + block - mean(background(:));
		% 			block = data((i-1)*blockSize+1:i*blockSize, (j-1)*blockSize+1:j*blockSize);
		% 			num = 0;
		% 			blockSum = zeros(blockSize);
		% 			if i > 1
		% 				num = num + 1;
		% 				blockSum = blockSum + data((i-2)*blockSize+1:(i-1)*blockSize, (j-1)*blockSize+1:j*blockSize);
		% 			end
		% 			if i < m
		% 				num = num + 1;
		% 				blockSum = blockSum + data(i*blockSize+1:(i+1)*blockSize, (j-1)*blockSize+1:j*blockSize);
		% 			end
		% 			if j > 1
		% 				num = num + 1;
		% 				blockSum = blockSum + data((i-1)*blockSize+1:i*blockSize, (j-2)*blockSize+1:(j-1)*blockSize);
		% 			end
		% 			if j < n
		% 				num = num + 1;
		% 				blockSum = blockSum + data((i-1)*blockSize+1:i*blockSize, j*blockSize+1:(j+1)*blockSize);
		% 			end
		% 			blockSum = blockSum ./ num;
		% 			newData((i-1)*blockSize+1:i*blockSize, (j-1)*blockSize+1:j*blockSize) = newData((i-1)*blockSize+1:i*blockSize, (j-1)*blockSize+1:j*blockSize) + block - blockSum;
		% 			weight((i-1)*blockSize+1:i*blockSize, (j-1)*blockSize+1:j*blockSize) = weight((i-1)*blockSize+1:i*blockSize, (j-1)*blockSize+1:j*blockSize) + 1;
	end
end
newData = newData ./ weight;
newData = newData(padSize+1:end-padSize, padSize+1:end-padSize);
end