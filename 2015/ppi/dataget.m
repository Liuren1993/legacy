clc;
clear all;
%%
load('PPIdata1.mat')
output(end) = 0;
data = -output/max(max(abs(output)));
data(data>=0.75) = 0;
dat = data';
[r,c] = size(data);
vecdata = reshape(data',1,r*c);
vecdata = ones(1,r*c) - vecdata;
fid = fopen('ppidata.bin','w')
fwrite(fid,vecdata,'float')
%%
frewind(fid)
fread(fid,'double')

fclose(fid);
