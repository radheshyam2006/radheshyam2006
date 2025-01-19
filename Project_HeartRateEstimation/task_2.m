% Load the ECG signal
load('E2.mat'); % Replace with your .mat file
ecg_signal = E2(500:1500); % Replace with actual variable name
fs = 128;        % Sampling frequency

% Preprocessing: Bandpass filter
low_cutoff = 1.5; % Hz
high_cutoff = 35; % Hz
[b, a] = butter(4, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
filtered_signal = filtfilt(b, a, ecg_signal);

% Step 1: Differentiation
diff_signal = diff(filtered_signal);

% Step 2: Squaring
squared_signal = diff_signal.^2;

% Step 3: Moving Window Integration
window_size = round(0.15 * fs); % 150 ms window
integrated_signal = movmean(squared_signal, window_size);

% Step 4: Peak Detection
threshold = max(integrated_signal) * 0.2; % Dynamic threshold
[~, r_locs] = findpeaks(integrated_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', fs * 0.3);

% Step 5: Calculate Heart Rate (BPM)
time_intervals = diff(r_locs) / fs; % Time intervals between peaks in seconds
bpm = 60 ./ time_intervals;         % Convert to BPM
bpm_time = r_locs(2:end) / fs;      % Time corresponding to BPM values

% Plotting Results
figure;

% Original ECG Signal
subplot(4, 1, 1);
plot((0:length(ecg_signal)-1) / fs, ecg_signal);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Filtered ECG Signal
subplot(4, 1, 2);
plot((0:length(filtered_signal)-1) / fs, filtered_signal);
title('Filtered ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Integrated Signal with Detected Peaks
subplot(4, 1, 3);
plot((0:length(integrated_signal)-1) / fs, integrated_signal);
hold on;
plot(r_locs / fs, integrated_signal(r_locs), 'ro');
title('Integrated Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');

% Heart Rate (BPM) Over Time
subplot(4, 1, 4);
plot(bpm_time, bpm, '-o');
xlim([bpm_time(1), bpm_time(end)]);
disp(mean(bpm));
title('Heart Rate (BPM) Over Time');
xlabel('Time (s)');
ylabel('BPM');
grid on;
