clear all; clc;
%set up coordinates
c = 299792.458;

p=26570;
pos=[];
phi = pi/6;
theta = linspace(0, 2*pi, 5);
for i = 1:4
    pos(i, :) = [
        p * cos(phi) * cos(theta(i)),
        p * cos(phi) * sin(theta(i)),
        p * sin(phi)
    ];
end
surfaceZ=6370;
numMoves=100;
xAll=[];
for i=1:numMoves
    initialPosActual=[(i-1)*.01,0,surfaceZ];
    distance=[];
    for j=1:4
        distance(j)=norm(pos(j,:)-initialPosActual);
    end
    t=distance./c;
    %noise_level = (1e-10)*i; % Adjust as needed to simulate noise magnitude
    %t = t + noise_level * randn(size(t)); 

    
    %calculate pos 
    x0 = [0; 0; 6370; 0];
    A = pos(:,1); B = pos(:,2); C = pos(:,3);
    
    syms x y z d
    
    fSym=sym([]);
    for j=1:length(A)
        fSym(j)=(x-A(j))^2 + (y-B(j))^2 + (z-C(j))^2 - (c*(t(j)-d))^2;
    end
    fSym=fSym';
    
    JSym = jacobian(fSym, [x, y, z, d]);
    
    f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
    J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);
    
    f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
    regularization_term = 1e-6; % Needed regularization due to illconditioned Jacobian resulting in NaN
    J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4)) + regularization_term * eye(4);
    
    x = newtons_method_n(f_wrapper, J_wrapper, x0);
    if mod(i,10)==0
        disp(i)
    end
    error(i)=norm(x(1:3)'-initialPosActual);
    xAll(i,:)=x;
end
plot(3:numMoves,error(3:end))
