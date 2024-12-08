earth_radius = 6370; 
[x, y, z] = sphere(50);
surf(x * earth_radius, y * earth_radius, z * earth_radius, 'FaceColor', 'blue', 'EdgeColor', 'none');
hold on;

scatter3(pos(:, 1), pos(:, 2), pos(:, 3), 100, 'red', 'filled');
text(pos(:, 1), pos(:, 2), pos(:, 3), arrayfun(@(i) sprintf('S%d', i), 1:4, 'UniformOutput', false), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', 'black');

title('Satellite Positions Above Earth');
xlabel('X (km)');
ylabel('Y (km)');
zlabel('Z (km)');
grid on;
axis equal;
hold off;