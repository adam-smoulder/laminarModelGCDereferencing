%% Perform MVGC on selected input (place variable name into "selection")
% adapted from MVGC toolbox examples
%
% Assumes modelEstimationOrder was run beforehand and data from that has
% been loaded!
% 
% Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/9/18

%% GC Prep variables

% selection = 'csd';    % dereference method to use (NN Q1 bip csd car)

% ^if running from external scripts, make sure to comment this variable out 
% and set it externally!

eval(['X4GC = X_' selection ';']) % model order to use
eval(['modelOrder = moAIC_' selection ';']) % model order to use


% Parameters that should not change between runs
ninputs = size(X4GC,1);     % updated number of inputs
analysisType = 'cond';      % 'cond' = conditional, 'pw' = pairwise
nullDistChoice = 'trial';   % trial for trial shuffle, time for time scramble to make null distribution
dnobs     = 0;          % initial observations to discard per trial - 0; we can ignore as needed
nobs  = dur*fs+1;       % number of time samples in a trial for testing
tnobs = nobs+dnobs;     % total observations per trial for time series generation
k = 1:tnobs;            % vector of time vals


tstat     = 'F';     % statistical test for MVGC: 'F' for Granger's F-test, 'chi2' for Geweke's chi2 test or leave empty for default
alpha     = 1e-9;   % significance level for significance test
mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')


%% Setup for MVGC
% Sets up variables based on configuration, sampling frequency and model 
% order before running MVGC.


% if different model order desired, use following line:
%modelOrder = 10; 

regmode   = 'OLS';                      % VAR model estimation regression mode ('OLS', 'LWR' or empty for default - 'OLS')
nlags     = 10;                         % number of lags in VAR model - 10 for performance sake
fres      = 1000;                       % frequency resolution for calculation - not true frequency resolution! Higher is better but needs more memory - 1k is good typically

t = (k-dnobs-1)/fs;                     % vector of time values
               
% initialize the GC variables
specGC = zeros(ninputs,ninputs,fres);        % dims:  time, eq1, eq2, freq

%% "Vertical" regression GC calculation
%  Performs MVGC on window
disp(['Beginning ' analysisType ' GC calculation'])
tic

if strcmp(analysisType,'cond') % conditional MVGC
    
    % convert time series data in window to VAR model
    [A,SIG] = tsdata_to_var(X4GC,modelOrder,regmode);
    if isbad(A), fprintf(2,'VAR estimation failed\n'); end
    
    % calculate autocovariance from VAR
    [G,info] = var_to_autocov(A,SIG);
    if info.error, fprintf(2,' bad VAR (%s)\n',info.errmsg); end
    if info.aclags < info.acminlags % warn if number of autocov lags is too small (not a show-stopper)
        fprintf(2,' *** WARNING: minimum %d lags required (decay factor = %e)',info.acminlags,realpow(info.rho,info.aclags));
    end
    
    % Calculate GC for window
    specGC = autocov_to_spwcgc(G,fres);     % rate limiting step
    if isbad(specGC,false), fprintf(2,'GC calculation failed\n'); end
    
    timeGC = autocov_to_pwcgc(G);
    pval = mvgc_pval(timeGC,modelOrder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
    sig  = significance(pval,alpha,mhtc);
    eval(['pval_' selection '= pval;'])
    eval(['sig_' selection '= sig;'])

% not fully implemented!
elseif strcmp(analysisType,'pw') % pairwise, no conditioning 
    for ii = 1:ninputs
        for jj = 1:ninputs
            if ii<jj
                [AT,SIG] = tsdata_to_var(X4GC([ii,jj],:,:),modelOrder,regmode);
                if isbad(AT), fprintf(2,' *** skipping - VAR estimation failed\n'); end
                
                [G,info] = var_to_autocov(AT,SIG);
                if info.error, fprintf(2,' *** skipping - bad VAR (%s)\n',info.errmsg); end
                if info.aclags < info.acminlags % warn if number of autocov lags is too small (not a show-stopper)
                    fprintf(2,' *** WARNING: minimum %d lags required (decay factor = %e)',info.acminlags,realpow(info.rho,info.aclags));
                end
                
                a  = autocov_to_spwcgc(G,fres);
                if isbad(a,false)
                    fprintf(2,' *** skipping - GC calculation failed\n');
                end
                specGC(ii,jj,:) = a(1,2,:);
                specGC(jj,ii,:) = a(2,1,:);
                disp(['ii jj = ' num2str(ii) num2str(jj) ' complete']); fprintf('\n');
            end
        end
    end
else  % if not cond or pw
    error('analysis type not supported. Use either analysisType="cond" or analysisType="pw"')
end

fprintf('\n');
timeGC = squeeze(sum(specGC,3));
 
% set values for our selection
eval(['specGC_' selection ' = specGC;'])
eval(['timeGC_' selection ' = timeGC;'])

disp('Completed GC calculation')

%% Calculate null distribution

shuffleCount = 100;  % how many shuffles/scrambles to run

% find null distribution (or set to '' if not desired)
if strcmp(nullDistChoice,'trial')
    trialShuffleForModel % outputs specGC_perm
else    % for quick testing purposes
    specGC_perm = zeros([shuffleCount size(specGC)]);
end


% I add 4*std to give a pretty rigorous check 
nullDistGC = squeeze(mean(specGC_perm))+4*squeeze(std(specGC_perm));
eval(['nullDistGC_' selection '= nullDistGC;']);

% one way of showing significance is to subtract the null distribution...
% not recommended for direct interpretation though, just for intuition
% specGCnew = specGC - nullDistSpecGC;
% timeGCnew = timeGC - nullDistTimeGC;

%% Calculate error metrics
%rels = sum(specGC,3) > sum(nullDistGC,3); % from null distribution
rels = sig; rels(isnan(sig)) = 0; % from timeGC significance
eval(['rels_' selection '= rels;']);
specGC4pe = zscore(specGC,[],3);    % zscored for pattern error
eval(['specGC4pe_' selection '= specGC4pe;']);
    

%  Assumes NN stuff has been run already and exists in the workspace...

if ~strcmp(selection, 'NN')
    % 1) Relationship Accuracy
    relAcc = (sum(sum(rels == rels_NN))-ninputs)/6; % subtracting diagonal and divide by max
    eval(['relAcc_' selection '= relAcc;']);
    eval(['relErrFP_' selection ' = length(find(rels-rels_NN==1))/((1-relAcc)*6);']); % what proportion of errors were false positives?
    eval(['relErrFN_' selection ' = 1-length(find(rels-rels_NN==1))/((1-relAcc)*6);']); % what proportion of errors were false negatives?

    % 2) Mean squared error
    mse = nanmean(nanmean(nanmean((specGC-specGC_NN).^2)));
    eval(['mse_' selection '= mse;']);

    % 3) Pattern error
    pe = nanmean(nanmean(nanmean((specGC4pe-specGC4pe_NN).^2)));
    eval(['pe_' selection '= pe;']);
    
    % for display
    relAcc
    mse
    pe
end
%% Save relevant GC data
disp('Saving...')

save(['GCforModel_' num2str(dacount)]);

