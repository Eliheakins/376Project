function x = newtons_method_n2(f_wrapper, J_wrapper, x0)
    tol = 1e-6; 
    max_iter = 100; % otherwise too slow
    x = x0;
    for iter = 1:max_iter
        f_val = f_wrapper(x);
        J_val = J_wrapper(x);
        
        % A'*A * delta = A'*b
        % delta = inv(A'A)*A'b
        delta = -pinv(J_val' * J_val) * J_val' * f_val;
        
        x = x + delta;
        if norm(delta) < tol
            break;
        end
    end
end
