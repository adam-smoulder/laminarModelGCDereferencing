function [CSD_cs,zs]=compute_iCSD(csd_input,el_pos,plotcsd)

% hObject    handle to run_this (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Corentin University of Pittsburgh 10/13/15

%set path to CSD_plotter toolbox
%addpath(genpath('C:\Users\massotc@upmc.edu\Work\NeuroPITT\Analysis\Toolboxes\CSDplotter-0.1.1'))
%projectRoot = pwd;
%addpath(genpath(projectRoot)); % adds all needed scripts/functions to file path


% filter parameters:
gauss_sigma = 0.1*1e-3; % mm -> m The gaussian filter width cannot be negative.
filter_range = 5*gauss_sigma; % numeric filter must be finite in extent

% electrical parameters:
cond = 0.3; %Ex. cond. has to be a positive number
cond_top = 0.3;

% size, potential (m1 has to equal number of electrode contacts)
[m1,m2] = size(csd_input);

% geometrical parameters:
diam = 0.5*1e-3; %diameter in [m] Diameter has to be a positive number.

%electrode positions
%el_pos = [0.1:0.15:2.35]*1e-3;
%el_pos = [0.1:0.15:2.05,2.35]/1000;

if cond_top~=cond & (el_pos~=abs(el_pos) | length(el_pos)~=length(nonzeros(el_pos)))
    errordlg('Electrode contact positions must be positive when top cond. is different from ex. cond.')
    return;
end;

if m1~=length(el_pos)
    errordlg(['Number of electrode contacts has to equal number of rows in potential matrix. Currently there are ',...
        num2str(length(el_pos)),' electrodes contacts, while the potential matrix has ',num2str(m1),' rows.']) 
    return
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute spline iCSD:
Fcs = F_cubic_spline(el_pos,diam,cond,cond_top);
[zs,CSD_cs] = make_cubic_splines(el_pos,csd_input,Fcs);
%[pos1,my_CSD_spline]=new_CSD_range(zs,CSD_cs,0,2.4e-3);
if gauss_sigma~=0 %filter iCSD
  [zs,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
%  [new_positions,gfiltered_spline_CSD]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
end;
 
% %   plot_CSD_with_axes(new_positions,delta_t,gfiltered_spline_CSD,1)
%   [gpot_pos,gfiltered_spline_CSD_short]=new_CSD_range(new_positions,gfiltered_spline_CSD,zstart_plot,zstop_plot);

%%
if plotcsd
    figure;
    dt=1;
    plot_CSD(CSD_cs,zs,dt,1,0) 
end
