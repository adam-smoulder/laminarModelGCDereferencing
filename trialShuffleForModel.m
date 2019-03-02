%% Trial shuffle runs.
% Run after performing GC normally!
%
% Establish GC null distribution by shuffling trials while retaining 
% temporal and spacial structure then finding GC
% For example, superficial -> mid GC normally is calculated by:
%
% trial 1 sup -> trial 1 mid
% trial 2 sup -> trial 2 mid
% ...
% trial 167 sup -> trial 167 mid
% 
% though this shuffle will now calculate GC by:
%
% trial 1 sup -> trial 24 mid
% trial 2 sup -> trial 152 mid
% etc.
% 

disp('Beginning Trial Shuffle runs')
clear i j k ii jj

dataPerms = zeros([shuffleCount,size(X4GC)]); % scrambled input data
specGC_perm = zeros([shuffleCount,size(specGC)]); % scrambled GCs


for k=1:shuffleCount
    % scramble the trials while retaining channel and temporal structure
    disp(['Shuffle ' num2str(k)])
    permX = zeros(size(X4GC));
    for q = 1:size(X4GC,1) % for each channel
        permX(q,:,:) = X4GC(q,:,randperm(size(X4GC,3)));  % dims: depth (channel), time, trial
    end
    dataPerms(k,:,:,:) = permX;
    
    
    % "Vertical" regression GC calculation
    specGCtemp = zeros(nvars,nvars,fres);          % dims:  eq1, eq2, freq
    
    if strcmp(analysisType,'cond') % conditional MVGC
        % convert time series data in window to VAR model
        [A,SIG] = tsdata_to_var(permX,modelOrder,regmode);
        if isbad(A), fprintf(2,'VAR estimation failed\n'); end
        
        % calculate autocovariance from VAR
        [G,info] = var_to_autocov(A,SIG);
        if info.error, fprintf(2,' bad VAR (%s)\n',info.errmsg); end
        if info.aclags < info.acminlags % warn if number of autocov lags is too small (not a show-stopper)
            fprintf(2,' *** WARNING: minimum %d lags required (decay factor = %e)',info.acminlags,realpow(info.rho,info.aclags));
        end
        
        % Calculate GC for window
        specGCtemp = autocov_to_spwcgc(G,fres);     % rate limiting step
        if isbad(specGCtemp,false), fprintf(2,'GC calculation failed\n'); end
        
    elseif strcmp(analysisType,'pw') % pairwise, no conditioning
        for ii = 1:nvars
            for jj = 1:nvars
                if ii<jj
                    [AT,SIG] = tsdata_to_var(permX([ii,jj],:,:),modelOrder,regmode);
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
                    specGCtemp(ii,jj,:) = a(1,2,:);
                    specGCtemp(jj,ii,:) = a(2,1,:);
                    disp(['ii jj = ' num2str(ii) num2str(jj) ' complete']); fprintf('\n');
                end
            end
        end
    else  % if not cond or pw
        error('analysis type not supported. Use either analysisType="cond" or analysisType="pw"')
    end
    
    fprintf('\n');
    timeGC = squeeze(sum(specGCtemp,3));
    
    % set values for our selection
    eval(['specGCtemp_' selection ' = specGCtemp;'])
    eval(['timeGC_' selection ' = timeGC;'])
    
    specGC_perm(k,:,:,:) = specGCtemp;
end
