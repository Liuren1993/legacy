function [ y , ny ] = conv_m( x , nx , h , nh )
% Modifiied convolution routine for signal processing
%   [y,ny]=conv_m(x,nx,h,nh);
%   [y,ny]=convolution result
%   [x,nx]=first signal
%   [h,nh]=second signal
%
ny_begin = nx(1) + nh(1);
ny_end = nx(length(x)) + nh(length(h));
ny = [ny_begin:ny_end];
y = conv(x,h);


end

