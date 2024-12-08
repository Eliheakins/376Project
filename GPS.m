%%Solution for suggested activity 1

clear all; clc;
format long;
c = 299792.458; %from textbook, km/sec signal speed
pos = [15600, 7540, 20140; 18760, 2750, 18610; 17610, 14630, 13480; 19170, 610, 18390];
t = [0.07074; 0.07220; 0.07690; 0.07242];
x0 = [0; 0; 6370; 0];
A = pos(:,1); B = pos(:,2); C = pos(:,3);

syms x y z d

fSym=sym([]);
for i=1:length(A)
    fSym(i)=(x-A(i))^2 + (y-B(i))^2 + (z-C(i))^2 - (c*(t(i)-d))^2;
end
fSym=fSym';

JSym = jacobian(fSym, [x, y, z, d]);

f_num = matlabFunction(fSym, 'Vars', [x, y, z, d]);
J_num = matlabFunction(JSym, 'Vars', [x, y, z, d]);

f_wrapper = @(v) f_num(v(1), v(2), v(3), v(4));
J_wrapper = @(v) J_num(v(1), v(2), v(3), v(4));

[x] = newtons_method_n(f_wrapper, J_wrapper, x0);

disp('Solution:');
disp(x);
