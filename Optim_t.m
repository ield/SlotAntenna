clear all;
close all;
path = 'Plots/';
t = [1:20]*.05;

maxDir = zeros(1, length(t));
sll = zeros(1, length(t));
cpxp = zeros(1, length(t));

for ii = 1:length(t)
    fprintf('Done %i', ii);
   [maxDir(ii), sll(ii), cpxp(ii)] = optimizeT(t(ii)); 
end

figure('Color',[1 1 1]);
set(gcf, 'DefaultAxesFontSize',10)
plot(t, maxDir); hold on;
plot(t, sll); hold on;
plot(t, cpxp); hold on;

xlabel('Upper plate thickness (mm)');
ylabel('dB');
legend('Max Dir', 'SLL', 'CPXP', 'Location', 'southwest');
saveas(gca, [path, 'optim_t'],'epsc');
saveas(gca, [path, 'optim_t'],'png');
