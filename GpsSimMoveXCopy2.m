clear all; clc; close all; 
signalspeed = 299792.458;
numSatelites = 6; % Variable for the number of satellites

satZ = 26570;
pos = [];
phi = pi/6;
theta = linspace(0, 2*pi, numSatelites + 1); % Adjusted for numSatelites
 
% Position calculation loop
for i = 1:numSatelites
    pos(i, :) = [
        satZ * cos(phi) * cos(theta(i)),
        satZ * cos(phi) * sin(theta(i)),
        satZ * sin(phi)
    ];
end

surfaceZ = 6370;
numMoves = 100;
xAll = zeros(4, numMoves);
error = zeros(1, numMoves);
stepdist = 0.1; 

for i = 1:numMoves
    initialPosActual = [(i-1) * stepdist, 0, surfaceZ];
    distance = zeros(numSatelites,1);
    for j = 1:numSatelites
        distance(j) = norm(pos(j, :) - initialPosActual);
    end
    t = distance ./ signalspeed;
    noise_level = (1e-11) * i; % Adjust as needed to simulate noise magnitude
    t = t + noise_level * randn(size(t)); 

    % Calculate position
    x0 = [0; 0; 6370; 0];
    % A = x positions of all the sats
    % B = y positions of all the sats
    % C = z positions of all the sats
    A = pos(:, 1); B = pos(:, 2); C = pos(:, 3);

    syms x y z d

    fSym = sym([]); % Initialize fSym as a column vector
    for j = 1:numSatelites % CHANGED
        fSym(j) = (x - A(j))^2 + (y - B(j))^2 + (z - C(j))^2 - (signalspeed * (t(j) - d))^2;
    end
    fSym = fSym';

    JSym = jacobian(fSym, [x, y, z, d]);

    f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
    J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);

    f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
    J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));


    x = newtons_method_n2(f_wrapper, J_wrapper, x0);
    if mod(i, 10) == 0
        disp(i)
    end
    error(1,i) = norm(x(1:3)' - initialPosActual);
    xAll(:, i) = x;
end

plot(1:numMoves, error)
