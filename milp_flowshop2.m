function [seq, Cmax] = milp_flowshop2(p1,p2)

n = numel(p1);%تعداد کارها
x    = optimvar('x',n,n,'Type','integer','LowerBound',0,'UpperBound',1);
C1   = optimvar('C1',n,1,'LowerBound',0);%زمان اتمام در ماشین 1و2
C2   = optimvar('C2',n,1,'LowerBound',0);
Cmax = optimvar('Cmax',1,1,'LowerBound',0);%زمان کل

prob = optimproblem('Objective',Cmax);%تعریف مسئله و تابع هدف
prob.Constraints.row = sum(x,2) == 1;   % هر کار فقط یکبار استفاده شود
prob.Constraints.col = sum(x,1) == 1;   % each position one job
prob.constrains.firstjob=s
% Completion times on M1
prob.Constraints.c1_1 = C1(1) == sum(x(:,1).*p1);%زمان اتمام اولین کار
for k = 2:n
    prob.Constraints.("c1_"+k) = C1(k) >= C1(k-1) + sum(x(:,k).*p1);%ماشین 1 همزمان دوکار اتجام نمیده
end

% Completion times on M2 (no overlap & order preserved)
prob.Constraints.c2_1 = C2(1) >= C1(1) + sum(x(:,1).*p2);
for k = 2:n
    prob.Constraints.("c2_"+k+"_A") = C2(k) >= C1(k) + sum(x(:,k).*p2);%job باید از ماشین 1 آمده باشد
    prob.Constraints.("c2_"+k+"_B") = C2(k) >= C2(k-1) + sum(x(:,k).*p2);%ماشین 2 باید آزاد باشد
end

prob.Constraints.cmax = Cmax >= C2(n);

opts = optimoptions('intlinprog','Display','off');
sol  = solve(prob,'Options',opts,'Solver','intlinprog');

[~,pos] = max(round(sol.x),[],1);  % پیدا کردن ترتیب
seq  = pos;
Cmax = round(sol.Cmax);
end


%[appendix]{"version":"1.0"}
%---
