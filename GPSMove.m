function [error, initialPositions, xAll, pos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long)
    % Constants
    signalspeed = 299792.458; % Speed of light in km/s
    satZ = 26570; % Altitude of satellites in km
    surfaceZ = 6370; % Earth's radius in km
    R = surfaceZ; % Earth's radius for polar calculations

    % Satellite positions
    pos = [];
    phi = rand(1, numSatelites) * 2 * pi;  % Generate a random phi for each satellite
    theta = rand(1, numSatelites) * 2 * pi; % Generate a random theta for each satellite
    xAll = zeros(4, numMoves);
    error = zeros(1, numMoves);
    initialPositions = zeros(3, numMoves);
    
    % Initialize satellite positions
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * cos(phi(i)) * cos(theta(i));
            satZ * cos(phi(i)) * sin(theta(i));
            satZ * sin(phi(i)),
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
        if long >= 2 * pi
            long = long - 2 * pi; % Wrap around after 360 degrees (2*pi radians)
        elseif long < 0
            long = long + 2 * pi; % Wrap around for negative values
        end
        if lat >= 2 * pi
            lat = lat - 2 * pi; % Wrap around after 360 degrees (2*pi radians)
        elseif lat < 0
            lat = lat + 2 * pi; % Wrap around for negative values
        end
        disp(rad2deg(lat))
        
        % Convert updated latitude and longitude to Cartesian coordinates
        x = R * cos(long)*cos(lat);
        y = R * cos(long) * sin(lat);
        z = R *sin(long);
        
        initialPosActual = [x, y, z];
        initialPositions(:, i) = initialPosActual';
        
        % Calculate which sats phone has view of
        %declaring alternate names for variables for clarity
        x1=x; %1 denotes pos of phone
        y1=y;
        z1=z;
        x3=0; %3 denotes pos of earth
        y3=0;
        z3=0;
        satsNoView=[];
        for j=1:numSatelites
            x2=pos(j,1);
            y2=pos(j,2);
            z2=pos(j,3);
            a=(x2-x1)^2+(y2-y1)^2+(z2-z1)^2;
            b=2*((x2-x1)*(x1-x3)+(y2-y1)*(y1-y3)+(z2-z1)*(z1-z3));
            c=x3^2+y3^2+z3^2+x1^2+y1^2+z1^2-2*(x3*x1+y3*y1+z3*z1)-R^2;
            sqrtOfQuadraticEq=b*b-4*a*c;
            if sqrtOfQuadraticEq <=0 %phone can not see sat
                satsNoView(end+1)=j; %keep track of "bad" sats
            end

        end
        pos(satsNoView,:)=[];
        [rownum, ~]=size(pos);
        numUsedSat=4; %denotes num of sats needed for one reading
        if rownum<numUsedSat
            disp("Not enough well-positioned sats to determine position")
            x=xAll(:, i-1);
        else
                    % Noise and distance calculation
            randnoise = zeros(numSatelites, 1);
            distance = zeros(numSatelites, 1);
            for j = 1:numSatelites
                distance(j) = norm(pos(j, :) - initialPosActual);
                randnoise(j) = rand() * noisefactor * i; % Scaled noise
            end
            t = distance ./ signalspeed + randnoise*0;
            [~, sortedIndices] = sort(t); % Sort distances
            xClosestIndices = sortedIndices(1:numUsedSat); % Indices of x closest satellites
            % Calculate phone position using times
            syms x y z d
            % x0 = [0; 0; 6370; 0];
            if i==1
                x0 = [0; 0; 0; 0];
            else 
                x0=xAll(:, i-1);
            end
            A = pos(xClosestIndices, 1); B = pos(xClosestIndices, 2); C = pos(xClosestIndices, 3); t= t(xClosestIndices); % Only uses closest sats
            
            fSym = sym([]);
            for j = 1:numUsedSat
                % Function to minimize for each satellite, using only the
                % numUsedSat number of sats
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
        end
        error(1, i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;
        
        % Display progress every 10 iterations
        if mod(i, 10) == 0
            fprintf('Iteration: %d\n', i);
        end
    end
end
