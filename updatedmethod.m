function x = updatedmethod(f_wrapper, J_wrapper, x0)
    tol = 1e-6;  
    max_iter = 100; % otherwise too slow
    x = x0;
    for iter = 1:max_iter
        f_val = f_wrapper(x);
        J_val = J_wrapper(x);
        
        % A'*A * delta = A'*b ==> delta = inv(A'A)*A'b
        delta = -pinv(J_val' * J_val) * J_val' * f_val; 
        %delta = -pinv(J_val)*f_val;
        x = x +delta;
        if mod(iter,49)
            % disp("   iter mod 49");
        end
        %gamma = 0.01;
        if norm(f_val) < tol
            break;
        end
        
        %nextx = x - gamma*J_val;
        %x = nextx; 
        %if norm(J_wrapper(x))<tol
         %   break;
        %end
        % x = x + delta;
        %if norm(delta) < tol
         %   break;
        %end
    end
    %disp(norm(f_val))
end
