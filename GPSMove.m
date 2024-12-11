function [error, initialPositions, xAll, pos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long)
    % Constants
    signalspeed = 299792.458; % Speed of light in km/s
    satZ = 26570; % Altitude of satellites in km
    surfaceZ = 6370; % Earth's radius in km
    R = surfaceZ; % Earth's radius for polar calculations

    % Satellite positions
    pos = [];
    phi = pi/6;
    theta = linspace(0, 2*pi, numSatelites + 1);  
    disp(theta)
    xAll = zeros(4, numMoves);
    error = zeros(1, numMoves);
    initialPositions = zeros(3, numMoves);
    
    % Initialize satellite positions
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * sin(phi), %flipped x and z for moving the satellites, will clean up later
            %satZ * cos(phi) * cos(theta(i)),
            satZ * cos(phi) * sin(theta(i)),
            satZ * cos(phi) * cos(theta(i))
            %satZ * sin(phi)
        ];
    end
    
    % Convert bearing to radians
    bearingRad = deg2rad(bearing);
    % Convert Initial long and lat to radians
    lat=deg2rad(lat);
    long=deg2rad(long);
    
    for i = 1:numMoves
        % Update latitude and longitude based on step distance using
        % Haversine formula
        centralAngle=stepdist/R;
        lat2 = asin(sin(lat)*cos(centralAngle)+cos(lat)*sin(centralAngle)*(cos(bearingRad)));
        long = long + atan2(sin(bearingRad)*sin(centralAngle)*cos(lat),cos(centralAngle)-sin(lat)*sin(lat2));
        lat=lat2;
        
        % Convert updated latitude and longitude to Cartesian coordinates
        x = R * cos(lat) * cos(long);
        y = R * cos(lat) * sin(long);
        z = R * sin(lat);
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
        if i==1
            x0 = [R; 0; 0; 0];
        else 
            x0=xAll(:, i-1);
        end
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
        x = updatedmethod(f_wrapper, J_wrapper, x0);
        error(1, i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;
        
        % Display progress every 10 iterations
        if mod(i, 10) == 0
            %disp(i);
        end
    end
end
