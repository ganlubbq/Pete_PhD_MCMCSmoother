clup

% Set test flag
for test_flag = [1,2,3];
    
    test_case = test_flag;
    
    % Load data
    load(['smoother_test' num2str(test_flag) '.mat']);
    
    % RMSEs
    fig = figure; hold on
    inds = 2; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_pos_rmse, results(inds)), 'ok', 'markersize', 7 )
    inds = 3; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_pos_rmse, results(inds)), 'r^', 'markersize', 7 )
    inds = 4:8; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_pos_rmse, results(inds)), '*-b', 'markersize', 7 )
    inds = 9:13; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_pos_rmse, results(inds)), 'x-.g', 'markersize', 7 )
    
    legend('FS', 'D-FFBS', 'MH-FFBS (M=1-100)', 'MH-FFBP (M=1-100)');
    xlabel('Running Time (s)'); ylabel('Position RMSE');
    xlimits = get(gca, 'XLim');
    ylimits = get(gca, 'YLim');
    xlim([-50, xlimits(2)]);
    plot([0 0], ylimits, ':k');
    ylim(ylimits);
    
    export_pdf(fig, ['case' num2str(test_case) '_smoother_comparison_posRMSE_time.pdf']);
    
    % MNEESs
    fig = figure; hold on
    inds = 2; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_nees, results(inds)), 'ok', 'markersize', 7 )
    inds = 3; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_nees, results(inds)), 'r^', 'markersize', 7 )
    inds = 4:8; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_nees, results(inds)), '*-b', 'markersize', 7 )
    inds = 9:13; plot( cellfun(@(x) x.times, results(inds)), cellfun(@(x) x.mean_nees, results(inds)), 'x-.g', 'markersize', 7 )
    
    legend('FS', 'D-FFBS', 'MH-FFBS (M=1-100)', 'MH-FFBP (M=1-100)');
    xlabel('Running Time (s)'); ylabel('ENEES');
    xlimits = get(gca, 'XLim');
    ylimits = [0.75 1];
    xlim([-50, xlimits(2)]);
    plot([0 0], ylimits, ':k');
    ylim(ylimits);
    
    export_pdf(fig, ['case' num2str(test_case) '_smoother_comparison_ENEES_time.pdf']);
    
    %%% Trajectories
    
    % DEFINE RANDOM SEED
    rand_seed = 1;
    
    % Set random seed
    s = RandStream('mt19937ar', 'seed', rand_seed);
    RandStream.setDefaultStream(s);
    
    % Set parameters
    set_parameters;
    
    if test_flag == 1
        params.bng_var = (pi/720)^2;
        params.rng_var = 0.1;
    elseif test_flag == 2
        params.bng_var = (pi/36)^2;
        params.rng_var = 0.1;
    elseif test_flag == 3
        params.bng_var = (pi/36)^2;
        params.rng_var = 100;
    end
    
    %% Generate some Bearings only tracking data
    [ t, x, y ] = generate_radar_data;
    
    % Plot it
    xmax = max(max(abs(x(1:2,:))))+5;
    fig = figure; hold on; xlim([-xmax, xmax]); ylim([-xmax, xmax]);
    plot(x(1,:), x(2,:), 'b', 'linewidth', 3);
    [x_obs, y_obs] = pol2cart(y(1,:), y(2,:)); plot(x_obs, y_obs, 'r');
    plot(0, 0, 'xk', 'markersize', 10)
    legend('Target Position', 'Observations', 'Location', 'SouthWest')
    xlabel('x coordinate'); ylabel('y coordinate');
    
    % Add some covariance ellipses
    plot_banana( gcf, x(:,1), params.rng_var, params.bng_var, 2 )
    plot_banana( gcf, x(:,end), params.rng_var, params.bng_var, 2 )
    
    xlim([-300, 50]);
    ylim([-50, 300]);
    
    export_pdf(fig, ['case' num2str(test_case) '_trajectory.pdf'], 4, 4, 'inches');
    
%     pos = get(gca, 'Position');
%     set(gca, 'Position', [pos(1), pos(2), pos(3), pos(3)]);
    
end

%%

resstruct = cell2mat(results);
table = [[resstruct.mean_pos_rmse]', [resstruct.mean_vel_rmse]', [resstruct.mean_nees]', [resstruct.times]', mean(cat(1,resstruct.unique_pts),2)];
for line = 2:size(table, 1);
    fprintf(1, '%.2f & %.2f & %.2f & %.2f & %.2f \\\\ \n', table(line,:));
    if any(line==[3,8])
        fprintf(1, '\n');
    end
end