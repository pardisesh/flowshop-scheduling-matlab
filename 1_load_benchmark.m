%% 1_load_benchmark.m — create/save a simple VRP instance
clear; clc; rng(1);

nCustomers = 15;                % number of customers (exclude depot)
coords = rand(nCustomers+1,2)*100;   % row 1 = depot, rows 2..n+1 = customers
demand = randi([1 10], nCustomers,1);
vehicleCap = 30;                % capacity of one vehicle (same for all)

save('vrp_data.mat','coords','demand','vehicleCap');
disp('✅ Saved vrp_data.mat'); %[output:3897e93b]


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:3897e93b]
%   data: {"dataType":"text","outputData":{"text":"✅ Saved vrp_data.mat\n","truncated":false}}
%---
