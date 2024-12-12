function [error, initialPositions, xAll, pos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long)
    % Constants
    signalspeed = 299792.458; % Speed of light in km/s
    satZ = 26570; % Altitude of satellites in km
    surfaceZ = 6370; % Earth's radius in km
    R = surfaceZ; % Earth's radius for polar calculations

    % Satellite positions
    phi = rand(1, numSatelites) * 2 * pi;  % Random phi for each satellite
    theta = rand(1, numSatelites) * 2 * pi; % Random theta for each satellite
    pos = zeros(numSatelites, 3);
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * cos(phi(i)) * cos(theta(i));
            satZ * cos(phi(i)) * sin(theta(i));
            satZ * sin(phi(i))
        ];
    end

    % Initialize result matrices
    xAll = zeros(4, numMoves);
    error = zeros(1, numMoves);
    initialPositions = zeros(3, numMoves);

    % Convert bearing and initial lat/long to radians
    bearingRad = deg2rad(bearing);
    lat = deg2rad(lat);
    long = deg2rad(long);

    for i = 1:numMoves
        % Update latitude and longitude using the Haversine formula
        centralAngle = stepdist / R;
        lat2 = asin(sin(lat) * cos(centralAngle) + cos(lat) * sin(centralAngle) * cos(bearingRad));
        long = long + atan2(sin(bearingRad) * sin(centralAngle) * cos(lat), cos(centralAngle) - sin(lat) * sin(lat2));
        lat = lat2;

        % Normalize longitude to [0, 2*pi]
        long = mod(long, 2 * pi);

        % Convert updated latitude and longitude to Cartesian coordinates
        x = R * cos(lat) * cos(long);
        y = R * cos(lat) * sin(long);
        z = R * sin(lat);

        initialPosActual = [x, y, z];
        initialPositions(:, i) = initialPosActual';

        % Determine visible satellites
        visibleMask = true(1, numSatelites); % Initialize all satellites as visible
        for j = 1:numSatelites
            LOS = pos(j, :) - initialPosActual;
            R_vec = initialPosActual;
            if dot(R_vec, LOS) <= 0
                visibleMask(j) = false; % Mark satellite as not visible
            end
        end

        % Get positions of visible satellites
        visiblePos = pos(visibleMask, :);
        numVisibleSats = size(visiblePos, 1);
        % Check if there are enough satellites
        numUsedSat = 6; % Minimum satellites needed
        if numVisibleSats < numUsedSat
            %disp("Not enough well-positioned satellites to determine position");
            if i > 1
                x = xAll(:, i-1); % Use previous position as fallback
            else
                x = [0; 0; 0; 0]; % Default fallback position
            end
        else
            % Calculate distances and noise for visible satellites
            distance = zeros(numVisibleSats, 1);
            randnoise = zeros(numVisibleSats, 1);
            for j = 1:numVisibleSats
                distance(j) = norm(visiblePos(j, :) - initialPosActual);
                randnoise(j) = rand() * noisefactor * i; % Scaled noise
            end
            t = distance ./ signalspeed + randnoise;
            [~, sortedIndices] = sort(t); % Sort by distance
            xClosestIndices = sortedIndices(1:numUsedSat);

            % Position calculation using the closest satellites
            A = visiblePos(xClosestIndices, 1);
            B = visiblePos(xClosestIndices, 2);
            C = visiblePos(xClosestIndices, 3);
            t = t(xClosestIndices);

            if i == 1
                x0 = [0; 0; 0; 0];
            else
                x0 = xAll(:, i-1);
            end

            syms x y z d
            fSym = sym([]);
            for j = 1:numUsedSat
                fSym(j) = (x - A(j))^2 + (y - B(j))^2 + (z - C(j))^2 - (signalspeed * (t(j) - d))^2;
            end
            fSym = fSym';
            JSym = jacobian(fSym, [x, y, z, d]);

            f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
            J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);
            f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
            J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));

            % Solve using Newton's method
            x = updatedmethod(f_wrapper, J_wrapper, x0);
        end

        % Compute error and store the position
        error(1, i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;

        % Display progress every 10 iterations
        %if mod(i, 10) == 0
            %fprintf('Iteration: %d\n', i);
        %end
    end
end
