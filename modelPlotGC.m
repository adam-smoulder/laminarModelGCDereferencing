%% plot results
%  You should be able to load any results of GC saved with the final
%  section of script and then run this section to plot its GC. Also plots
%  the null distribution calculated with it!
%
% Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/8/18


% selection = 'car';  % selection must be made before running!


% negative and imaginary values are uninterpretable, so:
% find real part, then make 0 for all neg. vals
eval(['specGC = specGC_' selection ';'])
eval(['nullDistGC = nullDistGC_' selection ';']);


specGC = max(0,real(specGC)); 
nullDistGC = max(0,real(nullDistGC));

maxGC = max(specGC(:)); % max GC value for lower half of frequencies
freqs = linspace(0,fs/2,fres+1);          % frequency values

% frequency GC Plot
figure
for i=1:ninputs
    for j=1:ninputs
        if i~=j
            subplot(ninputs,ninputs,(i-1)*ninputs+j); % subplot [i,j]
            plot(freqs,squeeze(specGC_NN(i,j,:)),'Linewidth',2)
            hold on
            plot(freqs,squeeze(nullDistGC(i,j,:)),'r--')
            ylabel('Frequency (Hz)')
            axis xy
            axis([0 100 -inf maxGC])
            hold off
        end
    end
end

subplot(ninputs, ninputs, 2)
legend('Estimated','Null Dist')
title(['GC for ' selection])



