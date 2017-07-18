% function mnrmlSpaceChange(inputFile,outputFile)
%
% Transforms the input data arranged to perform classification to the MNRML
% created space.
% Input: inputFile; data ready to perform classification per fold
% Input: outputFile; The file name where the input data transformed to the new
% MNRML space will be stored.
%% Example of call to the function
% inputFile = 'C:\Users\oscar\Desktop\TFM\project\data\classification_data_ms.mat.mat';
% outputFile = strcat(inputFile(1:length(classificationDataFileName)-4),'_mnrml.mat');
% mnrmlSpaceChange(inputFile,outputFile);
function [projFea,W,beta] = mnrmlProjection(fea, idxa, idxb, fold, ...
    matches, K, T, knn, eigValPerc, wdims)

disp('MNRML projection started. Folds: ')

addpath('external/NRML/nrml');

un = unique(fold);
nfold = length(un);

%% NRML
%if wdims == -1
Wdims = inf;
for p = 1:K
    newSize = size(fea{p},2);
        if newSize < Wdims
            Wdims = newSize;
        end
end
%else
%    Wdims = wdims;
%end
for c = 1:nfold
    
    % Display number of fold processing
    txt = strcat('fold number', num2str(c));
    disp(txt)
    disp('')
    
    trainMask = fold ~= c;
    testMask = fold == c;
    tr_idxa = idxa(trainMask);
    tr_idxb = idxb(trainMask);
    tr_matches = matches(trainMask);
    
    %% do PCA  on training data
    for p = 1:K
        X = fea{p};
        tr_Xa_pos{p} = X(tr_idxa(tr_matches), 1:Wdims); % positive training data
        tr_Xb_pos{p} = X(tr_idxb(tr_matches), 1:Wdims); % positive training data
        feaPCA{p} = X;
        clear X;
    end
    %% MNRML
    [W{c}, beta{c}] = mnrml_train(tr_Xa_pos, tr_Xb_pos, knn, Wdims, T);
    
    for p = 1:K
        projFea{c}{p} = feaPCA{p}(:,1:Wdims) * W{c};
    end
    
    clear feaPCA;
end

disp('MNRML projection finished')


end

% Returns the maximum value of Wdims (the value that holds percEigVal information
% of the feature that needs the biggest information) of all the folds
function maxWdims = calculateWdims(percEigVal, fea, idxa, idxb, fold, K)

un = unique(fold);
nfold = length(un);

maxWdims = 0;

for c = 1:nfold
    trainMask = fold ~= c;
    tr_idxa = idxa(trainMask);
    tr_idxb = idxb(trainMask);
    
    for p = 1:K
        X = fea{p};
        tr_Xa = X(tr_idxa, :);                    % training data
        tr_Xb = X(tr_idxb, :);                    % training data
        [~, eigval, ~, ~] = PCA([tr_Xa; tr_Xb]);
        totalEig = sum(eigval);
        accum = 0;
        idx = 0;
        while accum/totalEig < percEigVal
            idx = idx + 1;
            accum = accum + eigval(idx);
        end
        Wdims = idx;
        if Wdims > maxWdims
            maxWdims = Wdims;
        end
    end
end
end