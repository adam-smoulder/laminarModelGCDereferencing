function [csd zs clim]=plot_csdtrials(csd_input,index,events,event_align,max_plot,info,hdlfig,titlestr)

%function [csd zs]=plot_csdtrials(csd_input,index,events,event_align,max_plot,info,hdlfig,titlestr)
%  plot CSD from csd_input using iCSD method
%
%example:[csd zs clim]=plot_csdtrials(csd_input,1:info.nchannels,[],[],max_plot,info,[],[])
%example of 'info' structure:
% info = 
% 
%   struct with fields:
% 
%        datafile: 'bl_rSCTrack_022616_DelaySacc_vl_2.mat'
%           chmap: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
%       nchannels: 16
%          depths: [1×16 double]
%       trialtype: {'DelaySacc'}
%     targ_tuning: 2
%           align: 'sacc'
%       aligntime: 150
%            targ: 2
%         ntrials: 108
%        triallen: 201
%
% depths of each channel in mm
%     info.depths=2.35:-0.15:0.1
%
% max_plot: the maximum value to plot, if 0 then takes max of current csd.
%
% see also: get_csdtrials
%
% Corentin Massot
% Cognition and Sensorimotor Integration Lab, Neeraj J. Gandhi
% University of Pittsburgh  
% created 07/07/2016 last modified 07/07/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%get csd
[csd zs]=get_csdtrials(csd_input,index,info);

%plot
if ~isempty(hdlfig)
    subplot(hdlfig);
else
    figure;
end

clim=plot_CSD(csd,zs,1,1,max_plot);
axis ij;%[0 0] on top left corner
axis tight;ax=axis;

% %xtick
% mintime=0-info.aligntime;maxtime=ax(2)-info.aligntime;step=50;%(maxtime-mintime)/5
% vec=[ax(1):step:ax(2)];vectime=[mintime:step:maxtime];
% if ~isempty(find(vec==info.aligntime+0.5)) %+1 because vec starts at 1
%     xtick_vec=vec;
%     xticklabel_vec=vectime;
% else
%     al_ind=min(find(vec>info.aligntime+0.5));
%     xtick_vec=[vec(1:al_ind-1) info.aligntime vec(al_ind:end)];
%     xticklabel_vec=[vectime(1:al_ind-1) 0 vectime(al_ind:end)];
% end
% 
% set(gca,'xtick',xtick_vec,'xticklabel',xticklabel_vec);xlabel('Time (ms)');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %plot events
% %colorlist
% colorlist=get_colorlist;
% 
% %always first plot event at aligntime
% minval=0;maxval=ax(4);
% hl=line([info.aligntime info.aligntime] ,[minval maxval]);
% set(hl,'Color','w','LineStyle','-','Linewidth',1);
% if ~isempty(events),
%     plot_events(events,event_align,info.aligntime,[mintime maxtime minval maxval],hdlfig,0);
% end


if ~isempty(titlestr),
    title(titlestr);
else
    title(['CSD'])
end
