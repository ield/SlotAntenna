h = 1:10;

maxDir = zeros(1, length(h));
sll = zeros(1, length(h));
cpxp = zeros(1, length(h));

for ii = 1:length(h)
   [maxDir(ii), sll(ii), cpxp(ii)] = optimizeH(h(ii)); 
end

figure;
plot(h, maxDir); hold on;
plot(h, sll); hold on;
plot(h, cpxp); hold on;

xlabel('substrate height (mm)');
ylabel('dB');
legend('Max Dir', 'SLL', 'CPXP');
