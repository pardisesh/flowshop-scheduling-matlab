%% STEP 3 — VERIFY JOHNSON VS MILP ON SAME DATA
clear; clc;

SCHEMA = "dibris_bike";   
conn = database("BikeDB","","");  assert(isopen(conn));

% Read the same batch
tbl = fetch(conn, "SELECT p_welding, p_oven FROM " + SCHEMA + ...
                    ".CutTube WHERE batch_id=1 ORDER BY tube_id");
p1 = tbl.p_welding;  p2 = tbl.p_oven;%استخراج زمانهای ماشین ها

[jseq, jC] = johnson2machine(p1,p2);
[mseq, mC] = milp_flowshop2(p1,p2);

fprintf('\nJohnson: Cmax = %d, seq = %s\n', jC, mat2str(jseq)); %[output:6f9ab418]
fprintf('MILP   : Cmax = %d, seq = %s\n', mC, mat2str(mseq)); %[output:7e74cce3]
if jC == mC %[output:group:9f202061]
    disp("✅ Same makespan — Johnson is optimal for 2 machines."); %[output:5246dc96]
else
    disp("⚠️ Makespans differ — check instance.");
end %[output:group:9f202061]


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:6f9ab418]
%   data: {"dataType":"text","outputData":{"text":"\nJohnson: Cmax = 50, seq = [3 5 2 1 4]\n","truncated":false}}
%---
%[output:7e74cce3]
%   data: {"dataType":"text","outputData":{"text":"MILP   : Cmax = 50, seq = [5 1 3 2 4]\n","truncated":false}}
%---
%[output:5246dc96]
%   data: {"dataType":"text","outputData":{"text":"✅ Same makespan — Johnson is optimal for 2 machines.\n","truncated":false}}
%---
