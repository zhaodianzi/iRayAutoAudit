function [] = testNewProcess
is_lambda = 0.008; bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
h = 512; w = 640;
% dataPath = 'E:\BIT\iRay\code\data\������ϴ����\ѵ����\';
% dataPath = 'E:\BIT\iRay\code\data\������ϴ����\580(1��1)\';
dataPath = 'E:\BIT\iRay\code\data\coarse_dataset\';
dataList = dir([dataPath, '*.png']);
dataNum = length(dataList);
pred_label = zeros(dataNum, 1);
real_label = zeros(dataNum, 1);
for itr = 1:dataNum
	real_label(itr) = str2double(dataList(itr).name(1));
	data = double(imread([dataPath, dataList(itr).name]));
	ID = dataList(itr).name;
	
	[label, cr_score(itr)] = getBadRowColFunc(data); % ���л���
	if label > 0
		pred_label(itr) = label;
		continue;
	end
	[label, sp_score(itr)] = getSpotFunc(data); % �߿�
	if label > 0
		pred_label(itr) = label;
		continue;
	end
	[label, ss_score(itr)] = getSlopingFunc(ID(1:end-4)); % б��
	if label > 0
		pred_label(itr) = label;
		continue;
	end
	[label, is_score(itr)] = getShadingFunc(data); % ���ƺ�����
	pred_label(itr) = label;
	if itr >= 25 && mod(itr, 25) == 0
		fprintf('iter %d, correct: %.2f\n', itr, sum(pred_label(1:itr) == real_label(1:itr)));
	end
end

end