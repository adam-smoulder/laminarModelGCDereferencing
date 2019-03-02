%% Estimate model order for dereferenced models
%  load result from modelDereferencing before running!

%fileToUse = 'Model_07-Sep-20181427.mat';
%load(fileToUse)

icregmode = 'OLS';
momax = 10;

%% Model order estimation for each
%  Estimates the VAR model order of the data for analysis

[AIC_NN,~,moAIC_NN,~] = tsdata_to_infocrit(X_NN,momax,icregmode);
fprintf('\nNN: best model order (AIC) = %d\n',moAIC_NN);

[AIC_Q1,~,moAIC_Q1,~] = tsdata_to_infocrit(X_Q1,momax,icregmode);
fprintf('\nQ1: best model order (AIC) = %d\n',moAIC_Q1);

[AIC_bip,~,moAIC_bip,~] = tsdata_to_infocrit(X_bip,momax,icregmode);
fprintf('\nbip: best model order (AIC) = %d\n',moAIC_bip);

[AIC_csd,~,moAIC_csd,~] = tsdata_to_infocrit(X_csd,momax,icregmode);
fprintf('\ncsd: best model order (AIC) = %d\n',moAIC_csd);

[AIC_car,~,moAIC_car,~] = tsdata_to_infocrit(X_car,momax,icregmode);
fprintf('\ncar: best model order (AIC) = %d\n',moAIC_car);

tag = [{'k--'}; {'r-'}; {'b-'}; {'m-'}; {'g-'};];

% Plot information criteria.
figure
order = 1:momax;
subplot(5,1,1)
hold on
title('AIC No Noise');
plot(order,AIC_NN',tag{1},'LineWidth',3)
subplot(5,1,2)
hold on
title('AIC Q');
plot(order,AIC_Q1',tag{2},'LineWidth',2)
subplot(5,1,3)
hold on
title('AIC bip');
plot(order,AIC_bip',tag{3},'LineWidth',2)
subplot(5,1,4)
hold on
title('AIC csd');
plot(order,AIC_csd',tag{4},'LineWidth',2)
subplot(5,1,5)
hold on
title('AIC car');
plot(order,AIC_car',tag{5},'LineWidth',2)
hold off



save(['DerefModel_' thedate num2str(time(4)) num2str(time(5)) num2str(round(time(6)))])
