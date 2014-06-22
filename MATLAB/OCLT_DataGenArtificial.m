%工具函数，用于生成单类分类器实验的人工数据

% % 调用示例：
% OCLT_DataGenArtificial('rectangle',[100,100],[2 2 1 1],20);
% OCLT_DataGenArtificial('sine',[150,50],[1 10 2 1],25);
% OCLT_DataGenArtificial('spiral',[300,100],[],40);
% OCLT_DataGenArtificial('multi density',[100,100]);
% OCLT_DataGenArtificial('two circle',[100,100]);
% OCLT_DataGenArtificial('twin sine',[100,100]);

function A = OCLT_DataGenArtificial(type, nbSamples, args, snr)
switch type
    case 'banana'
        %% 香蕉型数据
        A = gendatb(nbSamples);
        A = oc_set(A,'1');
    case 'two circle'
        %% 双圆环数据
        numPoints = nbSamples;
        if(nargin < 3)
            radius = [2, 3, 5, 6];
        else
            radius = args;
        end
        
        num1 = numPoints(1);
        num2 = numPoints(2);

        t1 = 2 * pi * rand(num1,1);
        r1 = radius(1) + (radius(2) - radius(1)).*rand(num1,1);
        x1 = r1.*cos(t1);
        y1 = r1.*sin(t1);

        t2 = 2 * pi * rand(num2,1);
        r2 = radius(3) + (radius(4) - radius(3)).*rand(num2,1);
        x2 = r2.*cos(t2);
        y2 = r2.*sin(t2);

        data = [x1 y1];
        data = [data ; x2 y2];
        label_1 = ones(num1, 1);
        label_2 = ones(num2, 1);
        label = [label_1 ; label_2.*2];

        A = dataset(data,label);
    case 'rectangle' 
        %% 带噪声的矩形数据
        % args(1) args(2) 是矩阵的长和宽 (args(3), args(4))是矩阵左下角的坐标
        fprintf('Generating Artificial Data for OCC--Rectangle 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Rectangle Shape--[%.2f,%.2f] Position--(%.2f,%.2f)\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 按照矩形的 南、东、北、西顺序决定随机样本的位置参数，作为Target类
        samplePos = (2*args(1) + 2*args(2)) * rand(1, nbSamples(1));
        for i = 1 : 1 : nbSamples(1)
            if (samplePos(i) <= args(1))
                dataTarget(i, 1) = samplePos(i) + args(3);
                dataTarget(i, 2) = args(4);
            elseif (samplePos(i) <= args(1) + args(2))
                dataTarget(i, 1) = args(1) + args(3);
                dataTarget(i, 2) = samplePos(i) - args(1) + args(4);                
            elseif (samplePos(i) <= 2*args(1) + args(2))
                dataTarget(i, 1) = args(3) + args(1) - (samplePos(i) - args(1)- args(2));
                dataTarget(i, 2) = args(2) + args(4);                 
            elseif (samplePos(i) <= 2*args(1) + 2*args(2))
                dataTarget(i, 1) = args(3);
                dataTarget(i, 2) = args(4) + (samplePos(i) - 2*args(1) - args(2));                 
            else
                fprintf('Fatal Error\n');
                return;                
            end
        end
        % 对Target类的坐标加扰动
        dataTarget = awgn(dataTarget, snr);
        
        % 随机生成Outlier类，范围是130%扩展的矩形
        outlierBoundryX = [args(3) - abs(args(3))*0.3 ; args(3) + args(1) + abs(args(3))*0.3];
        outlierBoundryY = [args(4) - abs(args(4))*0.3 ; args(4) + args(2) + abs(args(4))*0.3];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % 生成数据集
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成矩形分布
    case 'sine'
        %% 带噪声的正弦形数据
        % args(1) args(2) 是 X轴方向的跨度，args(3)是Y轴的位置，args(4)是正弦的振幅
        fprintf('Generating Artificial Data for OCC--Sine 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Sine X range--[%.2f,%.2f] Base Y--[%.2f] Amplitude--[%.2f]\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 按照X轴的区间取随机值
        dataTarget(:,1) = args(1) + (args(2)-args(1)).*rand(nbSamples(1),1);
        dataTarget(:,2) = cos(dataTarget(:,1))*args(4) + args(3);
         % 对Target类的坐标加扰动
        dataTarget = awgn(dataTarget, snr);
        
        % 随机生成Outlier类，范围是130%扩展的矩形
        outlierBoundryX = [args(1) - abs(args(1))*0.3 ; args(2) + abs(args(2))*0.3];
        outlierBoundryY = [(args(3) -1 - abs(args(3))*0.3) ; (args(3) +1+ abs(args(3))*0.3)];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % 生成数据集
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成正弦分布
	case 'spiral'
        %% 带噪声的双螺旋形数据
        % args(1) args(2) 是
        fprintf('Generating Artificial Data for OCC--Spiral 2-D Data...');
        fprintf('  Sample Count--[%d,%d] \n',...
            nbSamples(1), nbSamples(2));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 计算双螺旋线的基准位置，正负类各100个点
        i = (1:1:100)';
        alpha=pi*(i-1)/25;
        beta=0.4*((105-i)/104);
        targetBase_x=0.5+beta.*sin(alpha);
        targetBase_y=0.5+beta.*cos(alpha); % Target类基准点：共100个
        outlierBase_x=0.5-beta.*sin(alpha);
        outlierBase_y=0.5-beta.*cos(alpha); % Outlier类基准点：x1-y1 共100个
        
        % 按照所需的样本点数，随机定位到基准点，之后加入随机扰动得到实际样本点
        randTarget = round(1 + (100-1).*rand(nbSamples(1),1));
        dataTarget = [targetBase_x(randTarget) targetBase_y(randTarget)];
        dataTarget = awgn(dataTarget, snr);
        
        randOutlier = round(1 + (100-1).*rand(nbSamples(2),1));
        dataOutlier = [outlierBase_x(randOutlier) outlierBase_y(randOutlier)];   
        dataOutlier = awgn(dataOutlier, snr);

        % 生成数据集
        A = dataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成双螺旋分布
	case 'multi gauss'
        %% 生成多个高斯分布的Target
        part1 = oc_set(gauss([150 30],[-1 -1; 3 3]),'1');
        part2 = oc_set(gauss([150 30],[8 8; 5 5]),'1');
        part3 = oc_set(gauss([150 30],[-1 8; 4 4]),'1');
        A = LC_CombineDatasets(part1, part2, 1);
        A = LC_CombineDatasets(A, part3, 1);
        % END 生成多个高斯分布
    case 'multi density'
        %% 生成多个不同密度分布的Target
        part1 = OCLT_DataGenArtificial('sine',[200,200],[-6 2 6 2],20);
        part2 = oc_set(gendatb([120,120]),'2');
        %part2 = oc_set(gauss([150 30],[6 7; 5 5]),'1');
        A = OCLT_DataCombineDatasets(part1, part2);
        % END 生成多个不同密度分布的Target
    case 'multi gauss for cluster stability analysis'
        %% 生成多个高斯分布的Target，用于聚类稳定性分析
        part1 = oc_set(gauss([100 30],[0 0; 0 0]),'1');
        part2 = oc_set(gauss([100 30],[5 5; 5 5]),'1');
        part3 = oc_set(gauss([100 30],[0 5; 0 5]),'1');
        part4 = oc_set(gauss([100 30],[5 0; 5 0]),'1');
        A = LC_DataCombineDatasets(part1, part2, 1);
        A = LC_DataCombineDatasets(A, part3, 1);
        A = gendatoc(A);
        A = gendatoc(A, part4);       
        % END 生成多个高斯分布，用于聚类稳定性分析
    case 'twin sine'
        %% 生成两个相邻的正弦分布
        part1 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
        part2 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 3 1],25);
        [part1_target, part1_outlier] = target_class(part1);
        [part2_target, part2_outlier] = target_class(part2);
        A_target = LC_DataCombineDatasets(part1_target, part2_target, 0);
        A_outlier = LC_DataCombineDatasets(part1_outlier, part2_outlier, 0);
        A = gendatoc(A_target, A_outlier);
    case 'twin gauss'
        %% 生成2个高斯分布的Target
        part1 = oc_set(gauss([150 100],[-1 -1; 0.5 -1]),'1');
        part2 = oc_set(gauss([150 100],[2.5 3; 1.2 2.3]),'1');
        A = gendatoc(part1, part2);
        %A = LC_CombineDatasets(part1, part2, 1);
end

end