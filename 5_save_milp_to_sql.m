SCHEMA = "dibris_bike";   
batch_id = 1;
conn = database("BikeDB","","");
assert(isopen(conn));

cnt = fetch(conn, "SELECT COUNT(*) AS c FROM " + SCHEMA + ...
                    ".CutTube WHERE batch_id = " + batch_id);%شمارش تعداد jobها
disp(cnt) %[output:4f5e07c6]
%% Save MILP schedule to SQL (header + steps)
clear; clc;
SCHEMA   = "dibris_bike";   
batch_id = 1;

% Connect
conn = database("BikeDB","","");
assert(isopen(conn), "Connection failed: " + conn.Message);

% Read jobs for this batch
sql = "SELECT tube_id, p_welding, p_oven FROM " + SCHEMA + ...
      ".CutTube WHERE batch_id = " + batch_id + " ORDER BY tube_id";
tbl = fetch(conn, sql);


assert(~isempty(tbl), "No rows found for batch_id=" + batch_id + ...
       ". Insert data first or change batch_id.");%اگر داده نبود توقف برنامه
p1 = tbl.p_welding;
p2 = tbl.p_oven;

% اجرای میلپ و پیداکردن بهترین ترتیب
[mseq, mC] = milp_flowshop2(p1, p2);

% Build timing for the MILP sequence (same machine logic as Johnson)
t1 = 0; t2 = 0; n = numel(mseq);
sched = zeros(n,5);  % [job s1 f1 s2 f2]
for k = 1:n
    j  = mseq(k);
    s1 = t1; f1 = s1 + p1(j); t1 = f1;
    s2 = max(t2, f1); f2 = s2 + p2(j); t2 = f2;%و زمان پایان شرط شروع
    sched(k,:) = [j s1 f1 s2 f2];
end
makespan = t2;

% Insert header and get schedule_id
Q = "INSERT INTO " + SCHEMA + ...
    ".ScheduleRun (batch_id, algo, makespan) " + ...
    "OUTPUT INSERTED.schedule_id VALUES (" + batch_id + ", 'MILP', " + makespan + ");";
schedule_id = fetch(conn, Q).schedule_id(1);

% Insert steps
Steps = table( ...
    repmat(schedule_id,n,1), (1:n).', tbl.tube_id(mseq), ...
    sched(:,2), sched(:,3), sched(:,4), sched(:,5), ...
    'VariableNames', {'schedule_id','seq_pos','tube_id','s1','f1','s2','f2'});

sqlwrite(conn, SCHEMA + ".ScheduleStep", Steps);

disp("Saved MILP schedule_id = " + schedule_id + " (Cmax = " + makespan + ")"); %[output:9300ba67]


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":27.4}
%---
%[output:4f5e07c6]
%   data: {"dataType":"text","outputData":{"text":"    <strong>c<\/strong> \n    <strong>__<\/strong>\n\n    20\n\n","truncated":false}}
%---
%[output:9300ba67]
%   data: {"dataType":"text","outputData":{"text":"Saved MILP schedule_id = 11 (Cmax = 188)\n","truncated":false}}
%---
