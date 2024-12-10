function [error, initialPositions] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long)
    % Constants
    signalspeed = 299792.458; % Speed of light in km/s
    satZ = 26570; % Altitude of satellites in km
    surfaceZ = 6370; % Earth's radius in km
    R = surfaceZ; % Earth's radius for polar calculations

    % Satellite positions
    pos = [];
    phi = pi/6;
    theta = linspace(0, 2*pi, numSatelites + 1);  
    xAll = zeros(4, numMoves);
    error = zeros(1, numMoves);
    initialPositions = zeros(3, numMoves);
    
    % Initialize satellite positions
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * cos(phi) * cos(theta(i)),
            satZ * cos(phi) * sin(theta(i)),
            satZ * sin(phi)
        ];
    end
    
    % Convert bearing to radians
    bearingRad = deg2rad(bearing);
    
    for i = 1:numMoves
        % Update latitude and longitude based on step distance
        lat = lat + rad2deg(stepdist * cos(bearingRad) / R);
        long = long + rad2deg(stepdist * sin(bearingRad) / (R * cos(deg2rad(lat))));
        
        % Convert updated latitude and longitude to Cartesian coordinates
        x = R * cos(deg2rad(lat)) * cos(deg2rad(long));
        y = R * cos(deg2rad(lat)) * sin(deg2rad(long));
        z = R * sin(deg2rad(lat));
        initialPosActual = [x, y, z];
        
        % Store the calculated position
        initialPositions(:, i) = initialPosActual';
        
        % Noise and distance calculation
        randnoise = zeros(numSatelites, 1);
        distance = zeros(numSatelites, 1);
        for j = 1:numSatelites
            distance(j) = norm(pos(j, :) - initialPosActual);
            randnoise(j) = rand() * noisefactor * i; % Scaled noise
        end
        t = distance ./ signalspeed + randnoise;
        
        % Calculate phone position using times
        syms x y z d
        x0 = [0; 0; R; 0];
        A = pos(:, 1); B = pos(:, 2); C = pos(:, 3); % Satellite positions
        
        fSym = sym([]);
        for j = 1:numSatelites
            % Function to minimize for each satellite
            fSym(j) = (x - A(j))^2 + (y - B(j))^2 + (z - C(j))^2 - (signalspeed * (t(j) - d))^2;
        end
        fSym = fSym';
        JSym = jacobian(fSym, [x, y, z, d]);
        
        f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
        J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);
        f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
        J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));
        
        % Numerical solution using Newton's method
        x = newtons_method_n2(f_wrapper, J_wrapper, x0);
        error(1, i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;
        
        % Display progress every 10 iterations
        if mod(i, 10) == 0
            disp(i);
        end
    end
end
