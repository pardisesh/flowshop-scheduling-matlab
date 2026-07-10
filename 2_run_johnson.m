%% STEP 2 — READ FROM SQL -> RUN JOHNSON -> SAVE SCHEDULE -> GANTT
clear; clc;

SCHEMA   = "dibris_bike";  
batch_id = 1;

conn = database("BikeDB","","");  assert(isopen(conn));
disp("✅ Connected to SQL Server"); %[output:49404ba3]

% Read jobs
tbl = fetch(conn, "SELECT tube_id, p_welding, p_oven FROM " + SCHEMA + ...
                    ".CutTube WHERE batch_id=" + batch_id + " ORDER BY tube_id");%از sqlمیاره به متلب
disp("📦 Jobs read from SQL:");  disp(tbl); %[output:4e737c20]

% اجرای جانسون
p1 = tbl.p_welding;  p2 = tbl.p_oven;
[seq, makespan, sched] = johnson2machine(p1, p2);
disp("Sequence:"); disp(seq);  disp("Makespan:"); disp(makespan); %[output:36cf5518]


Qrun = "INSERT INTO " + SCHEMA + ...
       ".ScheduleRun (batch_id, algo, makespan) " + ...%ساخت sql query
       "OUTPUT INSERTED.schedule_id VALUES (" + batch_id + ", 'Johnson', " + makespan + ");";
schedule_id = fetch(conn, Qrun).schedule_id(1);%ذخیره نتیجه در SQL و گرفتن ID
disp("🆕 schedule_id = " + schedule_id); %[output:9ae2f36c]

% (ScheduleStep) in Johnson order
n = numel(seq);
Steps = table( ...%جدول زمانبندی
    repmat(schedule_id,n,1), (1:n).', tbl.tube_id(seq), ...
    sched(:,2),sched(:,3),sched(:,4),sched(:,5), ...
    'VariableNames',{'schedule_id','seq_pos','tube_id','s1','f1','s2','f2'});
sqlwrite(conn, SCHEMA + ".ScheduleStep", Steps);
disp("✅ Saved " + n + " steps to " + SCHEMA + ".ScheduleStep"); %[output:522e49fd]

% رسم نمودار Gant
figure('Name','Johnson Gantt', 'Position',[100 100 1800 600]); clf; hold on %[output:5b431913]
yticks([1 2]); yticklabels({'Welding','Oven'}); xlabel('Time'); ylim([0.5 2.5]) %[output:5b431913]
colors = lines(height(Steps));
for k = 1:height(Steps)
    %M1
    rectangle('Position',[Steps.s1(k), 1-0.35, Steps.f1(k)-Steps.s1(k), 0.7], 'EdgeColor','k'); %[output:5b431913]
    text(Steps.s1(k)+0.2, 1, sprintf('J%d', Steps.tube_id(k)));
    %M2
    rectangle('Position',[Steps.s2(k), 2-0.35, Steps.f2(k)-Steps.s2(k), 0.7], 'EdgeColor','k');
    text(Steps.s2(k)+0.2, 2, sprintf('J%d', Steps.tube_id(k)));
end
title(sprintf('Batch %d — Johnson (Cmax = %d)', batch_id, makespan)); hold off; %[output:5b431913]
if ~isfolder("results"), mkdir results; end
saveas(gcf, "results/johnson_gantt.png"); %[output:5b431913]



%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":27.2}
%---
%[output:49404ba3]
%   data: {"dataType":"text","outputData":{"text":"✅ Connected to SQL Server\n","truncated":false}}
%---
%[output:4e737c20]
%   data: {"dataType":"text","outputData":{"text":"📦 Jobs read from SQL:\n    <strong>tube_id<\/strong>    <strong>p_welding<\/strong>    <strong>p_oven<\/strong>\n    <strong>_______<\/strong>    <strong>_________<\/strong>    <strong>______<\/strong>\n\n       1          12           6  \n       2           8           9  \n       3           5           7  \n       4          14           4  \n       5           7          10  \n\n","truncated":false}}
%---
%[output:36cf5518]
%   data: {"dataType":"text","outputData":{"text":"Sequence:\n     3     5     2     1     4\n\nMakespan:\n    50\n\n","truncated":false}}
%---
%[output:9ae2f36c]
%   data: {"dataType":"text","outputData":{"text":"🆕 schedule_id = 2\n","truncated":false}}
%---
%[output:522e49fd]
%   data: {"dataType":"text","outputData":{"text":"✅ Saved 5 steps to dibris_bike.ScheduleStep\n","truncated":false}}
%---
%[output:5b431913]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAT4AAABqCAYAAAAlUD1lAAAAAXNSR0IArs4c6QAAFydJREFUeF7tXV2oVkUXnv6JLEKU0gNieSChuzRIiU4ckUi6sCRONxrdKOSBg0gUGV6I\/aEigVZKEtiVROWV0k0gCV6U1UVBF4Hd9IcRUUZl1vfx7K+1v\/UuZ8+e2Xv23rP3uzaI73nf2TNrnpl5Zs2ambWumD9\/\/n+MPoqAIqAIjBECVyjxjVFra1UVAUUgQ0CJTzuCIqAIjB0CSnxj1+RaYUVAERgr4nvzzTfN8uXLra3+zTffmKeeesqcO3eukV5x9913m+effz7Le8eOHeajjz4KKqfu+0GFFSQm\/N566y3z6quvlmaZgsylQnokeOmll8yqVavMgQMHzNtvv52\/IfvTr7\/+WqltPURoPQnqPDU1NVIuHyO33Xab2bNnj5mYmMjS8N8effRRMzs7a86cOWOeeeaZ1mX3KVCJj6H05ZdfmieeeMIHtywNOj4IrA0SoEHW5eAaR+Ij8sbApr5B3914443WvuI7MXh3tA4S2pQETm623\/n4we8gxSqTfBvVHUvikx2TZqg\/\/\/zTq6H4bOfbyatqP3JmVeJrY1j8vwzSfHg706DnRMDJsOnVQ9MIUJ9buHDhZVouypbjBd9hNXPdddfl6Z988kmzceNGc+rUqSS1PiU+1pDnz5\/Pl7vUcLyTofOfPHlyRMXnaj4+c\/X\/4sWLeUfgxHfo0CGzZcsWA42Bp5EdmpPehQsXzLXXXmt8ybmJwWHT+OSSiM\/6PnXmaY4fP25mZmayeuLhZEODjX6Tv+NvX1lc5XDcbATgmsAg46ZNm8yuXbuylQDh9dlnn5lly5aNtDfKwXIQ9ZFE6VpCUx3pHd7nbCRj68dUx6K+Z8Oay0h5Sg0PZiRqM8qDj6km+mTVPMeS+Gxg8U5ga3i8A20Ldh50brJtEPG98sorZm5ubuR7\/Eb5fv311\/msiO\/mzZuXi1GkxdHA++CDDww6EAZKSsRXZDOlQbJgwYLSOpO2YFs2Ei5Lly7NSYK3HW8zX1lc5Ui7q43kQga0y6Ys+yCRls22hrREMnwyxDt4YIsr0jKrEF\/ROyQDyciJVn5XdYVTlchC31PiY4gVERA1IqnyH3\/8ca7Z0QxHnYXnwTvDO++8k5EABh51GJkvN5zLhgxdjod2BJ\/0XOMjIobGQhjw5R6+A5GU1ZkmBI4L1RUyYaIh7ahIe+ATVYgsshyJv43kqJ19lrNySbxy5cqcwCXRFdmXbeXJidm1avBpV5mG+i3JJHFasWJFRrYu4itbLleRK+Y7Y0l80i4nByxtVkgjNnUwG\/HZZkHeUDaSC+kcPsQXomHITuRjq+TEh\/dhw5EDlg8a4ChtP7LOXBOmXVOZhuNNcpctvZAuVBZJfDbSqUJ8ronOtmyE7FLrkkTLNUNX21XR+GTfkDbtJUuWeBMfVkY+fSsmqfnkpcT3L0o0qNFJz549m83MpGHwJRsGZx3iQ3G005Uy8dnseVWJz1VnIj4fXORGD97BoAohYZ9yaODYSM6lpRfZ+CTxcRkk8ckJtIho+STnOo0QSny2jTv5nQ1v2V+qbAD6EFasNEp8xhip8eFvGGqpw9qWRLKhXUtddEzSfkIGHm9kH40vVqdAPlQ\/GlRywNPy02epG4v4eP24NnfixIl8CVm21A3Bv8ieZ9vV5QOdtLOdO3eO9COb3YsTn01DlpsZOGdatPHmc6zKp4\/IMmmJTvZlsrnS38izTLN3mXF8ZIqdZiyJrwhEss9t2LDhssObeKfImI6OXrS5QVoJ2btCBl6XxFe0wVN2lgsyy82NusSHYxVYVtseIjrfzY0Q\/IsM9L7n+PgqAgd5y4gPu8H8VACvr8QUNlGu7cY85lRUP1IEbJo3ZC3a0U\/xLJ8S37+9i3cc2bB894wan8+69O6PP\/54WceVGkjIwOuS+FB2mZ0JaXyPkBQt732XujYilsc36soitZIyU0TZzY1Q4sMBaV5PTLTI46GHHjJ0pm7dunWZFslJRm5GxNCOJN4Sa9fNDZQfsvsdQ97QPMaK+ELB0fSKgO0As6JSjoAeYC7HSFMoAskiYLuylqywCQmmV9YSagwVRRGogkCRk4IqeY3DO+qkYBxaWeuoCCgCvUNAbXy9azIVWBFQBOoiMCjiW7RokcGuF851fffdd3Wx0fcVAUVgoAgMivjuuusuc\/DgQbN161bzySefDLTJtFqKgCJQFwElvroI6vuKgCLQOwSU+AKa7K+\/\/jK\/\/\/57wBuatK8IXH\/99eaaa64ZEf+XX35ptTo2GVoVoKCw3377zfz9999RRLnpppui5BOaiRKfJ2L\/\/POP+fnnnzMvs10+uB959dVXm6uuuqpLMSqV3RfZMagvXbpk5s+fn9cTgx0TnyTDSkB4vGSTweO1xpPExIH6Qxfkp8Tn2VWI+HBHsq3ObxPtp59+MjfccEPnBOwJ20gymjigyaT8YEBigEviAxm1NUhtMqSAGRHfzTffXFsc0qDbwpQLrMTn2XxKfJ5AOZIp8fljqMTnj1WVlEp8nqiVEZ\/tdL+86O3jtbdMHJfGZ5OhyGtJF84hXcRnk106SYjpgcSFc6jGV3azA22AJySCXx+JrwwHuv6HExfwVjMojU96yGgzylKTx1lCiU9e2yFvFlDr67jpCSE+KhOEETLoysi36u8hxFcU3ez222+3Rv6qKpPtvZjEV9VzyhCJT3qrGQzxoWKwgVFgbhp46FxNBuumzpsS8UksICOR4bFjx7xi8Yba+OSMSzMsoorFclJZh2B8iY88XEvClhpDHVma1vik26bQmM1DIz6uvZMyNAjiQ8XWr19\/mTbT5uBLifhsA6tt4kN5mzdvNocPHzYpeMD1Jb4iWdvylFJX4+Pa\/d69e7M2CNW6h0R81G6nT5829957b3a5YDBLXZcdg37DVTI5EOV7RbEESIPCUrEoHm3KxEeNj1mujvYbstQlDZCHs4wdkStE66pLfG15\/ahLfByTquaGoRAfrz+51h8M8VHlvvrqK2vUdAzAycnJ3D07pZPaIKUDMeCBG25KC+Lj9h3bUpKI74033oh+XzfUxkedny95YpBOCPFJzCBTl4416xBfLBupD1Er8RWj5DrOYtvcwHcYl7Br40FsjrEjPhDali1bMhLE5wcffNBMT09nn4noEDyb7FFYPtPvCNzCd8Y4SSIACx4iPnwG+R05csSnn3ulqUp8PPMYXmlDiM9WsbbtrlyGOsRni\/rm1XAVEinxxSE+adoZ5K6uz1IXO4uoPEjs6NGjBoGJ8fBALDLSPR1hAGn4Et\/u3buzWSWmh5YYxAf563qmrUt8MWSowCXZK1WJr03Sg5xKfPWJz7ZBNUjiC9ncQEfGILj11lvNu+++mxneSRPhGh+HXxKrS+NrwjsLJ759+\/bl6juip+EpO8NEdYlFfPv37+9MhrrEh4h0tPxx4ddVbFYX8WE14iM7YTRUG9\/rr7\/uxAH1R2xqhB+1PVBotm3bZs6cOdPabRguR9QDzL7HWYqix0sy4\/mFLHWbJr65uTkzMzMzcp6M2zIo2prcyYuxzCSND53GRwY0Nt9MqToQq5Kdbam7fft2p+wgw7IIZzHkKcrDRXxYnbhwJyIfOvE9++yzQTgAj0FqfNTQPgeYXUdc+K4uP6mfksa3evXqzEiLmxi0fOd\/Awsid35DIsaSjYgPxwJ8ZeCHyG0bHk2SiI347rvvvlLZu5TTRXxr1qwplZ3XuepEk\/qu7tq1a4NwGDzxtTWIbOW0eZxFXkezHVCVaWJcueI2vq5kqNrG3Mbnkr0omDmVG+Pqn6sOZTY+H9yHrvHBSUEIDkp8VUeNx3ttEp+HOI0kUe8sjcA6kmkZ8TUvgX2DpY1yy8pQ7yxlCHXwuxJfB6AHFKneWfzBSn2pq26p\/Nuy8ZRtEB984XXpjw\/kAX92XTtErdKYuLUC7FL3xweHozZ\/fPi+Ld9xNhmqYB77HeACUo5BfBcuXMjEawtTjkXUXd3YIIfm1yTxQRZq9FC5NH3\/EICXaz4gSQNrsyZShjbLLioLOCD8Ao53xXi6cqqrxBfQemjsWLEGAorVpB0gANf+V1555UjJ0MLafGwytFl+UVkxcehq9aTEl0JPUhkUAUWgVQSU+FqFWwtTBBSBFBBQ4kuhFVQGRUARaBUBJb5W4dbCFAFFIAUElPhSaAWVQRFQBFpFYHDE9\/jjj2e++OCWSh9FQBGIj0BXO7ExazIo4kMAaHhs1kcRUASaQ6Crs3cxazQo4sPNABxiRsN8+umnMXHKzu\/ByYDe3LgcVrplACeyOHs2xAeHdtEH5s2bN8TqedcJOKC9Y9zc8C60gYSDJD6cuI+91C3zwNxA21izTNFJAQYCJgUMBnnoty1cmi4Ht3ZAfF1cr2q6biH5x3RSEFJu7LRKfJ6IKvEVA6XE59mJBpBMiS\/BRqSlrk3js7mGl\/7EXH7eyojPlj93qsrh4s5JQ2EMjbnBAzmjrBg+AaXMLuIrc8nvitUSik2T6V0aX1kd2wqE3mT9Ke9BER863w8\/\/DASGtIWG8I3QHVR\/A2Ax70vnzx5ciSEZN2GCyE+GaO1LHxhKPFV9bxbhkEI8dlCSTbh2bgq8ZF8NieuZTi0\/Xsd4qMJkHvCblv+WOUNivhkrAsM2hdeeMEsWLDAvPfee3m4R1uAHxugfSA+W1xeGQ6P1y2U+Fzu9et0Ql\/is0W54hMPxTatIwu9G0p8PIgQ8hgy8XGNW4kvRm+Lk0dm48OA37Rpk9m1a5dBsBT8\/cgjj5jvv\/8+M1gjrgQem2ZYh\/gofm6cqhgTovHZyoxJfL7acWjdfYkPketsDxEyxQsJLd+WPoT4uGa9d+9es3nz5mz5TX0shjxN5FFF4yOsT58+bRAjJeZk00QdffIclMbHY91iwGCWwncnTpzICBARlfDs2bPH8PCPPLAQt49JjY\/PekgHG9zx48cNX+oeOnQoyx+DaPHixVlYOmmP4jYzaAkTExNZhHaKbEXENzU1lcnO4+r62mGQB49KRp0hVOOj8i5evJgfgcDnAwcOZOE0qz51iU8u8avKwd8LIT7+XlPmgBh1knmEEh+vGyZ4BIZS4muiZarlme\/qcm0On0EmICYseRH7Fg\/XCiW5cSM1\/w3vodFBdOgA3O5kIz6QIshMhmjkedJvlFYSHzYPcHvjyJEjOSpFxMeXXS5iCiU+my3NZnMLbbY6xFdmxwyVhdIr8b1kVq1aVRhulMaAEl\/VHhb\/vZz4MChvueWWbLlLZAfNhEgQRU9PT+fakFz28uUytMX169dnBMY\/g6CKNjdI48PNC8QuxcPJVO7+2eyIpPHdcccd2ewaovGhPNJMbbaYUOKzNVXMuLo21\/NlWm2M8JZ1l7rjoPFJk4nu6sYnrro55sRHdr3333\/fPPDAA9ny9ty5c\/myF7u+eEBK0jhNQpDGtHDhwpz4NmzYYCYnJ3PCpHexZLZpfDbiAxljGcx\/cxGf73EWG3i23Wyki0F8ROZyiR7SiFU1vqZID7Krxvd\/jc+2qaTEF9LD20mbEx8IaefOnRnZ4TMZm4kQ\/\/jjj8xuRvYp10YHJ6UuNL7t27ebZcuWjdj\/yrQhgtuH+Pbt25ddjeP2xbr5+zY3Ed\/+\/fu9ZOCTVJ3zgy75iPigta9YscIblz7a+GCucbU9cJqdnc1s1LaniXOUvn0nRrpBbW4QIK+99lq2i\/vhhx\/mR1joaAs8Mrz88sv5RoLUuDDwqUNwspP2DVpOYhD6anwg4RAb38aNG839999faHOR9kOqv2spyjW+ubk5MzMzU5o\/8uUbJTEGOhHftm3bnDLArEDlQQOvu6niQ3yYCB577LFCXMgWK\/Hu064uVjyutpd1RF1V44tBuXHzGLmyBnKRjUrLM\/wvjxzwXV2+MSBJkd+QAOngAemFEB\/JsXz5coOyYMO78847rbu66GiQlY5s2I5wcAKmYzWu5SAnvtWrV2cbNj75c3thjMPDRHw4HlEmQ4zyfLobaXxr1641L774ohMXnl+MicBHvhhpaFd3zZo1pbjL8pT4YrRA3Dx6e1cXxMU3WwALP8eHpS5fctgOycora65liLTxyXfr5u\/brNzG55JB\/ibzd13P85WF0nEbHybOMtz7rPHBfuzT9hxDJb7QHtV8+t4QH+06Q5Mr0hRcB5jrQlm2uVE3f9\/31TuLL1Jx06l3lv\/hOUgbX9yuEjc3mjXh8w2PTWNR4ouLuW9u6p3FF6n+p1PiS7ANQXyXLl0yS5cuHTnDF0tURJFHdPsunW2mIIMNT8hlO1sYC\/uu8wG5Q+sfch19MKZg4uqI1AetltJgVxnkF9sJaUviazGKQC8QgBfqvjuc7Y2Nz6dHgPgOHjxotm7d2jvyW7RokVm3bt1ld4x96t11GpW9mxZQ3KvjPkjiwz3d2DE3qkPs9yY68XPPPZfdMVbZ\/TCLkUpxj4FieB6Ee1dKyqCIj8CE5qePIqAIpI0ATFK7d+9uxB5fVvNBER8qC\/LDP30UAUUgbQTgRIQ7EmlT2sERX5vgaVmKgCLQTwSU+PrZbiq1IqAI1EBAia8GePqqIqAI9BMBJb5+tptKrQgoAjUQGAzx8XgcTfmdq4Gz9VWbT0N+NS81321l1wZTlh0NUBbdLXX5qRPZAlmlLLvNcTF36tGF7IMgPpfj09hkFSu\/olirLnf7scqukg91XvKCbXMUkarsVF8un81jSuryc\/KWPhZTll0GM5P9rwvZB0F8HDju2j52+MoqhCHfoQGHu614vvjiizzGiIzFK8N+xig\/Zh48zjJiMPOgUqnLDhxsREhBsVKVH5P8ww8\/nDXj4cOHM4\/oqfcbF5Zdyd574ivSRHh8jpiDvW5eaOglS5ZkV+pkHBG5hGkqNm\/dOtD7nPhWrlyZxcilwZi67LYBl7r8kPnpp5\/OQryC\/IqwTg17W3ycomV7W7IPhvh4vF\/fwOexCKBKPpKwkYecGcuWCFXKjfWOXCr2SXYyM3DXZn2QHxMNnrNnz142yfDQr6n1G+6pHfJz23VXuCvxxWKCwHz6THy22CRddeBA2EeSgwDh3xFxUaCxpkweFPQL0Q9t2nXKsnOcEcwsBdwHQ3zS6J7qUpdGXhHxpb7cKgrI1LdlOmnYhDf+Thl7im8Nu3UZ1m0tF6tOOly+rnDvPfGRkRpxf3nMX770rdpATb5nIz65REnNwO4KDpS67La25LYn\/I7wqkePHs02DFLCXh4j4nXB0S1EdktVdhvuHNuucB8E8fXxOIuN+IjE8T9ii\/BdxyZJ2DdvuWSR73VxLMFXdoltH4\/jUF1tGl2q2Kd6DGoQxEedGqEn8fThAHMR8XVxmNOHPIq0Dm6oTlV2aV6YmJjIvpJxW1KX30V8KcsuDzCngPtgiM9n8GoaRUARUASAgBKf9gNFQBEYOwSU+MauybXCioAioMSnfUARUATGDgElvrFr8m4qzL3n2CSAwfvbb781ixcvzg4U46CrPopAUwgo8TWFrOZbiEDqB2y16YaPgBLf8Ns4uRoq8SXXJGMnkBLf2DV59xUuIj6bt5fPP\/\/c3HPPPZnQdGYQB9bpzCZ3aCnPi6XmyLV75FUCQkCJT\/tC6wj4Et\/s7Kw5f\/58ZvPDAzdeOHxMB9SRD9IcO3Ysu7YFf4Bw94Wri3hApIixvGPHjux3fRQBJT7tA50hEEJ8IDVyKMs1Qmx+cJ96qMz09PTIxkjR7ZjOKq4FJ4OAanzJNMX4COJLfNxbCmlwk5OTOblx4oNz16mpKSuIp06dyrXA8UFZa+pCQIlP+0frCDRBfCBB8q2nR2Fab9LeFajE17sm67\/ATRAfND615\/W\/b7RVAyW+tpDWcnIEmiA+2tzAQWi49MLDNz9SDDylXaI7BJT4usN+bEtugvhAbDbXWX1wUTa2HaHDiivxdQi+Fq0IKALdIKDE1w3uWqoioAh0iIASX4fga9GKgCLQDQL\/BZLAmxDnn434AAAAAElFTkSuQmCC","height":85,"width":254}}
%---
