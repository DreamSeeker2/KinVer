% inputFile = 'C:\Users\oscar\Desktop\TFM\project\data\mnrmlFeat_ms.mat';
% inputFile = 'C:\Users\oscar\Desktop\TFM\project\data\mnrmlFeat_ms_noW.mat';
% SVMClassification(inputFile);

function accuracy = pairSVMClassification(inputFile)

load(inputFile);

% Merge parent and child 2 feature vectors into one (Train data)
Xtrc = mergeIndividualsPerFeaturesAndFolds(Xtra,Xtrb);

% Merge parent and child 2 feature vectors into one (Test data)
Xtsc = mergeIndividualsPerFeaturesAndFolds(Xtsa,Xtsb);

numFolds = size(Xtrc,2);
numFeat = size(Xtrc{1},1);

for feat = 1:numFeat
    allReal{feat} = [];
    allPredicted{feat} = [];
end

for fold = 1:numFolds
    for feat = 1:numFeat
        svmModel = trainLinearSVM(Xtrc{fold}{feat},tr_matches{fold});
        prediction = predictSVM(svmModel,Xtsc{fold}{feat});
        allReal{feat} = [allReal{feat};ts_matches{fold}];
        allPredicted{feat} = [allPredicted{feat};prediction];
    end
end

for feat = 1:numFeat
    accuracy{feat} = calculateAccuracy(allReal{feat},allPredicted{feat});
end

% TODO weight probabilities of classifiers using the beta coeficient
% TODO (to do so, make classifiers output a probabilty instead of the
% class)
% prob = 0;
% for f = 1:numFeat
%     prob = prob + beta{f}*svmFeat{f};
% end

end