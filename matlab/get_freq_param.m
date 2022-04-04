function [totalP,VLF,LFnorm,HFnorm,ratioLtoH] = get_freq_param(freq_axis,HRV_psd)
% Frequency Domain Parameters
startpoint=find(freq_axis>=0,1);
vlf_end=find(freq_axis<=0.15,1,'last');

lf_start=find(freq_axis>0.15,1);
lf_end=find(freq_axis<=0.4,1,'last');

hf_start=find(freq_axis>0.4,1);
endpoint=find(freq_axis<=1,1,'last');

% Total HRV Positive frequency range
totalP=trapz(freq_axis(1,startpoint:endpoint),HRV_psd(1,startpoint:endpoint));

% VLF - HRV from 0.00 to 0.04
VLF=trapz(freq_axis(1,startpoint:vlf_end),HRV_psd(1,startpoint:vlf_end));

% LF - HRV from 0.04 to 0.15 Hz (normalize)
LF=trapz(freq_axis(1,lf_start:lf_end),HRV_psd(1,lf_start:lf_end));
LFnorm=LF/(totalP-VLF)*100;

% HF - HRV from 0.15 to 0.40 Hz (normalize)
HF=trapz(freq_axis(1,hf_start:endpoint),HRV_psd(1,hf_start:endpoint));
HFnorm=HF/(totalP-VLF)*100;

% Ratio of LF to HF
ratioLtoH=LFnorm/HFnorm;
end

