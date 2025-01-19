% % Audio Loudness Analysis Script with Enhanced Detection
% % Clear previous data and close figures
% clc; close all; clear vars;
% 
% % Load the text file and audio file
% fileID = fopen('3.txt', 'r');
% data = textscan(fileID, '%s %f %f %f'); % Columns: word, start_time, end_time, answer
% fclose(fileID);
% 
% % Read audio file
% [audio, fs] = audioread("3.wav");
% % [audio, fs] = audioread("9.mp3");
% 
% % Convert to mono if stereo
% if size(audio, 2) > 1
%     audio = mean(audio, 2);
% end
% 
% % Extract data from text file
% words = data{1}; % List of words
% start_times = data{2}; % Start times in seconds
% end_times = data{3}; % End times in seconds
% 
% % Figure for audio visualization
% figure('Position', [100, 100, 1200, 600]);
% 
% % Prepare storage for segment analysis
% segment_amplitudes = zeros(length(words), 1);
% segment_rms = zeros(length(words), 1);
% segment_sqrt_means = zeros(length(words), 1);
% segment_max_values = zeros(length(words), 1);
% loud_segments = {};
% loud_words = {};
% 
% % Create time axis for plotting
% time_axis = (1:length(audio)) / fs;
% 
% % Analyze each segment
% disp('Segment Analysis:');
% for i = 1:length(words)
%     % Calculate start and end sample indices
%     start_sample = round(start_times(i) * fs);
%     end_sample = round(end_times(i) * fs);
% 
%     % Ensure we don't exceed audio length
%     start_sample = max(1, start_sample);
%     end_sample = min(length(audio), end_sample);
% 
%     % Extract word segment
%     word_segment = audio(start_sample:end_sample);
% 
%     % Calculate various amplitude metrics
%     segment_mean = mean(abs(word_segment));
%     segment_sqrt_mean = mean(sqrt(abs(word_segment)));
%     segment_rms_value = rms(word_segment);
%     segment_max_value = max(abs(word_segment));
% 
%     % Store segment parameters
%     segment_amplitudes(i) = segment_mean;
%     segment_sqrt_means(i) = segment_sqrt_mean;
%     segment_rms(i) = segment_rms_value;
%     segment_max_values(i) = segment_max_value;
% end
% 
% % Robust loud segment detection
% % Find top percentile of max values and RMS
% max_threshold = prctile(segment_max_values, 79);  % Top 15% loudest segments
% rms_threshold = prctile(segment_rms, 78.6);  % Top 15% segments by RMS
% 
% % Plot whole audio signal
% subplot(2,1,1);
% plot(time_axis, audio, 'b');
% title('Entire Audio Signal');
% xlabel('Time (seconds)');
% ylabel('Amplitude');
% hold on;
% 
% % Detect loud segments
% for i = 1:length(words)
%     % Identify loud segments based on multiple criteria
%     is_loud = (segment_max_values(i) >= max_threshold) || ...
%               (segment_rms(i) >= rms_threshold);
% 
%     % If segment is identified as loud
%     if is_loud
%         start_sample = round(start_times(i) * fs);
%         end_sample = round(end_times(i) * fs);
% 
%         % Ensure we don't exceed audio length
%         start_sample = max(1, start_sample);
%         end_sample = min(length(audio), end_sample);
% 
%         word_segment = audio(start_sample:end_sample);
% 
%         % Store loud segment details
%         loud_segments{end+1} = word_segment;
%         loud_words{end+1} = words{i};
% 
%         % Highlight loud segment on the plot
%         plot(time_axis(start_sample:end_sample), word_segment, 'r', 'LineWidth', 2);
% 
%         % Print loud segment details
%         fprintf('Loud Segment - Word: %s\n', words{i});
%         fprintf('  Max Amplitude: %.4f (Threshold: %.4f)\n', ...
%             segment_max_values(i), max_threshold);
%         fprintf('  RMS: %.4f (Threshold: %.4f)\n', ...
%             segment_rms(i), rms_threshold);
%     end
% end
% 
% % Prepare detailed analysis subplot
% subplot(2,1,2);
% % Plotting segment parameters
% bar(categorical(words), [segment_amplitudes, segment_sqrt_means, segment_rms, segment_max_values]);
% title('Segment Amplitude Metrics');
% xlabel('Words');
% ylabel('Amplitude');
% legend('Mean Amplitude', 'Sqrt Mean', 'RMS', 'Max Amplitude');
% 
% % Loud Segment Playback
% if ~isempty(loud_segments)
%     disp('Playing Loud Segments:');
%     for i = 1:length(loud_segments)
%         fprintf('Playing loud word: %s\n', loud_words{i});
%         sound(loud_segments{i}, fs);
%         pause(3);
%     end
% end
% 
% % Print comprehensive analysis
% fprintf('\nComprehensive Segment Analysis:\n');
% fprintf('%-10s | %-15s | %-15s | %-15s | %-15s\n', 'Word', 'Mean Amplitude', 'Sqrt Mean', 'RMS', 'Max Amplitude');
% fprintf('%-10s | %-15s | %-15s | %-15s | %-15s\n', ...
%     repmat('-',1,10), repmat('-',1,15), repmat('-',1,15), repmat('-',1,15), repmat('-',1,15));
% 
% for i = 1:length(words)
%     fprintf('%-10s | %-15.4f | %-15.4f | %-15.4f | %-15.4f\n', ...
%         words{i}, segment_amplitudes(i), segment_sqrt_means(i), segment_rms(i), segment_max_values(i));
% end
% 
% % Return metrics for reference
% metrics.max_threshold = max_threshold;
% metrics.rms_threshold = rms_threshold;

[speech, fs] = audioread('C:\Users\user\OneDrive\Desktop\sp_project\Project_LouderWordsDetection\audios\7.wav');
filename_txt = 'C:\Users\user\OneDrive\Desktop\sp_project\Project_LouderWordsDetection\text\7.txt';

fileID = fopen(filename_txt, 'r');

data = {};
while ~feof(fileID)
    line = fgetl(fileID);
    if ischar(line)
        parts = strsplit(line);
        if length(parts) == 4
            data = [data; parts];
        end
    end
end
fclose(fileID);

words = data(:, 1);
startTimes = str2double(data(:, 2));
endTimes = str2double(data(:, 3));
loudnessMarkers = str2double(data(:, 4));

dataTable = table(words, startTimes, endTimes, loudnessMarkers, ...
    'VariableNames', {'Word', 'StartTime', 'EndTime', 'LoudnessMarker'});

louderWords = dataTable(dataTable.LoudnessMarker == 1, :);
disp('Louder words (from .txt file):');
disp(louderWords);

frameLength = 1024;
overlap = 512;
numFrames = ceil(length(speech) / frameLength);
energy = zeros(numFrames, 1);

for i = 1:frameLength:length(speech) - frameLength + 1
    frame = speech(i:i + frameLength - 1);
    energy(round(i / frameLength) + 1) = sum(frame.^2);
end

energy = energy / max(energy);

timeVector = (1:length(energy)) * (frameLength / fs);

wordEnergy = zeros(height(dataTable), 1);
for i = 1:height(dataTable)
    startIndex = floor(dataTable.StartTime(i) * fs / frameLength) + 1;
    endIndex = floor(dataTable.EndTime(i) * fs / frameLength) + 1;
    
    startIndex = max(1, startIndex);
    endIndex = min(numFrames, endIndex);
    
    wordEnergy(i) = mean(energy(startIndex:endIndex));
end

figure;
bar(wordEnergy);
set(gca, 'xtick', 1:length(words), 'xticklabel', words, 'XTickLabelRotation', 45);
xlabel('Words');
ylabel('Average Energy');
title('Average Energy of Words');
grid on;