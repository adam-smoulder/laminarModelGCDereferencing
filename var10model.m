%% Function for creating a 10 variable VAR model that exhibits larger scale
%  interactions approximately an order of magnitude larger than local scale
%  interactions. 
%
%  This script was made for simulating a 3 layered structure where the first
%  9 of 10 electrode contacts are in the structure and the last is outside of it.
%
%  Adapted from MVGC toolbox var9test script from Lionel Barnett and Anil
%  K. Seth
%
%
%
%  inputs:
%  
%  relations - nx2 matrix, where n is the number of desired large scale
%  relationships to utilize. The first value of each row is the "affector",
%  whereas the second is the "affectee", where 1 is superficial, 2 is
%  intermediate, and 3 is deep. For example, if I input [2, 3 ; 3, 1], I
%  would be stating I want a large scale relationship of intermediate
%  affecting deep layers and deep affecting superficial layers.
%
%  details - nx3 matrix. The first value of row n in details is the 
%  relative power of the relationship described in row n of relations with
%  respect to the average local power shared (I'd roughly use 10 for this
%  to start). The second and third values are the number of channels from
%  which to source (affect) and sink (effect), respectively. Playing from
%  the above example, if I had details as [10, 3, 1 ; 15, 2, 2], I would be
%  saying I want the intermediate -> deep relationship to happen from all 3
%  intermediate channels onto only 1 deep channel with 10x the local
%  affecting power, whereas I want the deep -> superficial layer effects to
%  be 15x the local power with 2 channels in deep affecting 2 channels in
%  superficial
%
%  Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/7/18

function [A, n, p, s] = var10model(relations, details, selectedStream)


% create initial model
n = 10; % number of variables
p = 3; % model order

A = zeros(n,n,p);

A(:,:,1) = [
     0.0114   -0.04088          0           0          0          0         0         0          0       0;
   -0.03394    -0.0192      0.028           0          0          0         0         0          0       0;
          0    0.02400     0.0194     0.03437          0          0         0         0          0       0;
          0          0    0.03302      0.0188    0.03000          0         0         0          0       0;
          0          0          0     0.02851     0.0027    0.01000         0         0          0       0;
          0          0          0           0    0.01039    -0.0020   0.03160         0          0       0;
          0          0          0           0          0    0.03030   -0.0186      0.01          0       0;
          0          0          0           0          0          0      0.01   -0.0084    0.03477       0;
          0          0          0           0          0          0         0   0.02810    -0.0208    -.02;
          0          0          0           0          0          0         0         0       0.01    0.05;   
];

A(:,:,2) = [
    0.0148    0.02590          0          0          0          0          0          0         0       0;
    0.02232   -0.0070    0.01779          0          0          0          0          0         0       0;
         0    0.01800    -0.0058    0.02008          0          0          0          0         0       0;
         0          0    0.02103     0.0012   -0.01590          0          0          0         0       0;
         0          0          0   -0.01597     0.0065    0.01989          0          0         0       0;
         0          0          0          0    0.02062     0.0177    0.01897          0         0       0;
         0          0          0          0          0    0.01895    -0.0008      0.003         0       0;
         0          0          0          0          0          0      0.003    -0.0032   -0.0138       0;
         0          0          0          0          0          0          0   -0.01718    0.0068    0.01;
         0          0          0          0          0          0          0          0      0.03   -0.003;
];

A(:,:,3) = [
    0.0076    0.01434         0         0         0         0         0         0         0         0;
    0.01082   -0.0065   0.01351         0         0         0         0         0         0         0;
         0    0.01300     0.005   0.00926         0         0         0         0         0         0;
         0          0    0.0109   -0.0037    0.0090         0         0         0         0         0;
         0          0         0   0.01000    0.0097   0.01347         0         0         0         0;
         0          0         0         0    0.0135   -0.0081   0.02000         0         0         0;
         0          0         0         0         0    0.0227   -0.0004      0.03         0         0;
         0          0         0         0         0         0      0.03   -0.0014   0.01397         0;
         0          0         0         0         0         0    	  0   0.01417   -0.0022    -0.005;
         0          0         0         0         0         0         0         0      0.01     -0.02;
];


% scale up or down local interactions a bit if desired
c = 0.5;
A = A.*...
    repmat([ 1 c 1 1 1 1 1 1 1 1;
             c 1 c 1 1 1 1 1 1 1;
             1 c 1 c 1 1 1 1 1 1;
             1 1 c 1 c 1 1 1 1 1;
             1 1 1 c 1 c 1 1 1 1;
             1 1 1 1 c 1 c 1 1 1;
             1 1 1 1 1 c 1 c 1 1;
             1 1 1 1 1 1 c 1 c 1;
             1 1 1 1 1 1 1 c 1 c;
             1 1 1 1 1 1 1 1 c 1;],[1,1,3]);
         
localPowerAvg = c*0.025; % approximate


% incorporate larger scale interactions input by user
nrel = size(relations,1);  % number of relationships
assert(nrel==size(details,1));

B = zeros(size(A));
chanDepths = [1 2 2 3; 4 5 5 6; 7 8 8 9]; % biases connections to middle of layers
if strcmp(selectedStream,'')
    s = RandStream.getGlobalStream;
else
    s = RandStream(selectedStream); % used for reproducibility
end

for i = 1:nrel
    relPower = details(i,1)*localPowerAvg;
    affectorChans = datasample(s, chanDepths(relations(i,1),:), ...
        details(i,2), 'Replace',false);
    affecteeChans = datasample(s, chanDepths(relations(i,2),:), ...
        details(i,3), 'Replace',false);
    
    for j = 1:length(affectorChans)
        for k = 1:length(affecteeChans)
            signs = sign(rand(1,3)-0.5); % randomize sign of interactions
            B(affecteeChans(k),affectorChans(j),:) = ...
                signs.*[0.1*rand+0.2*relPower 0.1*rand+relPower 0.1*rand+0.6*relPower]; % weighs most power to 2nd order, lots to 3rd order too
        end
    end
end

% finally, add them together
A = A+B;
end
