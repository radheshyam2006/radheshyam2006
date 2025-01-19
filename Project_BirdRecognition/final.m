close all;

% Load Bird Reference Files
[b1, fs_b1] = audioread("Reference\bird1.wav");
[b2, fs_b2] = audioread("Reference\bird2.wav");
[b3, fs_b3] = audioread("Reference\bird3.wav");

% Load Task Files
[f1, fs_f1] = audioread("Task\F1.wav");
[f2, fs_f2] = audioread("Task\F2.wav");
[f3, fs_f3] = audioread("Task\F3.wav");
[f4, fs_f4] = audioread("Task\F4.wav");
[f5, fs_f5] = audioread("Task\F5.wav");
[f6, fs_f6] = audioread("Task\F6.wav");
[f7, fs_f7] = audioread("Task\F7.wav");
[f8, fs_f8] = audioread("Task\F8.wav");

% FFT of bird Signals
fft_b1 = fftshift(fft(b1));
fft_b2 = fftshift(fft(b2));
fft_b3 = fftshift(fft(b3));
% FFT of Task Signals
fft_f1 = fftshift(fft(f1));
fft_f2 = fftshift(fft(f2));
fft_f3 = fftshift(fft(f3));
fft_f4 = fftshift(fft(f4));
fft_f5 = fftshift(fft(f5));
fft_f6 = fftshift(fft(f6));
fft_f7 = fftshift(fft(f7));
fft_f8 = fftshift(fft(f8));

% Spectral Centroids Function
% 
% computeSpectralCentroid = @(mag_fft, fs, L) ...
%     sum((fs * (-L/2:L/2-1) / L) .* mag_fft') / sum(mag_fft);

% Compute Magnitudes and Spectral Centroids
%variables
task_files = {fft_f1, fft_f2, fft_f3, fft_f4, fft_f5, fft_f6, fft_f7, fft_f8};
bird_files = {fft_b1, fft_b2, fft_b3};
fs_task = [fs_f1, fs_f2, fs_f3, fs_f4, fs_f5, fs_f6, fs_f7, fs_f8];
fs_bird = [fs_b1, fs_b2, fs_b3];

%calculates the length of each signal.(cellfun)

L_task = cellfun(@length, task_files);
L_bird = cellfun(@length, bird_files);

% Preallocate
% 
% spectral_centroids_task = zeros(1, 8);
% spectral_centroids_bird = zeros(1, 3);
correlations = zeros(8, 3);


% Compute Correlations and Spectral Centroid Distances
%Measure similarity between each task file and bird file using cross-correlation.
for i = 1:8
    for j = 1:3
        % Correlation
        correlations(i, j) = xcorr(abs(task_files{i}), abs(bird_files{j}), 0, 'coeff');
    end
end

% Match Files Based on Correlation and Spectral Centroid Distance
for i = 1:8
    % Find Best Match Using Combined Metric
    [max_corr, corr_match_index] = max(correlations(i, :)); % Maximum correlation
    
    % Display Results
    disp(['File F' num2str(i)]);
    disp([' - Best Match by Correlation: Bird ' num2str(corr_match_index) ...
          ' (Correlation: ' num2str(max_corr) ')']);
end

% Plot Example Comparisons
% figure;
% subplot(2, 2, 1);
% plot(abs(task_files{8})); 
% title('Task File 8 Spectrum');
% subplot(2, 2, 2); 
% plot(abs(bird_files{1}));
% title('Bird File B1 Spectrum');
% subplot(2, 2, 3);
% plot(abs(bird_files{2}));
% title('Bird File B2 Spectrum');
% subplot(2, 2, 4);
% plot(abs(bird_files{3}));
% title('Bird File B3 Spectrum');