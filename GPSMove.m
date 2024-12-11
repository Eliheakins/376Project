function [error, initialPositions, xAll, pos] = GPSMove(numSatelites, numPoints, noisefactor)
    % Constants
    signalspeed = 299792.458; % Speed of light in km/s
    satZ = 26570; % Altitude of satellites in km
    surfaceZ = 6370; % Earth's radius in km
    R = surfaceZ; % Earth's radius for polar calculations

    % Satellite positions
    pos = [];
    phi = rand(1, numSatelites) * 2 * pi;  % Generate a random phi for each satellite
    theta = rand(1, numSatelites) * 2 * pi; % Generate a random theta for each satellite
    xAll = zeros(4, numPoints); % Assuming 4 variables for the position vector
    error = zeros(1, numPoints);
    initialPositions = zeros(3, numPoints); % Store positions in Cartesian coords
    
    % Initialize satellite positions
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * cos(phi(i)) * cos(theta(i));
            satZ * cos(phi(i)) * sin(theta(i));
            satZ * sin(phi(i)),
        ];
    end
    
    % Randomly generate initial positions for points on the Earth's surface
    for i = 1:numPoints
        lat = (rand() * 180) - 90;  % Random latitude in degrees
        long = (rand() * 360) - 180; % Random longitude in degrees
        
        % Convert latitude and longitude to radians
        lat = deg2rad(lat);
        long = deg2rad(long);
        
        % Convert to Cartesian coordinates
        x = R * cos(lat) * cos(long);
        y = R * cos(lat) * sin(long);
        z = R * sin(lat);
        
        % Store the results
        initialPositions(:, i) = [x; y; z]; % Store as a column vector
    end
    
    % Loop through each point
    for i = 1:numPoints
        initialPosActual = initialPositions(:, i); % Actual position of the point
        
        % Calculate which satellites the phone has a view of
        satsNoView = [];
        for j = 1:numSatelites
            x2 = pos(j, 1);
            y2 = pos(j, 2);
            z2 = pos(j, 3);
            x1 = initialPosActual(1);
            y1 = initialPosActual(2);
            z1 = initialPosActual(3);
            
            a = (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2;
            b = 2 * ((x2 - x1) * (x1 - 0) + (y2 - y1) * (y1 - 0) + (z2 - z1) * (z1 - 0));
            c = x1^2 + y1^2 + z1^2 - 2 * (x1 * 0 + y1 * 0 + z1 * 0) - R^2;
            sqrtOfQuadraticEq = b * b - 4 * a * c;
            
            if sqrtOfQuadraticEq <= 0
                satsNoView(end + 1) = j; % Keep track of "bad" satellites
            end
        end
        
        pos(satsNoView, :) = []; % Remove satellites that the phone cannot see
        [rownum, ~] = size(pos);
        numUsedSat = 4; % Number of satellites needed
        
        if rownum < numUsedSat
            disp("Not enough well-positioned satellites to determine position");
            return;
        end
        
        % Noise and distance calculation
        randnoise = zeros(numSatelites, 1);
        distance = zeros(numSatelites, 1);
        for j = 1:numSatelites
            distance(j) = norm(pos(j, :) - initialPosActual); % Distance to satellite
            randnoise(j) = rand() * noisefactor; % Scaled noise (noisefactor used directly)
        end
        t = distance / signalspeed + randnoise; % Time calculation with noise
        
        % Sort the times and select closest satellites
        [~, sortedIndices] = sort(t);
        xClosestIndices = sortedIndices(1:numUsedSat); % Indices of closest satellites
        
        % Calculate phone position using times (Solving nonlinear system)
        syms x y z d
        x0 = [0; 0; 0; 0]; % Initial guess for the first iteration
        
        A = pos(xClosestIndices, 1); 
        B = pos(xClosestIndices, 2); 
        C = pos(xClosestIndices, 3); 
        t = t(xClosestIndices); % Only use closest satellites
        
        fSym = sym([]);
        for j = 1:numUsedSat
            fSym(j) = (x - A(j))^2 + (y - B(j))^2 + (z - C(j))^2 - (signalspeed * (t(j) - d))^2;
        end
        
        fSym = fSym';
        JSym = jacobian(fSym, [x, y, z, d]);
        
        f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
        J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);
        
        % Numerical solution using Newton's method
        f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
        J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));
        
        % Use external method for Newton's method (ensure it's defined)
        x = updatedmethod(f_wrapper, J_wrapper, x0);
        
        % Calculate the error
        error(1, i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;
        
        % Display progress every 10 iterations
        if mod(i, 10) == 0
            fprintf('Iteration: %d\n', i);
        end
    end
end
