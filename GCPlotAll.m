%% plot results
%  You should be able to load any results of GC saved with the final
%  section of script and then run this section to plot its GC. If you want
%  to plot the null distributions, you'll have to hack it.
%
% Adam Smoulder, Cognition and Sensorimotor Integration Lab, 9/9/18

allSpecGCs = zeros([5 size(specGC_NN)]);
for i = 1:5
    eval(['allSpecGCs(i,:,:,:) = specGC_' selections{i} ';']);
end

% used for colors and stuff
tag = [{'k--'}; {'r-'}; {'b-'}; {'m-'}; {'g-'};];

maxGC = max(allSpecGCs(:)); % max GC value for lower half of frequencies
freqs = linspace(0,fs/2,fres+1);          % frequency values

% frequency GC Plot
figure('units','normalized','outerposition',[0 0 1 1])
for i=1:ninputs
    for j=1:ninputs
        if i~=j
            subplot(ninputs,ninputs,(i-1)*ninputs+j); % subplot [i,j]
            hold on
            %plot(freqs,squeeze(nullDistGC(i,j,:)),'r--')
            for k = 1:5
                plot(freqs,squeeze(allSpecGCs(k,i,j,:)),tag{k},'Linewidth',2)
            end
            ylabel('Frequency (Hz)')
            axis xy
            axis([0 100 -inf maxGC])
            hold off
        end
    end
end

subplot(ninputs, ninputs, 2)
legend('Ground Truth', 'None','Bipolar','CSD','CAR')
title(['GC for ' selection])

subplot(ninputs, ninputs, ninputs^2)
relAcctxt = sprintf('relAcc: %.4f %.4f %.4f %.4f',[relAcc_Q1 relAcc_bip relAcc_csd relAcc_car]);
msetxt = sprintf('mse: %.4f %.4f %.4f %.4f',[mse_Q1 mse_bip mse_csd mse_car]);
petxt = sprintf('pe: %.4f %.4f %.4f %.4f',[pe_Q1 pe_bip pe_csd pe_car]);
axis([0 1 0 1])
text(0.1, 0.75, ['relAcc = ' relAcctxt])
text(0.1, 0.55, ['mse = ' msetxt])
text(0.1, 0.25, ['pe = ' petxt])

