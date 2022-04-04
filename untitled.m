clc; close all; clear all;

%% read data file
subj_det = readtable('SubjectDetails.xls');
filenames = lower(strcat(subj_det.StudyNumber,'.edf'));
id = {'02', '03', '05', '06', '07', '08', '09', '10', '11', '12' ,'13', '14',...
    '15', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28'};
filenames_resp_evt = lower(strcat(subj_det.StudyNumber,'_respevt_c.csv'));

Num_patients = length(id);
%Num_patients = 5;

%% Preallocations for speed
% = deal(cell(1,p));

%% Separation of abdominal table
%header = {'Time' ,'Type','PB_CS','Duration','Desat_Low','Desat_Drop','snore','arousal','BT_Rate','BT_Change'};

% for subj_no = 1:Num_patients
%     resp_table = timetable2table(edfread(cell2mat(filenames(subj_no))));
%     abdo_original = cell2mat(resp_table.abdo);
%     fs = length(resp_table.abdo{1,1});
%     b_low = 1;
%     abdo{1,subj_no}(:) = preprocess(abdo_original,b_low,fs);
%
%     % read respiratory events file to obtain time and duration of apnea
%     % events
%     reading = readtable(char(filenames_resp_evt(subj_no)));
%     time_evt = reading.Time(~isnan(reading.Time));
%     full_time = datevec(time_evt(:,:));
%     full_time(1:3) = 0;
%     evt_mat{1,subj_no} = full_time(:,:);            %Time
%     evt_mat{2,subj_no} = reading.Duration(~isnan(reading.Duration));  %Duration
%     %evt_mat{3,subj_no} = reading.Type;             %Type
%
%     % from SubjectDetails file obtain starting time of the study
%     start_temp = datevec(subj_det.PSGStartTime{subj_no});
%     start_temp(1:3) = 0;
%     start_time(subj_no,:) = start_temp(:,:);
% end
% %%
% filename = 'Abdo_Time_Duration.mat';
% save(filename)

load("Abdo_Time_Duration.mat")

%%
for subj_no = 1:5
    subj_abdo = (abdo{1,subj_no});
    %     stages = zeros(length(abdo{1,subj_no}),1);

    %figure
    for i = 1:length(evt_mat{1,subj_no})
        [event_time_axis(i, :)] = calculate_time_axis(evt_mat{1,subj_no}(i, :),...
            start_time(subj_no,:), evt_mat{2,subj_no}(i,:), fs);
        event_type{i}='APNEA';
        %nexttile,
        %plot(event_time_axis(i, :), abdo{1,subj_no}(event_time_axis(i, :)*fs));
        %title(event_type{i})
    end

    % healthy period extractions

    N = length(evt_mat{1,subj_no});
    time_axis = 0:1/fs:(length(subj_abdo)-1)/fs;
    equal_sep = round(time_axis(end)/(N+1));
    count=0;
    for i = 1:N
        health_start_time(i,1)=equal_sep*i;

        for j = 1:N

            if ((event_time_axis(j,1)<=health_start_time(i,1))&&(health_start_time(i,1)<=(event_time_axis(j,1)+30))...
                    ||(health_start_time(i,1)<=event_time_axis(j,1))&&(event_time_axis(j,1)<=(health_start_time(i,1)+30)))

                health_start_time(i,1) = health_start_time(i,1)+60;
            end

            while length(health_start_time) ~= length(unique(health_start_time))
                %count=count+1;
                health_start_time(i,1)=health_start_time(i,1)+60;
            end
        end
    end
    health_duration=15;

    figure
    for i = 1:N
        health_time_axis(i, :) = health_start_time(i,1) : 1/fs : health_start_time(i,1) + health_duration - 1/fs;
        healthy_type{i}='HEALTY';
        nexttile,
        plot(health_time_axis(i, :),subj_abdo(health_time_axis(i, :)*fs));
        title(healthy_type{i})
    end

    close all;

    % rows = subjects
    % columns = Apnea label | Apnea time | Apnea signal | Healthy label |
    % Healthy time | Healthy signal
    all_event{subj_no,1} = event_type;              % Apnea event type
    all_event{subj_no,2} = event_time_axis;         % Apnea event time
    all_event{subj_no,3} = subj_abdo(event_time_axis*fs);  % Apnea signal
    all_event{subj_no,4} = healthy_type;            % Healthy event type
    all_event{subj_no,5} = health_time_axis;        % Healthy event time
    all_event{subj_no,6} = subj_abdo(health_time_axis*fs); % Healthy signal

    %parameter extraction
    ENGY_hlt=zeros(N,1);
    ENGY_apn=zeros(N,1);
    for i = 1:N
        [magAR_apn(i,1) freqAR_apn(i,1)]=ardata(all_event{subj_no,3}(i,:),fs);
        [magAR_hlt(i,1) freqAR_hlt(i,1)]=ardata(all_event{subj_no,6}(i,:),fs);

        for j=1:length(all_event{subj_no,3}(i,:))
            ENGY_apn(i,1)=ENGY_apn(i,1)+(all_event{subj_no,3}(i,j))^2;
        end

        ENGY_apn(i,1)=ENGY_apn(i,1)/length(all_event{subj_no,3}(i,:));

        for j=1:length(all_event{subj_no,6}(i,:))
            ENGY_hlt(i,1)=ENGY_hlt(i,1)+(all_event{subj_no,6}(i,j))^2;
        end

        ENGY_hlt(i,1)=ENGY_hlt(i,1)/length(all_event{subj_no,6}(i,:));
    end


    % rows = subjects
    % columns = Apnea magnitude | Healthy  magnitude | Apnea frequency |
    % Healthy frequency | Apnea Energy | Healthy Energy

    parameters{subj_no,1} = magAR_apn;      % Apnea magnitude
    parameters{subj_no,2} = magAR_hlt;      % Healthy  magnitude
    parameters{subj_no,3} = freqAR_apn;     % Apnea frequency
    parameters{subj_no,4} = freqAR_hlt;     % Healthy frequency
    parameters{subj_no,5} = ENGY_apn;       % Apnea Energy
    parameters{subj_no,6} = ENGY_hlt;       % Healthy Energy

    % Freq. param
    for i = 1:N
        event_psd{subj_no,i} = abs((fftshift(fft(subj_abdo(event_time_axis(i, :)*fs))).^2)/length(subj_abdo(event_time_axis(i, :)*fs)));
        event_freq_axis{subj_no,i} = -fs/2:fs/(length(event_psd{subj_no,i})):...
            (fs/2-fs/(length(event_psd{subj_no,i})));

        healthy_psd{subj_no,i} = abs((fftshift(fft(subj_abdo(health_time_axis(i, :)*fs))).^2)/length(subj_abdo(health_time_axis(i, :)*fs)));
        healthy_freq_axis{subj_no,i} = -fs/2:fs/(length(healthy_psd{subj_no,i})):...
            (fs/2-fs/(length(healthy_psd{subj_no,i})));

        [healthy_totalP(i,1),healthy_VLF(i,1),healthy_LFnorm(i,1),healthy_HFnorm(i,1),healthy_ratioLtoH(i,1)]...
            = get_freq_param(healthy_freq_axis{subj_no,i},healthy_psd{subj_no,i});

        [event_totalP(i,1),event_VLF(i,1),event_LFnorm(i,1),event_HFnorm(i,1),event_ratioLtoH(i,1)]...
            = get_freq_param(event_freq_axis{subj_no,i},event_psd{subj_no,i});
    end

    subj_no

    clear event_time_axis;
    clear health_time_axis;
    clear event_type;
    clear healthy_type;
end
%%
figure;

nexttile
boxplot([magAR_apn magAR_hlt])
title('Mag')

nexttile
boxplot([freqAR_apn freqAR_hlt])
title('Freq')

nexttile
boxplot([ENGY_apn ENGY_hlt])
title('Energy')

%% time domain
%for subj_no = 1:Num_patients
for subj_no = 1:5
    N = length(evt_mat{1,subj_no});
    for i = 1:N
        [means_apn{subj_no,1}(i,1), stds_apn{subj_no,1}(i,1), ...
            RMS_adj_NN_apn{subj_no,1}(i,1), STD_adj_NN_apn{subj_no,1}(i,1),...
            NN50_apn{subj_no,1}(i,1), pNN50_apn{subj_no,1}(i,1)]...
            = get_time_domain_features(all_event{subj_no,3}(i,:));

        [means_hlt{subj_no,1}(i,1), stds_hlt{subj_no,1}(i,1),...
            RMS_adj_NN_hlt{subj_no,1}(i,1), STD_adj_NN_hlt{subj_no,1}(i,1),...
            NN50_hlt{subj_no,1}(i,1), pNN50_hlt{subj_no,1}(i,1)]...
            = get_time_domain_features(all_event{subj_no,6}(i,:));
    end
    subj_no

    figure;

    nexttile
    boxplot([means_apn{subj_no,1} means_hlt{subj_no,1}]);
    title('mean');

    nexttile
    boxplot([stds_apn{subj_no,1} stds_hlt{subj_no,1}]);
    title('std');

    nexttile
    boxplot([RMS_adj_NN_apn{subj_no,1} RMS_adj_NN_hlt{subj_no,1}]);
    title('RMS')

    nexttile
    boxplot([STD_adj_NN_apn{subj_no,1} STD_adj_NN_hlt{subj_no,1}]);
    title('STD adj')

    nexttile
    boxplot([NN50_apn{subj_no,1} NN50_hlt{subj_no,1}]);
    title('NN50')
end


for subj_no = 1:5
    figure;
    nexttile
    boxplot([event_totalP{subj_no,1} healthy_totalP{subj_no,1}])
    title('Total Power')

    nexttile
    boxplot([event_VLF{subj_no,1} healthy_VLF{subj_no,1}])
    title('VLF')

    nexttile
    boxplot([event_LFnorm{subj_no,1} healthy_LFnorm{subj_no,1}])
    title('LFnorm')

    nexttile
    boxplot([event_HFnorm{subj_no,1} healthy_HFnorm{subj_no,1}])
    title('HFnorm')

    nexttile
    boxplot([event_ratioLtoH healthy_ratioLtoH])
    title('LF/HF')
end


dataset2 = [ENGY_apn means_apn stds_apn  event_LFnorm event_HFnorm event_ratioLtoH...
    ; ENGY_hlt means_hlt stds_hlt healthy_LFnorm healthy_HFnorm healthy_ratioLtoH];

%% Functions
function [event_time_axis] = calculate_time_axis(event_time, start_time, duration, fs)
time_diff = datetime(event_time)-datetime(start_time);
offset_stages = (duration)/5;
if time_diff < 0
    event_start_time = seconds(hours(24) + time_diff);
else
    event_start_time = seconds(time_diff);
end

%     stages((event_start_time-offset_stages)*fs:(event_start_time+duration+offset_stages)*fs) = 1;
event_time_axis = event_start_time+duration/2-15 : 1/fs : event_start_time + duration/2 + 15 - 1/fs;
end



