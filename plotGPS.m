function [] = plotGPS(estPos, actualPos, satPos)
    % Earth parameters
    earth_radius = 6370; 

    % Create a sphere for Earth
    [x, y, z] = sphere(50);
    h_earth = surf(x * earth_radius, y * earth_radius, z * earth_radius, ...
                   'FaceColor', 'black', 'EdgeColor', 'none');
    hold on;
    
    % Plot satellite positions
    h_sat = scatter3(satPos(:, 1), satPos(:, 2), satPos(:, 3), 100, 'red', 'filled');
    
    % Plot the positions of the actual target (without connecting lines)
    h_actual_start = scatter3(actualPos(1, 1), actualPos(2, 1), actualPos(3, 1), ...
                              200, 'green', 'o', 'filled');
    h_actual_end = scatter3(actualPos(1, end), actualPos(2, end), actualPos(3, end), ...
                            200, 'yellow', 'o', 'filled');
    h_actual_points = scatter3(actualPos(1, :), actualPos(2, :), actualPos(3, :), ...
                               50, 'green', 'o', 'filled');  % Actual target points
    
    % Plot the positions of the estimated target (without connecting lines)
    h_est_start = scatter3(estPos(1, 1), estPos(2, 1), estPos(3, 1), 200, 'blue', '^', 'filled');
    h_est_end = scatter3(estPos(1, end), estPos(2, end), estPos(3, end), 200, 'cyan', '^', 'filled');
    h_est_points = scatter3(estPos(1, :), estPos(2, :), estPos(3, :), ...
                            50, 'blue', '^', 'filled');  % Estimated target points

    % Corrected legend order without paths
    legend([h_earth, h_sat, h_actual_points, h_actual_start, h_actual_end, ...
            h_est_points, h_est_start, h_est_end], ...
           {'Earth', 'Satellites', 'Actual Points', 'Actual Start', 'Actual End', ...
            'Estimated Points', 'Est Start', 'Est End'}, ...
           'Location', 'northeastoutside');

    % Plot settings
    title('Satellite and Target Positions Above Earth');
    xlabel('X (km)');
    ylabel('Y (km)');
    zlabel('Z (km)');
    grid on;
    axis equal;
    hold off;
end
