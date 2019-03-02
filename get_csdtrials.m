function [csd zs]=get_csdtrials(csd_input,index,info)

%[csd zs]=get_csdtrials(csd_input,index,info)
%  get CSD from csd_input using iCSD method
%
%
% Corentin Massot
% Cognition and Sensorimotor Integration Lab, Neeraj J. Gandhi
% University of Pittsburgh  
% created 09/06/2017 last modified 09/06/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%NOTE: flips should be good but check with fake signals
%el_pos = flip(info.depths(info.chmap(index)));
el_pos = 1:16;
% csd_input=flip(csd_input);

%iCSD
[csd,zs]=compute_iCSD(csd_input,el_pos*1e-3,0);
