function [seq, makespan, sched] = johnson2machine(p1, p2)
% Johnson's rule for a 2-machine flow shop (M1 -> M2)
%بررسی ورودی ها
if nargin < 2  
    error('Usage: [seq,makespan,sched] = johnson2machine(p1,p2)');%اگر ورودی ناقص باشه
end
p1 = p1(:); p2 = p2(:); % ستونی‌سازی
%برای جلوگیری از ورود داده‌های نامعتبر.
assert(numel(p1)==numel(p2),'p1 and p2 must have same length');
assert(all(isfinite(p1)) && all(isfinite(p2)),'times must be finite numbers');
assert(all(p1>=0) && all(p2>=0),'processing times must be nonnegative');
n = numel(p1);
if n==0
    seq=[]; makespan=0; sched=zeros(0,5); return;
end

n = numel(p1);
A = [p1(:) p2(:) (1:n)'];  % [p1 p2 job]


L = []; R = [];%Lاول و R اخریا
while ~isempty(A)
    [~, idx] = min(A(:,1:2), [], 'all', 'linear');%پیدا کردن کمترین زمان
    [row, col] = ind2sub([size(A,1) 2], idx);%کدوم کار روی کدوم ماشین
    if col == 1, L(end+1) = A(row,3); else, R = [A(row,3) R]; end 
    A(row,:) = [];%جاب حذف میشه
end
seq = [L R];

% build start/finish times
t1 = 0; t2 = 0;
sched = zeros(n,5); % [job s1 f1 s2 f2]
for k = 1:n
    j  = seq(k);
    s1 = t1; f1 = s1 + p1(j); t1 = f1;
    s2 = max(t2, f1); f2 = s2 + p2(j); t2 = f2;%شروع روی ماشین 2=زمان ازاد شدن ماشین2و زمان اماده شدن کار
    sched(k,:) = [j s1 f1 s2 f2];
end
makespan = t2;
end


%[appendix]{"version":"1.0"}
%---
