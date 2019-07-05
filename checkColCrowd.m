function [hasManyCol, cc_mask, ccolIndex] = checkColCrowd(img, BCDetectionThres)
lenThres = 20;
edgeThreshold = 20;
stdThres = 8.8;
win = 80;
[h, w] = size(img);
maskCol = zeros(1, w);
colS = sum(img, 1);
smoothColS = smoothing(colS, 0.03, 'rlowess');
flatColS = smoothing(colS, 0.3, 'rlowess');
colS = smoothColS - flatColS;
stdCol = std(img);
dsm = colS(2:end) - colS(1:end-1);
startPos = -1;
hasManyCol = 0;
boundThres = 9000;
sig = std(colS);
% lowThres = -BCDetectionThres * sig;
% highThres = BCDetectionThres * sig;
lowThres = max(-boundThres, -BCDetectionThres * sig);
highThres = min(boundThres, BCDetectionThres * sig);
for i = 1 + edgeThreshold : w - edgeThreshold
	% 	colIndex = find(maskCol ~= 0);
	% 	left = max(1, i - win); right = min(w, i + win);
	% 	index = [left : i - 1, i + 1 : right];
	% 	index = setdiff(index, colIndex);
	% 	avr = mean(colS(index)); sig = std(colS(index));
	% 	lowArr(i) = max(avr - boundThres, avr - BCDetectionThres * sig);
	% 	highArr(i) = min(avr + boundThres, avr + BCDetectionThres * sig);
	% 	lowThres = max(avr - boundThres, avr - BCDetectionThres * sig);
	% 	highThres = min(avr + boundThres, avr + BCDetectionThres * sig);
	if colS(i) > highThres || colS(i) < lowThres
		if startPos == -1 %&& stdCol(i) < stdThres
			startPos = i;
		end
	else
		if startPos ~= -1
			preWidth = i - startPos;
			pos = sign(smoothColS(i - 1) - smoothColS(startPos));
			subD = dsm(startPos - 1 : i + 1);
			flag = 0;
			if pos == 1
				if sum(find(subD < 0)) > 0, flag = 1; end
			elseif pos == -1
				if sum(find(subD > 0)) > 0, flag = 1; end
			else
				flag = 1;
			end
			if preWidth >= lenThres && flag == 1
				hasManyCol = 1;
				maskCol(startPos : i - 1) = 1;
			end
			startPos = -1;
		end
	end
end
if startPos ~= -1
	preWidth = w - startPos;
	pos = sign(smoothColS(w - 1) - smoothColS(startPos));
	subD = dsm(startPos - 1 : w - 1);
	flag = 0;
	if pos == 1
		if sum(find(subD < 0)) > 0, flag = 1; end
	elseif pos == -1
		if sum(find(subD > 0)) > 0, flag = 1; end
	else
		flag = 1;
	end
	if preWidth >= lenThres && flag == 1
		hasManyCol = 1;
		maskCol(startPos : w - 1) = 1;
	end
	startPos = -1;
end
% figure, plot(colS(1+edgeThreshold:end))
% hold on, plot(lowArr(1+edgeThreshold:end))
% hold on, plot(highArr(1+edgeThreshold:end))
cc_mask = repmat(maskCol, h, 1);
ccolIndex = find(maskCol ~= 0);
end
