%% 2_run_sa.m — load data, run SA solver, plot routes
clear; clc;

assert(isfile('vrp_data.mat'), 'vrp_data.mat not found. Run 1_load_benchmark.m first.');
S = load('vrp_data.mat');          % load safely into struct
coords = S.coords; demand = S.demand; vehicleCap = S.vehicleCap;

% basic checks
assert(size(coords,2)==2, 'coords must be (n+1)x2 with the depot in row 1.');
assert(numel(demand) == size(coords,1)-1, 'demand length must be nCustomers.');
assert(isscalar(vehicleCap) && vehicleCap>0, 'vehicleCap must be positive.');

[bestRoutes,bestDist] = vrp_sa(coords, demand, vehicleCap); %[output:9336455b]
fprintf('Best total distance = %.2f\n', bestDist);

% plot
figure; hold on; axis equal
plot(coords(1,1),coords(1,2),'ks','MarkerFaceColor','k','MarkerSize',10)  % depot
colors = lines(numel(bestRoutes));
for r = 1:numel(bestRoutes)
    rt = [1 bestRoutes{r} 1];
    plot(coords(rt,1),coords(rt,2),'-o','Color',colors(r,:))
end
title(sprintf('Best Distance = %.2f', bestDist));


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:9336455b]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"Unrecognized function or variable 'vrp_sa'."}}
%---
