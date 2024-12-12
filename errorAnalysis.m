load('errors_data.mat');
visualizeErrors(errors, numSatelitesRange, maxIter);

function visualizeErrors(errors, numSatelitesRange, maxIter)
    % Mean Error Trend
    meanErrors = cellfun(@mean, errors);
    figure;
    plot(numSatelitesRange, meanErrors, '-s', 'LineWidth', 1.5, 'MarkerSize', 8);
    xlabel('Number of Satellites');
    ylabel('Mean Error');
    title('Mean Error Across Satellite Counts');
    grid on;

    % Box Plot
    errorMatrix = cell2mat(cellfun(@(x) reshape(x, 1, []), errors, 'UniformOutput', false)');
    figure;
    boxplot(errorMatrix', numSatelitesRange);
    xlabel('Number of Satellites');
    ylabel('Error');
    title('Error Distribution Across Satellite Counts');
    grid on;
end