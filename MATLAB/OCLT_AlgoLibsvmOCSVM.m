% AW_LibsvmOCSVM 用于包装LibSVM库（的OCSVM分类部分）
% 实际上仅仅是一个包装（至少目前为止）

% 作者：刘家辰
% 更新时间：2013年4月24日10:48:13

function out = OCLT_AlgoLibsvmOCSVM(varargin)
    name = 'LibSVM OC-SVM Classifier';
	%prtrace(mfilename);

    argin = setdefaults(varargin,[],' ',0.1,[]);
	
	if mapping_task(argin,'definition')
        %% Path A: 生成尚未训练的（untrained）分类器
        %   如果调用算法的时候没有提供参数，或没有提供训练数据集，则走此处的逻辑。
		w = prmapping(mfilename,'untrained');
		w = setname(w,name);
		out = w;
        %fprintf('Untrained Subspace Classifier\n');
    else
        %% Path B: 训练分类器
        %   凡是提供了训练数据集，同时param不是一个已经训练好的分类器的调用
        %   均认为是训练分类器，例如A*AW_OCAdaBoost, A*AW_OCAdaBoost(A)
        if mapping_task(argin,'training') % 关键分支A：构成一个包装
            [A, W, rejf, validA] = deal(argin{:});
            
            [~,numAttributes,numClasses] = getsize(A); 
            [label, inst] =  DataConvertLibsvm2PRTools(A);
            data.libsvmArgs = W;
            if (length(W) > 0) % No Auto Model Selection
                data.libsvmModel = svmtrain(label, inst, ...
                    ['-s 2 -t 2', ' -n ', num2str(rejf), ' ', data.libsvmArgs]);                 
            else
                [~,bestg] = OCLT_LibsvmModelSelectionForOCSVM(A, rejf, validA);
                %msgbox(['Best G is ', num2str(bestg)]);
                data.libsvmModel = svmtrain(label, inst, ...
                    ['-s 2 -t 2', ' -n ', num2str(rejf), ' -g ', num2str(bestg), ' ', data.libsvmArgs]);               
            end

            data.SV = A(data.libsvmModel.sv_indices, :);
           
            out = prmapping(mfilename, 'trained' , data, getlablist(A),numAttributes,numClasses);
            out = setname(out,name);
        elseif mapping_task(argin,'execution') % 关键分支B：测试分类器
            %% Path C: 评估分类器
            % 使用测试数据集评估分类器的调用方式实际上有两种： 
            %       evaResult = AW_OCAdaBoost(testingData, W)
            %       evaResult = testingData * W;  % 自动判定mapping类型
            %   处理的时候都按照第一种，即：
            %       参数1：测试数据集
            %       参数2：训练好的mapping
            %       返回值：结果dataset
            %   所谓的“结果dataset”是一种特殊的dataset，除了data域之外，其内容
            %   与测试数据（参数1）一致。data域是后验概率矩阵，行列数s x c，其中
            %       s：样本数
            %       c：类别数
            %   可见，“结果dataset”的data域中，每一行表示一个样本在各类别上的估计
            %   最终的分类结果（暂不考虑soft）是其中最大的一个。
            %   所以，可以通过以下方式从“结果dataset”中取得分类结果向量：
            %    [mx,result] = max(+evaResult,[],2); % result是结果
               [A,W] = deal(argin{1:2});
            %fprintf('Evaluating Subspace Classifier...\n');
           
            if(isnumeric(A)) % Sometimes, A is a double array rather than a dataset
                A = dataset(A);
                [~, inst] = DataConvertLibsvm2PRTools(A);
            else
                [~, inst] = DataConvertLibsvm2PRTools(A);
            end
            
            [numInstances,numAttributes,numClasses] = getsize(A); 
            [label_true, inst_true] = DataConvertLibsvm2PRTools(A);
            
            [predict_label, ~, dec_values] = ...
                svmpredict(label_true, inst, W.data.libsvmModel);
            
            data = zeros(numInstances, 2);
            data(:, 2) = dec_values;
                      
            out = prdataset(A); 
            out.data = data;
            out.featlab = A.lablist{1,1};
            %out = setdata(out, data);
        else
            out = 'error';
            error('Wrong Invoking, please check input arguments.');
        end
	end

	return
end

