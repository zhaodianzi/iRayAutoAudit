function [crowdNum, spotCrowd, crowdMemNum, maxCrowd, A_maxCrowd] ...
	= getBrightSpotCrowd(mask, judgeThres, disThres)
%disThres = 5; %判定是否属于一簇的间隔阈值
crowdNum = 0;
A_crowdNum = 0;
maxCrowd = 0;
A_maxCrowd = 0;
[h, w] = size(mask);
node = find(mask(:) == 1);
number = length(node);
if number >= 20000
	spotCrowd = [];
	crowdMemNum = [];
	return;
end
[row, col] = ind2sub([h, w], node);
father = 1 : number;
rank = ones(number, 1);
for i = 1 : number
	ri = row(i); ci = col(i);
	for j = i + 1 : number
		rj = row(j); cj = col(j);
		dis = sqrt((ri - rj)^2 + (ci - cj)^2);
		if dis < disThres
			[father, rank] = Union(i, j, father, rank);
		end
	end
end
op = 0;
order = zeros(number, 1);
for i = 1 : number
	k = findFather(i, father);
	if order(k) == 0
		op = op + 1;
		order(k) = op;
	end
	order(i) = order(k);
end

for i = 1 : op
	index_i = find(order == i);
	len = length(index_i);
	if len >= judgeThres
		crowdNum = crowdNum + 1;
		spotCrowd(crowdNum).row = row(index_i);
		spotCrowd(crowdNum).col = col(index_i);
		crowdMemNum(crowdNum) = len;
		A_Pix_Len = inCenterRegionLen(row(index_i), col(index_i));
		if A_Pix_Len >= judgeThres
			A_crowdNum = A_crowdNum + 1;
			if A_Pix_Len > A_maxCrowd
				A_maxCrowd = A_Pix_Len;
			end
		end
		if len > maxCrowd
			maxCrowd = len;
		end
	end
end
if crowdNum == 0
	spotCrowd = [];
	crowdMemNum = [];
	return;
end

end

function [len] = inCenterRegionLen(row, col)
len = 0;
for i = 1 : numel(row)
	if row(i) >= 113 && row(i) <= 400 && ...
		col(i) >= 129 && col(i) <= 512
		len = len + 1;
	end
end
end

function [father, rank] = Union(a, b, father, rank)
a = findFather(a, father);
b = findFather(b, father);
if (a == b)
	return;
end
if (rank(a) > rank(b))
	father(b) = a;
else
	if (rank(a) == rank(b))
		rank(b) = rank(b) + 1;
	end
	father(a) = b;
end
end

function [r] = findFather(x, father)
while (father(x) ~= x)
	x = father(x);
end
r = x;
end