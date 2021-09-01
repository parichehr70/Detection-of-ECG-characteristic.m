clear all;
clc;
close all;

sig=load('data.mat');
ecg=sig.ecgn;
l_s = length(ecg);
x = (1:size(ecg, 2)) * 0.002;
figure;plot(x', ecg'); axis tight;title('original ecg signal');

%% normalization
ecgn=ecg./max(ecg);
%figure;plot(x',ecgn); axis tight; title('original ecg signal');

%% perform decomposition
[C,L] = wavedec(ecgn,8,'db6');
D1 = wrcoef('d',C,L,'db6',1); 
D2 = wrcoef('d',C,L,'db6',2); 
D3 = wrcoef('d',C,L,'db6',3);
D4 = wrcoef('d',C,L,'db6',4);
D5 = wrcoef('d',C,L,'db6',5);
D6 = wrcoef('d',C,L,'db6',6);
D7 = wrcoef('d',C,L,'db6',7);
D8 = wrcoef('d',C,L,'db6',8);

subplot(8,1,1); plot(x',D1');title('Detail D1');
subplot(8,1,2); plot(x',D2');title('Detail D2');
subplot(8,1,3); plot(x',D3');title('Detail D3');
subplot(8,1,4); plot(x',D4');title('Detail D4');
subplot(8,1,5); plot(x',D5');title('Detail D5');
subplot(8,1,6); plot(x',D6');title('Detail D6');
subplot(8,1,7); plot(x',D7');title('Detail D7');
subplot(8,1,8); plot(x',D8');title('Detail D8');

%% feature extraction
e1=D2+D3+D4;
figure;subplot(2,1,1);plot(x',ecgn');axis tight; title('original ecg signal');ylabel('Amplitude(mV)');
subplot(2,1,2);plot(x',e1');axis tight; title('plot of e1');xlabel('Time(s)');ylabel('Amplitude(mV)');

e2=(D3.*(D2+D4))/256;
R=e1.*e2;
figure;subplot(2,1,1);plot(x',ecgn');axis tight; title('original ecg signal');
subplot(2,1,2);plot(x',R');axis tight; title('plot of modulus of e1*e2');

% R finding
Rp=[];
double p;
for j=1:374:2619
p=max(R(j:j+374));
Rp=[Rp p];
end

n=[];
for k=1:length(R)
    for j=1:length(Rp)
        if(R(k)==Rp(j))
            n=[n k];
        end
    end
end
R1=[];
for i=1:length(ecgn)
    for j=1:length(n)
    if i==n(j)
        R1=[R1 ecgn(i)];
    end
    end
end
n1=n.*0.002;
figure;plot(x',ecgn');hold on;plot(n1',R1','r*');axis tight;title('R peak')

% Q&S finding
e3=D2+D3+D4+D5;
for k=3:length(ecgn)-2;
    Decg(k)=(-e3(k+2)+(8*e3(k+1))-(8*e3(k-1))+e3(k-2))/12;
end

figure;subplot(2,1,1);plot(Decg);hold on;plot(n,Decg(n),'r*');
subplot(2,1,2);plot(e3);hold on;plot(n,e3(n),'r*');



QRS_onset=[];
QRS_offset=[];
on=[];
off=[];
for j=n
for k=j:j+50;
    
    if ( ( Decg(k) < 0 ) && (Decg(k+1) > 0) && (Decg(k-1) < 0) )
        off=[off k];
    end
end
        
        [r2,c2,v2]=find(off,1,'first');
        QRS_offset=[QRS_offset v2];
        off=[];
end

for j=n
for k=j-50:j;
    
    if ( ( Decg(k) < 0 ) && (Decg(k+1) > 0) && (Decg(k-1) < 0) )
        on=[on k];
    end
end
        
        [r1,c1,v1]=find(on,1,'last');
        QRS_onset=[QRS_onset v1];
        on=[];
end
S1=QRS_onset.*0.002;
S2=QRS_offset.*0.002;
figure;plot(x',ecgn');hold on;plot(S1',ecgn(QRS_onset),'r*');hold on;plot(S2',ecgn(QRS_offset),'r*');hold on;plot(n1',R1','r*');title('QRS characteristic points');axis tight;xlabel('Time(s)');ylabel('Amplitude(mV)');