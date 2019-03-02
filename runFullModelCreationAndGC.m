% Script used for running a bunch of randomized models from this simulation
% pipeline. Make sure modelConstruction and modelMVGC are configured such
% that the relationships/details are randomized and the selections can be
% set separately for each run (I'd recommend just try running 2 or 3 once,
% then check the results!
%
% Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/9/18

%% run models
numRuns = 3;

for dacount = 1:numRuns
    modelConstructionForNER
    modelDereferencing
    modelEstimationOrder
    
    selections = [{'NN'}; {'Q1'}; {'bip'}; {'csd'}; {'car'}];
    for qq = 1:length(selections)
        selection = selections{qq};
        modelMVGC
    end
    close all
    clearvars -except dacount numRuns
end

%% Get errors from all models
selections = [{'NN'}; {'Q1'}; {'bip'}; {'csd'}; {'car'}];

for ii = 1:numRuns
    load(['GCforModel_' num2str(ii)]);
    disp(['Loaded GCforModel_' num2str(ii)]);
    if ii == 1
        relAccAll = zeros([dacount 4]);
        relAccAllFP = zeros([dacount 4]);
        relAccAllFN = zeros([dacount 4]);
        mseAll = zeros([dacount 4]);
        peAll = zeros([dacount 4]);        
    end
    
    for jj = 2:(length(selections))
        eval(['relAccAll(ii,jj-1) = relAcc_' selections{jj} ';']);
        eval(['relErrAllFP(ii,jj-1) = relErrFP_' selections{jj} ';']);
        eval(['relErrAllFN(ii,jj-1) = relErrFN_' selections{jj} ';']);
        eval(['mseAll(ii,jj-1) = mse_' selections{jj} ';']);
        eval(['peAll(ii,jj-1) = pe_' selections{jj} ';']);
    end
end


relAccAvg = squeeze(mean(relAccAll))
relAccStd = squeeze(std(relAccAll))
relAccMed = squeeze(median(relAccAll))
relErrFPAvg = squeeze(nanmean(relErrAllFP))
relErrFPStd = squeeze(std(relErrAllFP))
relErrFPMed = squeeze(median(relErrAllFP))
mseAvg = squeeze(mean(mseAll))
mseStd = squeeze(std(mseAll))
mseMed = squeeze(median(mseAll))
mseQuarts = quantile(mseAll,3)
peAvg = squeeze(mean(peAll))
peStd = squeeze(std(peAll))
peMed = squeeze(median(peAll))


