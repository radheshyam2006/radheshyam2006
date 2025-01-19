
% Set paths for folders
referenceFolder = 'C:\Users\user\OneDrive\Desktop\sp_project\Project_BirdRecognition\Reference/';
taskFolder = 'C:\Users\user\OneDrive\Desktop\sp_project\Project_BirdRecognition\Task/';


K=3;


% Step 1: Load and Analyze Reference Files
refFiles = dir(fullfile(referenceFolder, '*.wav'));
referenceFeatures = []; % Store features of reference files
referenceSignals = {};  % Store reference audio signals
speciesLabels = [];     % To label each bird species

for i = 1:length(refFiles)
    % Load audio file
    [audio, fs] = audioread(fullfile(referenceFolder, refFiles(i).name));

    % Normalize audio
    audio = audio / max(abs(audio));

    % Compute features
    zcr = mean(abs(diff(sign(audio))));          % Zero-Crossing Rate
    rms = sqrt(mean(audio.^2));                 % Root Mean Square
    spectrum = abs(fft(audio));                 % Spectrum
    freqs = (0:length(spectrum)-1) * (fs/length(audio));
    spectralCentroid = sum(freqs' .* spectrum) / sum(spectrum); % Spectral Centroid

    % Store features and label
    referenceFeatures = [referenceFeatures; zcr, rms, spectralCentroid];
    referenceSignals{i} = audio; % Store normalized signal for matched filtering
    speciesLabels = [speciesLabels; i]; % Replace 'i' with actual species if known
end

% Step 2: Load Task Files and Classify using Matched Filter and KNN
taskFiles = dir(fullfile(taskFolder, '*.wav'));
taskFeatures = [];
results = [];

for i = 1:length(taskFiles)
    % Load task audio file
    [taskAudio, fs] = audioread(fullfile(taskFolder, taskFiles(i).name));
    taskAudio = taskAudio / max(abs(taskAudio));

    % Compute features
    zcr = mean(abs(diff(sign(taskAudio))));          % Zero-Crossing Rate
    rms = sqrt(mean(taskAudio.^2));                 % Root Mean Square
    spectrum = abs(fft(taskAudio));                 % Spectrum
    freqs = (0:length(spectrum)-1) * (fs/length(taskAudio));
    spectralCentroid = sum(freqs' .* spectrum) / sum(spectrum); % Spectral Centroid

    % Store task features
    taskFeatures = [taskFeatures; zcr, rms, spectralCentroid];

    % Matched Filtering for Direct Matching
    maxCorrelation = -Inf;
    bestMatch = -1;

    for j = 1:length(referenceSignals)
        % Matched filter computation (cross-correlation)
        refAudio = referenceSignals{j};
        correlation = max(xcorr(taskAudio, refAudio, 'coeff'));

        % Update best match based on correlation
        if correlation > maxCorrelation
            maxCorrelation = correlation;
            bestMatch = speciesLabels(j);
        end
    end

    % Store matched filter result for validation
    matchedFilterLabel = bestMatch;

    % KNN Classification
    distances = sqrt(sum((referenceFeatures - taskFeatures(i, :)).^2, 2));
    [~, idx] = sort(distances);
    nearestLabels = speciesLabels(idx(1:K));
    knnLabel = mode(nearestLabels);

    % Combine Matched Filter and KNN (e.g., majority vote or validation)
    if matchedFilterLabel == knnLabel
        results = [results; knnLabel]; % Consensus
    else
        results = [results; matchedFilterLabel]; % Trust Matched Filter if discrepancy
    end
end


% Display results
disp('Classification Results:');
disp(results);



