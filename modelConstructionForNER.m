%% Construct multiple non-stationary VAR time series
% model is derived from MVGC toolbox demo, var9model. Output is X
%
% Coefficients for the model are set in A, which is setup such that each
% "page" (along the 3rd dimension) of A can be multiplied with a vector of
% the channel's at the given page's lag to yield the AR equation. 
%
% For example, if we had a 2 variable 2nd order model defined by:
%
% A(:,:,1) = [0.5 0.2;
%            [0   -0.4];
% A(:,:,2) = [-0.3 0.1;
%             0    0.6];
%
% The model is produced by A(:,:,i)*[ X1[n-i] ; X2[n-i] ] for each
% page, i
%
% This would produce a model defined by the equations:
% X1[n] = 0.5*X1[n-1] + 0.2*X2[n-1] - 0.3*X1[n-2] + 0.1*X2[n-2]
% X2[n] = -0.4*X2[n-1] + 0.6*X2[n-2]
%
% WGN is then added to each equation based on the covaraince matrix, SIGT
% (which for simplicity of this demo, Barnett and Seth selected a 
% "minimal var" model using just an identity matrix for the covariance)
%
%  Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/7/18

%% Parameters
tic
clearvars -except dacount numRuns

ntrials   = 1000;    % number of trials
dur       = 1;       % duration of trial (s)
fs        = 200;     % sampling frequency (Hz)

nobs  = dur*fs;      % number of observations per trial

%% VAR model construction
rng('shuffle')
streamChoices = [{'dsfmt19937'};
                {'mcg16807'};
                {'mlfg6331_64'};
                {'mrg32k3a'};
                {'mt19937ar'};
                {'shr3cong'};
                {'swb2712'}];

%selectedStream = streamChoices{randi(length(streamChoices))}; % change for diff randomization
selectedStream = '';  % enter in '' for randomization based on clock


% randomly generate relationships and their power; if you desire to make an
% explicit model, comment out this section and place the info you want into
% "relationships" and "details" (see var10model.m for what the structure
% should be for those variables)
numrels = randi(4);
relationships = [];
details = [];
for i = 1:numrels
    thisRelChans = datasample(1:3,2,'Replace',false);
    relationships = [relationships ; thisRelChans];
    details = [details ; 20+randi(10) randi(3) 1+randi(2) ];
end

[Aorig, nvars, p, s] = var10model(relationships, details, selectedStream);

SIGT = eye(nvars); % covariance matrix; minimal VAR uses identity matrix

X = var_to_tsdata(Aorig,SIGT,nobs,ntrials); % time series construction

% save!
thedate = date;
time = clock;
save(['Model_' thedate num2str(time(4)) num2str(time(5)) num2str(round(time(6)))])
disp('raw model preparation complete!')
