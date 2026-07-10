% STEP 1 — CONNECT & INSERT SAMPLE JOBS
clear; clc;

SCHEMA = "dibris_bike";   
conn = database("BikeDB","","");  
assert(isopen(conn),"Connection failed: " + conn.Message);%بررسی اتصال
disp("✅ Connected."); %[output:66aa7b43]

% Small sample for batch 1
batch_id = 1;
T = table( ...
    repmat(batch_id,5,1), ...%چون 5تاکار داریم باید برای هرکدوم بچ جدا داشته باشیم
    [12;  8;  5; 14;  7], ...   % weldingزمان
    [ 6;  9;  7;  4; 10], ...   % oven
    'VariableNames',{'batch_id','p_welding','p_oven'});
exec(conn, "DELETE FROM dbo.CutTube WHERE batch_id = 1");%برای جلوگیری از تکرار

sqlwrite(conn, SCHEMA + ".CutTube", T);%ذخیره داده ها در جدول
disp("✅ Inserted into " + SCHEMA + ".CutTube"); %[output:0f45a03a]

disp(fetch(conn, "SELECT * FROM " + SCHEMA + ... %[output:group:12a6f3c3] %[output:2a5a886d]
    ".CutTube WHERE batch_id=" + batch_id + " ORDER BY tube_id")); %[output:group:12a6f3c3] %[output:2a5a886d]
%داده هارو از sql میخونه و نمایش میده


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":28.7}
%---
%[output:66aa7b43]
%   data: {"dataType":"text","outputData":{"text":"✅ Connected.\n","truncated":false}}
%---
%[output:0f45a03a]
%   data: {"dataType":"text","outputData":{"text":"✅ Inserted into dibris_bike.CutTube\n","truncated":false}}
%---
%[output:2a5a886d]
%   data: {"dataType":"text","outputData":{"text":"    <strong>tube_id<\/strong>    <strong>batch_id<\/strong>    <strong>p_welding<\/strong>    <strong>p_oven<\/strong>\n    <strong>_______<\/strong>    <strong>________<\/strong>    <strong>_________<\/strong>    <strong>______<\/strong>\n\n       1          1           12           6  \n       2          1            8           9  \n       3          1            5           7  \n       4          1           14           4  \n       5          1            7          10  \n\n","truncated":false}}
%---
