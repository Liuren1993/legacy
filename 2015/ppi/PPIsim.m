clc
clear all
%% Basic Parameters
int_pulsenum = 10;                  % Number of pulses to integrate

pd = 0.9;                           % Probability of detection
pfa = 1e-6;                         % Probability of false alarm
maxRange = 30e3;  %(3km)            % Maximum unambiguous range (m)
range_res = 15;                     % Range resolution (m)
targetRCS = 1;                      % Target radar cross section (m^2)
fc = 10e9;                          % Operating frequency (Hz)
c = physconst('LightSpeed');        % Wave propagation speed (m/s)
lambda = c/fc;                      % Wavelength (m)
% calculated parameters
snr_min = albersheim(pd, pfa, int_pulsenum);

% Waveform %
pulseBandwidth = c/(2*range_res);             % Pulse bandwidth (Hz)
pulseWidth = 1/pulseBandwidth;                % Pulse width
prf = c/(2*maxRange);                         % Pulse repetition frequency
fs = 2*pulseBandwidth;                        % Sampling rate

% Transmitter & Receiver %
transmitterGain = 20;                         % Transmitter gain (dB)
% requiredPeakPower is the peak transmit power required for a radar operating at a
% wavelength of lambda meters to achieve the specified signal-to-noise ratio
% SNR in decibels for a target at a rangeof tgtrng meters. The target has a
% nonfluctuatingradar cross section (RCS) of 1 square meter.
requiredPeakPower = radareqpow(lambda,maxRange,snr_min,pulseWidth,'RCS',targetRCS,'Gain',transmitterGain);

% monostatic case
receiverGain = 20;                            % Receiver gain (dB)
noiseBandwidth = pulseBandwidth;              % Noise bandwidth (Hz)
noiseFigure = 0;                              % Noise figure (dB)

%% Antenna %%
% specify the element of antenna array
antennaElement = phased.IsotropicAntennaElement('FrequencyRange',[5e9 15e9]);
% create 100-by-100 uniform rectangular antenna array
antenna = phased.URA('Element',antennaElement, 'Size',[100 100],'ElementSpacing',[lambda/2, lambda/2]);
antenna.Element.BackBaffled = true;  % Suppress Backward Radiation
%plotResponse(antenna,fc,physconst('LightSpeed'), 'RespCut','3D','Format','Polar');
% rerrange peak power
antennaGain = phased.ArrayGain('SensorArray',antenna,'PropagationSpeed',c);
% calculate atenna gain at (0,0) -- main lobe gain
mainLobeGain = step(antennaGain,fc,[0;0]);
% calculate 3dB-beamwidth
theta3dB = radtodeg(sqrt(4*pi/db2pow(mainLobeGain)))
% In this case, 3dB-beamwidth is approximately 2 degree: that is 2.0311, so
% we can use 2 degree as a scan step interval here.
scanstep = floor(theta3dB);
% specify antenna platform
antennaPlatform = phased.Platform( 'InitialPosition',[0; 0; 0],'Velocity',[0; 0; 0]);
%% Waveform %%
waveform = phased.RectangularWaveform('PulseWidth',1/pulseBandwidth, 'PRF',prf,'SampleRate',fs);

%% Radiator & Collector %%
radiator = phased.Radiator('Sensor',antenna,'OperatingFrequency',fc);
radiator.WeightsInputPort = true;
collector = phased.Collector('Sensor',antenna,'OperatingFrequency',fc);

%% Transmitter & Receiver %%
transmitter = phased.Transmitter('Gain',transmitterGain,'PeakPower',requiredPeakPower,'InUseOutputPort',true);
receiver = phased.ReceiverPreamp('Gain',receiverGain,'NoiseBandwidth',noiseBandwidth,'NoiseFigure',noiseFigure,'SampleRate',fs, 'EnableInputPort',true);

%% Data Parameters %%
% Scan Range 360 degree
initialAz = -180;                       % Initial azimuth
endAz = 180;                            % End azimuth
scanGrid = initialAz:scanstep:endAz;
numScans = length(scanGrid);            % The total number of scans, every scan covers scanstep(2) degree
pulsenum = int_pulsenum*numScans;       % The total number of pulses
revisitTime = pulsenum/prf;             % Revisit time (s)
SimTime = 1;                            % Simulation time (s)
Frame = floor(SimTime/revisitTime)      % Frame number
%% Target Parameters
%30 degree
target{1} = phased.RadarTarget('MeanRCS',1,...
    'OperatingFrequency',fc);
tgtplatform{1} = phased.Platform(...
    'InitialPosition',[10e3; 10e3*tan(pi/6); 0],...
    'Velocity',[5e3; 5e3; 0]);
%30 degree
target{2} = phased.RadarTarget('MeanRCS',1.5,...
    'OperatingFrequency',fc);
tgtplatform{2} = phased.Platform(...
    'InitialPosition',[15e3; 15e3*tan(pi/6); 0],...
    'Velocity',[5e3; 5e3; 0]);
%60 degree
% target{3} = phased.RadarTarget('MeanRCS',1.3,...
%     'OperatingFrequency',fc);
% tgtplatform{3} = phased.Platform(...
%     'InitialPosition',[15e3; 0; 0],...
%     'Velocity',[90; 120; 0]);
tgtNum = length(target);
% Range & Angel & RadialSpeed
tgtrange = zeros(1,tgtNum); % Range
tgtang = zeros(2,tgtNum);   % [Azu,Azu,Azu,...;Ele,Ele,Ele,...]
tgtspeed = zeros(1,tgtNum); % Radial Speed
for k = 1:tgtNum
    [tgtrange(k),tgtang(:,k)]=rangeangle(tgtplatform{k}.InitialPosition,...
        antennaPlatform.InitialPosition);
    tgtspeed(k)=radialspeed(tgtplatform{k}.InitialPosition,...
        tgtplatform{k}.Velocity,antennaPlatform.InitialPosition);
end

%% Pulse Synthesis %%
% Create the steering vector for transmit beamforming
steering = phased.SteeringVector('SensorArray',antenna,'PropagationSpeed',c);
% Create the receiving beamformer
beamformer = phased.PhaseShiftBeamformer('SensorArray',antenna,...
    'OperatingFrequency',fc,'PropagationSpeed',c,...
    'DirectionSource','Input port');
% Define propagation channel for each target
for n = 1:tgtNum
    htargetchannel{n} = phased.FreeSpace(...
        'SampleRate',fs,...
        'TwoWayPropagation',true,...
        'OperatingFrequency',fc);
end
% Dynamic Simulation
FastTimeGrid = unigrid(0, 1/fs, 1/prf, '[)');
signalmatrix = zeros(numel(FastTimeGrid),pulsenum);            % Pre-allocate
FixedPulse = zeros(numel(FastTimeGrid),int_pulsenum);          % Pre-allocate
for y = 1:Frame
    for m = 1:pulsenum    % Fast-Time Processing
        signal = step(waveform);                               % Generate pulse
        [signal,tranStatus] = step(transmitter,signal);        % Transmit pulse
        [transPos,transVel] = step(antennaPlatform,1/prf);     % Update radar position
        % Calculate the steering vector
        scanCount = floor((m-1)/int_pulsenum) + 1;
        sv = step(steering,fc,scanGrid(scanCount));
        weight = conj(sv);
        % Get received signal
        receivedSignal = zeros(length(signal),tgtNum);
        % For Each Target
        for n = 1:tgtNum
            % Update target position
            [tgtPos,tgtVel] = step(tgtplatform{n},1/prf);
            % Calculate range&angle
            [tgtrange(n),tgtang(:,n)] = rangeangle(tgtPos,transPos);
            % Radiate toward target
            tsig = step(radiator,signal,tgtang(:,n),weight);
            % Propagate pulse
            tsig = step(htargetchannel{n},tsig,transPos,tgtPos,transVel,tgtVel);
            % Reflect off target
            receivedSignal(:,n) = step(target{n},tsig);
            tgtspeed(n)=radialspeed(tgtPos,tgtVel,transPos,transVel);
        end
        receivedSignal = step(collector,receivedSignal,tgtang);                    % Collect all echoes
        receivedSignal = step(receiver,receivedSignal,~(tranStatus>0));            % Receive signal
        receivedSignal = step(beamformer,receivedSignal,[scanGrid(scanCount);0]);  % Beamforming
        signalmatrix(:,m) = receivedSignal;                                        % Form received signal matrix
%         figure(1)
        % Get matched filter's output
        matchingCoeff = getMatchedFilter(waveform);
        hmf = phased.MatchedFilter(...
            'Coefficients',matchingCoeff,...
            'GainOutputPort',true);
        [mf_pulses, mfgain] = step(hmf,signalmatrix);
        mf_pulses = reshape(mf_pulses,[],int_pulsenum,numScans);
        matchingdelay = size(matchingCoeff,1)-1;
        sz_mfpulses = size(mf_pulses);
        mf_pulses = [mf_pulses(matchingdelay+1:end) zeros(1,matchingdelay)];
        mf_pulses = reshape(mf_pulses,sz_mfpulses);
        % Pulse integration
        int_pulses = pulsint(mf_pulses,'noncoherent');
        int_pulses = squeeze(int_pulses);
        % Visualize
        r = c*FastTimeGrid/2;
        X = r'*cosd(scanGrid); Y = r'*sind(scanGrid);
        output = pow2db(abs(int_pulses).^2);
%         if mod(m,int_pulsenum) == 0
%             pcolor(X,Y,output);
%             axis equal tight
%             shading interp
%             set(gca,'Visible','off');
%             text(-800,0,'Array');
%             text((max(r)+10)*cosd(initialAz),(max(r)+10)*sind(initialAz),...
%                 [num2str(initialAz) '^o']);
%             text((max(r)+10)*cosd(endAz),(max(r)+10)*sind(endAz),...
%                 [num2str(endAz) '^o']);
%             text((max(r)+10)*cosd(0),(max(r)+10)*sind(0),[num2str(0) '^o']);
%             colorbar;
%         end
    end % End of m
    % Save Data %
    save(['PPIdata',int2str(y),'.mat'],'output')

end % End of Frame

disp('Finished')


figure(1)
pcolor(X,Y,output);
axis equal tight
shading interp
set(gca,'Visible','off');
text(-800,0,'Array');
text((max(r)+10)*cosd(initialAz),(max(r)+10)*sind(initialAz),...
    [num2str(initialAz) '^o']);
text((max(r)+10)*cosd(endAz),(max(r)+10)*sind(endAz),...
    [num2str(endAz) '^o']);
text((max(r)+10)*cosd(0),(max(r)+10)*sind(0),[num2str(0) '^o']);
colorbar;