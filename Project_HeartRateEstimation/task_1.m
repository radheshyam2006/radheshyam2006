% Load the ECG signal
load('E1.mat'); % Replace with your .mat file
ecg_signal = E1(500:1000); % Replace with actual variable name
fs = 128;        % Sampling frequency

% Preprocessing: Bandpass filter (optional)
% low_cutoff = 0.5; % Hz
% high_cutoff = 50; % Hz
% [b, a] = butter(4, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
% filtered_signal = filtfilt(b, a, ecg_signal);

% Step 1: Differentiation
diff_signal = diff(ecg_signal);

% Step 2: Squaring
squared_signal = diff_signal.^2;

% Step 3: Moving Window Integration
window_size = round(0.15 * fs); % 150 ms window
integrated_signal = movmean(squared_signal, window_size);

% Step 4: Peak Detection
% Adjust MinPeakHeight based on integrated signal
threshold = max(integrated_signal) * 0.2; % Dynamic threshold
[~, r_locs] = findpeaks(integrated_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', fs * 0.3);

% Step 5: Calculate Heart Rate (BPM)
time_intervals = diff(r_locs) / fs; % Time intervals between peaks in seconds
bpm = 60 ./ time_intervals;         % Convert to BPM
bpm_time = r_locs(2:end) / fs;      % Time corresponding to BPM values

% Plotting Results
figure;
subplot(3, 1, 1);
plot((0:length(ecg_signal)-1) / fs, ecg_signal);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot((0:length(integrated_signal)-1) / fs, integrated_signal);
hold on;
plot(r_locs / fs, integrated_signal(r_locs), 'ro');
title('Integrated Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(bpm_time, bpm, '-o');
xlim([bpm_time(1), bpm_time(end)]); % Correct time axis limits
title('Heart Rate (BPM) Over Time');
xlabel('Time (s)');
ylabel('BPM');
grid on;

% figure;
% subplot(2, 1, 1);
% plot(squared_signal);
% title('Squared Signal');
% xlabel('Samples');
% ylabel('Amplitude');
% 
% subplot(2, 1, 2);
% plot(integrated_signal);
% title('Integrated Signal (Smoothed)');
% xlabel('Samples');
% ylabel('Amplitude');
% 
