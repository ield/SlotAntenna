clear all;
close all;
path = 'Plots/';


fmin = 7.25e9;
leffmax = 3e8/fmin/4*1000;
fmax = 8.3e9;
leffmin = 3e8/fmax/2*1000;
h = linspace(leffmin, leffmax, 10); %From lambda/4 to lambda/2
maxDir = zeros(1, length(h));
sll = zeros(1, length(h));
error = zeros(1, length(h));


parfor ii = 1:length(h)
   [maxDir(ii), sll(ii), error(ii)] = optimizeH(h(ii)); 
end

figure('Color',[1 1 1]);
set(gcf, 'DefaultAxesFontSize',10)
plot(h, maxDir); hold on;
plot(h, sll); hold on;
plot(h, error); hold on;

xlabel('Substrate thickness (mm)');
ylabel('dB');
legend('Max Dir', 'SLL', 'error', 'Location', 'southwest');
saveas(gca, [path, 'optim_h'],'epsc');
saveas(gca, [path, 'optim_h'],'png');

%% Once it is known the substrate value that gives the best results it is studied that results for 8, 9 and 10 turns

indexMinError = find(error == min(error), 1);
h_subs = h(indexMinError);
% h_subs = 20;

fprintf('The substrate chosen is %f\n', h_subs);

parfor Nturns = 8:10
    for txrx = 1:2
       for fsel = 1:2
           optimizeAll(h_subs, txrx, fsel, Nturns);
       end
    end
end