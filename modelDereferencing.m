%% The purpose of this script is to take a model created by 
% modelConstruction.m and:
% - maintain the original model with no noise, crunch to 3 channels (X_NN)
% - corrupt the original model with noise of equal (1) variance (X_Q1)
% - perform bipolar differencing on corrupted signals (X_bip)
% - calculate current source density of corrupted signals, crunch to 3 channels (X_csd)
% - perform common average reference subtraction on corrupted signals (X_car)
%
% Assumes X contains time series of the relevant model with dimensions
% channel x time x trial

%% Step 1: Create reference noise, Q, to be added to all channels

Qpower = 1; % variance of noise / variance of signal
Qvariance = Qpower*mean(squeeze(var(X,[],2))); % mean variance of channels
Qcoeff = repmat(sqrt(Qvariance),[size(X,2),1]);
Qfor1Channel = Qcoeff.*randn(size(X,2),size(X,3)); 
Q = permute(repmat(Qfor1Channel, [1 1 size(X,1)]),[3 1 2]); % same noise for each channel within a given trial

%% Step 2: Create output X_NN and X_Q1
XQ = X-Q;  % This would effectively be what we record: signal with reference
supr = 1:3;
intr = 4:6;
deep = 7:9;
X_NN = [mean(X(supr,:,:)) ; mean(X(intr,:,:)) ; mean(X(deep,:,:))];
X_Q1 = [mean(XQ(supr,:,:)) ; mean(XQ(intr,:,:)) ; mean(XQ(deep,:,:))];

%% Step 3a: Dereference XQ using bipolar subtraction
X_bip =[XQ(supr(1),:,:)-XQ(supr(2),:,:);
        XQ(intr(1),:,:)-XQ(intr(2),:,:);
        XQ(deep(1),:,:)-XQ(deep(2),:,:)];
    
%% Step 3b: Dereference XQ using CSD

X_csd = zeros(size(X_NN));
el_pos = (1:nvars)*0.2e-3;      % input electrode positions for CSD calc; taken from commonly used real electrode

for i = 1:ntrials
    disp(['CSD for trial ' num2str(i)])
    
    % compute CSD for all
    [rawCSD,~] = compute_iCSD(squeeze(XQ(:,:,i)),el_pos,0);
    
    % Make Gaussian window for weighting channels
    rowsPerVar = floor(size(rawCSD,1)/nvars);
    suprRows = ((supr(1)-1)*rowsPerVar+1):(supr(3)*rowsPerVar);
    intrRows = ((intr(1)-1)*rowsPerVar+1):(intr(3)*rowsPerVar);
    deepRows = ((deep(1)-1)*rowsPerVar+1):(deep(3)*rowsPerVar);
    
    suprChanWin = gausswin(length(suprRows),1.5); %ones(1,length(suprRows))';
    suprChan = sum((suprChanWin/sum(suprChanWin)).*...
        squeeze(rawCSD(suprRows,:)));
    intrChanWin = gausswin(length(intrRows),1.5); %ones(1,length(suprRows))';
    intrChan = sum((intrChanWin/sum(intrChanWin)).*...
        squeeze(rawCSD(intrRows,:)));
    deepChanWin = gausswin(length(deepRows),1.5); %ones(1,length(suprRows))';
    deepChan = sum((deepChanWin/sum(deepChanWin)).*...
        squeeze(rawCSD(deepRows,:)));
    
    % put it all together
    X_csd(:,:,i) = [suprChan ; intrChan ; deepChan];
end

%% Step 3c: Dereference XQ using CAR
CAR = mean(XQ);
X_carFull = XQ-repmat(CAR,[size(XQ,1), 1, 1]);
X_car = [mean(X_carFull(supr,:,:)) ; 
         mean(X_carFull(intr,:,:)) ; 
         mean(X_carFull(deep,:,:))];
     
%% done!
clear suprChan intrChan deepChan suprRows intrRows deepRows ...
      suprChanWin intrChanWin deepChanWin...
      CAR el_pos Qcoeff Qvariance rawCSD rowsPerVar
save(['DerefModel_' thedate num2str(time(4)) num2str(time(5)) num2str(round(time(6)))])
disp('Model Preparation complete!')
