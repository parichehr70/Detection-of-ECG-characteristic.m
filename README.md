#Detection-of-ECG-characteristic
clear all;
clc;
close all;

sig=load('data.mat');
ecg=sig.ecgn;
l_s = length(ecg);
x = (1:size(ecg, 2)) * 0.002;
figure;plot(x', ecg'); axis tight;title('original ecg signal');
