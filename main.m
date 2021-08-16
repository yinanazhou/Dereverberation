% Zhou/Yinan/Final Project: Dereverberation

close all; clear;
%% load audio
[y, fs] = audioread('audio/mozart_high_reverb.wav');
y = y(:,1);         % convert to mono
y = y/max(abs(y));  % normalize
y_len = length(y);
soundsc(y, fs)
%% convert
win_sz = 1024;
overlap = 0.75;
noverlap = overlap*win_sz;
% noverlap = 199;
win = hann(win_sz, 'periodic');
nfft = win_sz;
[M,w,t] = spectrogram(y, win, noverlap, nfft, fs);
[freqlen, framelen] = size(M);

%% Initialization
B = noverlap/4;                     % block size (hop size: 1/4 overlap)
% B = 400;                     % block size
S = zeros(freqlen, framelen);       % S(omega): dry 
R = zeros(freqlen, framelen);       % R(omega): reverberant 
SiPreFrame_2 = zeros(freqlen,B);    % Si2(omega): previous frame

% assume all dry
G_S = ones(freqlen, 1);             % Gain (dry): always <1.0
G_R = zeros(freqlen, 1);            % Gain (reverb)
MinGain = zeros(freqlen,1);         % MinGain(w): positive, prevent G_s falling below some desired positive value
MinGain(:) = 0;                   % (EXP)

% H2(omega) & estimation
MaxValue = zeros(freqlen,B);        % MaxValue_i(w)
MaxValue(:) = 0.99;                  % (EXP)
Bias = zeros(freqlen,B);            % Bias_i(w), >1.0
Bias(:) = 1.29;                     % (EXP)
H_2 = MaxValue/2;                   % H2(omega)
% H_2 = ones(freqlen, B);
C_2 = zeros(size(H_2));             % C2(omega): limited estimate H2(omega)
MiPreFrame_2 = ones(freqlen,B);     % Mi2(omega): previous frame 

% smoothing
gamma = zeros(freqlen,1);           % gamma, smoothing, 0(max)-1(min)
gamma(:) = 0.05;                     % (EXP)
alpha = zeros(freqlen,B);           % alpha, temporal soomthing, 0(min)-1(max)
alpha(:) = 0.08 ;                     % (EXP), freq dependent

%% Dereverberation
for FrameIdx = 1:framelen
    M0 = M(:, FrameIdx);        % M0(omega)
    M0_2 = abs(M0).^2;          % M02(omega)
    
    for BlockIdx = 1:B
        % esitimate of H2_i(omega)
        Estimate_H = M0_2./MiPreFrame_2(:,BlockIdx);  % C(omega) = M0(omega)/Mi(omega)
        flag = Estimate_H >= H_2(:,BlockIdx);
        Estimate_H(flag) = H_2(flag,BlockIdx).*Bias(flag,BlockIdx) + eps; 
        
        % limit C_i(omega)
        C_2(:,BlockIdx) = min(MaxValue(:,BlockIdx), Estimate_H);
        
        % temporal smoothing
        a = alpha(:,BlockIdx);
        H_2(:,BlockIdx) = a.*H_2(:,BlockIdx) + (1-a).*C_2(:,BlockIdx);
    end
    
    % G_S
    CurrentG_S = 1.0 - (sum(SiPreFrame_2.*H_2, 2))./M0_2;
    % limit G_S
    CurrentG_S = max([CurrentG_S MinGain], [], 2);
    % G_R
    CurrentG_R = 1.0 - CurrentG_S;
    % smoothing
    G_S = (1-gamma).*G_S + gamma.*CurrentG_S;       % G'_S,t
    cond = G_S > 1.0;
    G_S = cond.*1.0 + (~cond).*G_S;
    
    G_R = (1-gamma).*G_R + gamma.*CurrentG_R;       % G'_R,t
    
    % estimate dry and reverb signal
    S(:, FrameIdx) = G_S.*M0;                 % S0_est(omega)
    R(:, FrameIdx) = G_R.*M0;                 % R0_est(omega)
    
    % shift frame
    SiPreFrame_2(:, 2:end) = SiPreFrame_2(:, 1:end-1);
    SiPreFrame_2(:, 1) = abs(S(:, FrameIdx)).^2;
    
    MiPreFrame_2(:, 2:end) = MiPreFrame_2(:, 1:end-1);
    MiPreFrame_2(:, 1) = M0_2;
end

%% convert back
% s = istft(S, fs, 'Window', win, 'OverlapLength', 166);
s = ISTFT(S, win,win_sz, noverlap, y_len);
% pause(2.5)
soundsc(s, fs)
s = s / max(abs(s));

% audiowrite('dereverb_audio/12dry.wav',s,fs)
audiowrite('audio/mozart_dereverb.wav',s,fs)
%% plot
% spectrogram(y, win, noverlap,'yaxis');
% title('Original Signal')
% xlim([0 2.5e5])

figure()
spectrogram(s, win, noverlap,'yaxis');
title('Dry Signal')
xlim([0 2.5e5])


