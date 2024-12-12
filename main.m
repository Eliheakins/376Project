clear all; clc; close all;

% Independent variables
maxIter = 10;         % Number of iterations per satellite count
numSatelitesRange = 6:25;
numSatelitesCount = numel(numSatelitesRange);

% Preallocate a cell array to store error values
errors = cell(1, numSatelitesCount);

% Initialize the progress bar
hWaitBar = waitbar(0, 'Processing satellite counts...');

% Loop through each satellite count
for idx = 1:numSatelitesCount
    numSatelites = numSatelitesRange(idx); % Current satellite count
    disp(['Processing numSatelites: ', num2str(numSatelites)]);
    
    % Initialize storage for errors in this satellite count
    errorForCurrentSat = zeros(maxIter, 1);
    
    for i = 1:maxIter
        disp(i)
        % Simulation parameters
        stepdist = 100; 
        noisefactor = 0; 
        bearing = 90; % Zero is north
        lat = 0;     % Initial latitude (degrees)
        long = 0;    % Initial longitude (degrees)
        
        earthCircum = 40075; % Earth's circumference in km
        dist = 40000;        % Total distance in km
        numMoves = dist / stepdist;

        % Call the GPSMove function (assuming it exists)
        [error, actualPos, estPos, satPos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long);

        % Save the final error for this iteration
        errorForCurrentSat(i) = error(end); % Assuming `error` is a vector
    end

    % Save all errors for this satellite count
    errors{idx} = errorForCurrentSat;
    
    % Update progress bar
    waitbar(idx / numSatelitesCount, hWaitBar, ...
        sprintf('Processing %d/%d satellite counts...', idx, numSatelitesCount));
end

% Close the progress bar
close(hWaitBar);

disp('Error storage complete!');
save('errors_data.mat', 'errors', 'numSatelitesRange', 'maxIter');