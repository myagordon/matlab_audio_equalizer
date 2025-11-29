% 5-Band Audio Equalizer
% Key Features:
%  Reads an input audio file wav format,
%  splits the signal into 5 frequency bands using FIR filters
%  applies a gain (in dB) to each band, user inputs this value
%  sums the bands to create an equalized output signal
%  plots original vs equalized signal in time and frequency
%  and saves the result as wav file
%
% Requirements:
% MATLAB with Signal Processing Toolbox 
% A mono or stereo WAV file in the current folder

clc; clear; close all;


% Name of input wav file 
inputFileName  = 'test1.wav';  

% Name of the output wav file
outputFileName = 'output_equalized.wav';

% Gain for each band in dB - 5 in total

gain_dB = [0, 0, 0, 0, 0];   % to start

% FIR filter order 
filterOrder = 256; 

% toggle this on/off
showPlots   = true;

% read in wav file
[x, Fs] = audioread(inputFileName);

% if audio is stereo convert to mono by avging channels
if size(x, 2) > 1
    x = mean(x, 2);  % (L + R) /2
end

N = length(x);

% time vector for plotting
t = (0:N-1) / Fs;

% define freq bands
bandEdges_Hz = [ ...
    0, ...         % Edge 0
    200, ...       % 1
    600, ...       % 2
    2000, ...      % 3
    6000, ...      % 4
    Fs/2 ...       % edge 5 = nyquist
];

numBands = length(bandEdges_Hz) - 1; % this is 5

% convert gain from dB to linear once
gain_lin = 10.^(gain_dB / 20);

%% I've used fir1 to design
%  A lowpass filter for the first band, ahighpass filter for the last band
%  and a bandpass filters for the bands in between
% We will store the filter coefficients for each band in a cell array.

filters_b = cell(1, numBands);  % each cell will hold a row vector of b coefficients

for k = 1:numBands
    f1 = bandEdges_Hz(k);
    f2 = bandEdges_Hz(k+1);

    % Convert to normalized frequency
    if k == 1
        % First band: lowpass from 0 to f2
        Wn = f2 / (Fs/2); % normalized cutoff
        filters_b{k} = fir1(filterOrder, Wn, 'low');
    elseif k == numBands
        % Last band: highpass from f1 to Nyquist
        Wn = f1 / (Fs/2); % normalized cutoff
        filters_b{k} = fir1(filterOrder, Wn, 'high');
    else
        % Middle bands: bandpass from f1 to f2
        Wn = [f1, f2] / (Fs/2); % normalized band edges
        filters_b{k} = fir1(filterOrder, Wn, 'bandpass');
    end
end


%% apply filters
% init output to 0
y = zeros(size(x));

% store each band separately for debugging
bands = zeros(N, numBands);

for k = 1:numBands
    % Get FIR filter coefficients for band
    b = filters_b{k};
    % Filter the input signal
    bandSignal = filter(b, 1, x);
    % Apply gain in linear scale
    bandSignal = gain_lin(k) * bandSignal;
    % store
    bands(:, k) = bandSignal;
    % Add to output
    y = y + bandSignal;
end

% normalize output to avoid clipping
maxVal = max(abs(y));
if maxVal > 1
    % Scale down so the max amplitude is 0.99
    y = 0.99 * y / maxVal;
end

%% plot results
if showPlots
    % time domain plots
    figure;
    subplot(2,1,1);
    plot(t, x);
    title('Original Signal (Time Domain)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2,1,2);
    plot(t, y);
    title('Equalized Signal (Time Domain)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    % freq domain plots
    Nfft = 4096;
    % Compute FFT of orig and equalized signals
    X = fft(x, Nfft);
    Y = fft(y, Nfft);

    % freq vector
    f = (0:Nfft-1) * (Fs / Nfft);

    % plot up to Nyquist 
    halfIdx = 1:floor(Nfft/2);
    f_half  = f(halfIdx);
    X_half  = abs(X(halfIdx));
    Y_half  = abs(Y(halfIdx));

    figure;
    subplot(2,1,1);
    plot(f_half, X_half);
    title('Original Signal (Magnitude Spectrum)');
    xlabel('Frequency (Hz)');
    ylabel('|X(f)|');
    grid on;

    subplot(2,1,2);
    plot(f_half, Y_half);
    title('Equalized Signal (Magnitude Spectrum)');
    xlabel('Frequency (Hz)');
    ylabel('|Y(f)|');
    grid on;

    % show the frequency response of each filter 
    figure;
    hold on;
    for k = 1:numBands
        [H, f_resp] = freqz(filters_b{k}, 1, 1024, Fs);
        plot(f_resp, 20*log10(abs(H)));  % mag in dB
    end
    hold off;
    title('Magnitude Response of Each EQ Band');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    legend({'Band 1', 'Band 2', 'Band 3', 'Band 4', 'Band 5'}, 'Location', 'best');
    grid on;
end


%% save equalized audio, can comment this out
audiowrite(outputFileName, y, Fs);
fprintf('Equalized audio saved as: %s\n', outputFileName);
