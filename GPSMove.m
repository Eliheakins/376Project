function [error,initialPositions] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, latmove, longmove)
    % idea -- radius of where collect

    % static variables (these dont change)
    signalspeed = 299792.458;
    satZ = 26570;
    surfaceZ = 6370;
    
    % set up stuff
    pos = [];
    phi = pi/6;
    theta = linspace(0, 2*pi, numSatelites + 1);  
    xAll = zeros(4, numMoves);
    error = zeros(1, numMoves);
    initialPositions = zeros(3,numMoves);
     
    % Position calculation loop
    for i = 1:numSatelites
        pos(i, :) = [
            satZ * cos(phi) * cos(theta(i)),
            satZ * cos(phi) * sin(theta(i)),
            satZ * sin(phi)
        ];
    end
    
    
    for i = 1:numMoves
    
        % calculate time taken from each satelite to the phone
        %initialPosActual = [0 + (i-1) * latmove, 0 + (i-1) * longmove, surfaceZ]; % FIGURE OUT HOW TO IMPLEMENT POLARWIZE
        
        initialPosActual = [(i-1) * stepdist, 0, surfaceZ]; % WHEN XYZ COORDS
        randnoise = zeros(numSatelites,1);
        distance = zeros(numSatelites,1);
        initialPositions(:,i) = initialPosActual';
    
        for j = 1:numSatelites
            distance(j) = norm(pos(j, :) - initialPosActual);
            randnoise(j) = rand()*noisefactor*i; % sizes by a factor of i
        end
        t = distance ./ signalspeed + randnoise;
    
        % Calculate PHONE position using TIMES
        syms x y z d
        x0 = [0; 0; 6370; 0];
        A = pos(:, 1); B = pos(:, 2); C = pos(:, 3); % A = x positions of sats; B = y positions of sats; C = z positions of sats
    
        fSym = sym([]); % Initialize fSym as a column vector
        for j = 1:numSatelites 
            % this is the function we are trying to minimize for each satelite
            fSym(j) = (x - A(j))^2 + (y - B(j))^2 + (z - C(j))^2 - (signalspeed * (t(j) - d))^2;
        end
        fSym = fSym';
        JSym = jacobian(fSym, [x, y, z, d]);
    
        f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
        J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);
        f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
        J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));
    
        x = newtons_method_n2(f_wrapper, J_wrapper, x0); % numerical solution!
        error(1,i) = norm(x(1:3)' - initialPosActual);
        xAll(:, i) = x;
    
        if mod(i, 10) == 0
            disp(i)
        end
    
    end



end
