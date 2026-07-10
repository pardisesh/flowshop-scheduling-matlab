%% STEP 4 — RANDOM INSTANCES: COMPARE MAKESPANS & RUNTIMES
clear; clc; 
rng(1);%ثابت کردن اعداد تصادفی
%reproducibilityبرای اینکه هر بار اجرا، نتایج یکسان باشد
Ns = [5 10 20 40];   %برنامه 4 بار اجرا میشه
results = table('Size',[0 5], 'VariableTypes',{'double','double','double','double','double'}, ...
                'VariableNames',{'n','CJ','tJ','CM','tM'});

for n = Ns
    p1 = randi([1 30], n,1);
    p2 = randi([1 30], n,1);
%اجرای Johnson + اندازه‌گیری زمان
    t = tic; [~, CJ] = johnson2machine(p1,p2); tJ = toc(t);
    t = tic; [~, CM] = milp_flowshop2(p1,p2);   tM = toc(t);

    results = [results; {n, CJ, tJ, CM, tM}]; 
end

disp(results); %[output:9c53b283]
if ~isfolder("results"), mkdir results; end
writetable(results, "results/comparison_results.csv");
disp("✅ Saved CSV to results/comparison_results.csv"); %[output:91d912b0]


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":22.2}
%---
%[output:9c53b283]
%   data: {"dataType":"text","outputData":{"text":"    <strong>n<\/strong>     <strong>CJ<\/strong>        <strong>tJ<\/strong>        <strong>CM<\/strong>       <strong>tM<\/strong>   \n    <strong>__<\/strong>    <strong>___<\/strong>    <strong>_________<\/strong>    <strong>___<\/strong>    <strong>_______<\/strong>\n\n     5     54    0.0036271     54    0.21889\n    10    179     0.002453    179     0.1573\n    20    318    0.0017083    318    0.55755\n    40    705    0.0006289    705     1.0847\n\n","truncated":false}}
%---
%[output:91d912b0]
%   data: {"dataType":"text","outputData":{"text":"✅ Saved CSV to results\/comparison_results.csv\n","truncated":false}}
%---
