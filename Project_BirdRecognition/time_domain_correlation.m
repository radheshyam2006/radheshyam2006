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

% Organize into cell arrays
task_files = {f1, f2, f3, f4, f5, f6, f7, f8};
bird_files = {b1, b2, b3};

% FFT of bird and task signals
fft_task_files = cellfun(@(x) fftshift(fft(x)), task_files, 'UniformOutput', false);
fft_bird_files = cellfun(@(x) fftshift(fft(x)), bird_files, 'UniformOutput', false);

% Initialize storage for time-domain results
correlations_time = zeros(8, 3);
lag_coefficients = zeros(8, 3);

% Time-domain correlations and lag coefficients
for i = 1:8
    for j = 1:3
        % Perform cross-correlation
        [xc, lags] = xcorr(task_files{i}, bird_files{j}, 'coeff');
        [max_corr, idx] = max(xc); % Find max correlation and corresponding lag
        correlations_time(i, j) = max_corr;
        lag_coefficients(i, j) = lags(idx); % Store the lag at max correlation
    end
end

% Display results
for i = 1:8
    disp(['Task File F' num2str(i)]);
    for j = 1:3
        disp(['  - Correlation with Bird B' num2str(j) ': ' num2str(correlations_time(i, j)) ...
              ' at lag: ' num2str(lag_coefficients(i, j))]);
    end
end

% Spectral Comparison: Example Task File (F8) and Bird Files
% figure;
% subplot(2, 2, 1);
% plot(abs(fft_task_files{8}));
% title('Task File 8 Spectrum');
% 
% subplot(2, 2, 2);
% plot(abs(fft_bird_files{1}));
% title('Bird File B1 Spectrum');
% 
% subplot(2, 2, 3);
% plot(abs(fft_bird_files{2}));
% title('Bird File B2 Spectrum');
% 
% subplot(2, 2, 4);
% plot(abs(fft_bird_files{3}));
% title('Bird File B3 Spectrum');

% Time-Domain Correlation Visualization: Task File F8 with Bird Files
figure;
for j = 1:3
    [xc, lags] = xcorr(task_files{8}, bird_files{j}, 'coeff');
    subplot(3, 1, j);
    plot(lags, xc);
    title(['Correlation: Task File F8 vs Bird B' num2str(j)]);
    xlabel('Lag');
    ylabel('Correlation');
end
