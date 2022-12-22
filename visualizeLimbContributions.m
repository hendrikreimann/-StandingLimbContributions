function visualizeLimbContributions(C_l_total, C_r_total, C_w_total, c_l_timeseries, c_r_timeseries, c_w_timeseries, cop_ap_dot, sampling_frequency)
% VISUALIZELIMBCONTRIBUTIONS visualizes the results of CALCULATELIMBCONTRIBUTIONS
%
%   Input:
%       C_l_total       - total contribution of the _left_ foot CoP shift to the whole-body CoP shift
%       C_r_total       - total contribution of the _right_ foot CoP shift to the whole-body CoP shift
%       C_w_total       - total contribution of the weight shift between the two feet to the whole-body CoP shift
%       c_l_timeseries  - timeseries of instantaneous contribution of the _left_ foot CoP shift
%       c_r_timeseries  - timeseries of instantaneous contribution of the _right_ foot CoP shift
%       c_w_timeseries  - timeseries of instantaneous contribution of the weight shift
%       p_ap_dot        - timeseries of total instantaneous CoP velocity
%       sampling_frequency  - sampling frequency of the timeseries, in Hz
%
%   See also CALCULATELIMBCONTRIBUTIONS

    % construct time
    number_of_data_points = numel(c_l_timeseries);
    total_time = number_of_data_points / sampling_frequency;
    time = linspace(1/sampling_frequency, total_time, number_of_data_points)';

    % create figure and layout
    figure;
    tiledlayout(1, 3, "padding", "loose")
    colors = lines(3);

    % plot total contributions
    nexttile(1) ; hold on;
    title('Total contributions')
    plot([0.8 3.2], [0 0], 'color', [0.5 0.5 0.5])
    plot([0.8 3.2], [1 1], 'color', [0.5 0.5 0.5])
    plot(1, C_l_total, 'd', 'markersize', 20, 'markeredgecolor', 'none', 'markerfacecolor', colors(1, :));
    plot(2, C_r_total, 'd', 'markersize', 20, 'markeredgecolor', 'none', 'markerfacecolor', colors(2, :));
    plot(3, C_w_total, 'd', 'markersize', 20, 'markeredgecolor', 'none', 'markerfacecolor', colors(3, :));
    set(gca, 'xtick', [1 2 3], 'xticklabel', {'Left', 'Right', 'Weight Shift'})
    set(gca, 'XLim', [0.8 3.2], 'ylim', [-0.1 1.1])
    ylabel('Relative Contribution');

    % plot instantaneous contributions over time
    nexttile(2, [1, 2]); hold on;
    title('Instantaneous contributions')
    plot(time, c_l_timeseries, 'linewidth', 2, 'displayname', 'Left');
    plot(time, c_r_timeseries, 'linewidth', 2, 'displayname', 'Right');
    plot(time, c_w_timeseries, 'linewidth', 2, 'displayname', 'Weight Shift');
    plot(time, cop_ap_dot, 'displayname', 'CoP velocity');
    legend('show')
    xlabel('time (s)')
    ylabel('absolute contribution to CoP movement')
    
end