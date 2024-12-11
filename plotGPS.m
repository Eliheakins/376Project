function [] = plotGPS(estPos, actualPos, satPos)
    % Earth parameters
    earth_radius = 6370; 

    % Create a sphere for Earth
    [x, y, z] = sphere(50);
    surf(x * earth_radius, y * earth_radius, z * earth_radius, 'FaceColor', 'black', 'EdgeColor', 'none');
    hold on;
    
    % Plot satellite positions (no labels)
    scatter3(satPos(:, 1), satPos(:, 2), satPos(:, 3), 100, 'red', 'filled');
    
    % Plot actual positions of the target (no labels)
    scatter3(actualPos(1, :), actualPos(2, :), actualPos(3, :), 50, 'green', 'filled');
    
    % Plot the path of the actual target (a line connecting the actual positions)
    plot3(actualPos(1, :), actualPos(2, :), actualPos(3, :), 'g-', 'LineWidth', 2);

    % Plot estimated positions of the target (no labels)
    scatter3(estPos(1, :), estPos(2, :), estPos(3, :), 50, 'blue', 'filled');
    
    % Plot the path of the estimated target (a line connecting the estimated positions)
    plot3(estPos(1, :), estPos(2, :), estPos(3, :), 'b-', 'LineWidth', 2);

    % Plot settings
    title('Satellite and Target Positions Above Earth');
    xlabel('X (km)');
    ylabel('Y (km)');
    zlabel('Z (km)');
    grid on;
    axis equal;
    hold off;
end
