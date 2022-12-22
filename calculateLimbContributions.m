function [C_l_total, C_r_total, C_w_total, c_l_timeseries, c_r_timeseries, c_w_timeseries, cop_ap_dot] ...
    = calculateLimbContributions(cop_ap_l, cop_ap_r, f_vert_l, f_vert_r, sampling_frequency)
% CALCULATELIMBCONTRIBUTIONS  Calculate how much each leg and weight
% shifting between the legs contribute to balance control in standing
%
%   [C_l_total, C_r_total, C_w_total] = CALCULATELIMBCONTRIBUTIONS(cop_ap_l, cop_ap_r, f_vert_l, f_vert_r, sampling_frequency) 
%   calculates the contributions of the left leg center of pressure (CoP) shift, right leg CoP shift, and weight shift 
%   to the total CoP shift. *Note: Input data should be filtered, or calculation of the CoP velocity will not work
%   well.*
%   Input:
%       cop_ap_l            - timeseries of the CoP under the _left_ foot, in anterior-posterior direction
%       cop_ap_r            - timeseries of the CoP under the _right_ foot, in anterior-posterior direction
%       f_vert_l            - timeseries of the vertical ground reaction force under the _left_ foot
%       f_vert_r            - timeseries of the vertical ground reaction force under the _right_ foot
%       sampling_frequency  - sampling frequency of the timeseries, in Hz
%   Output:
%       C_l_total       - total contribution of the _left_ foot CoP shift to the whole-body CoP shift
%       C_r_total       - total contribution of the _right_ foot CoP shift to the whole-body CoP shift
%       C_w_total       - total contribution of the weight shift between the two feet to the whole-body CoP shift
%       c_l_timeseries  - timeseries of instantaneous contribution of the _left_ foot CoP shift
%       c_r_timeseries  - timeseries of instantaneous contribution of the _right_ foot CoP shift
%       c_w_timeseries  - timeseries of instantaneous contribution of the weight shift
%       p_ap_dot        - timeseries of total instantaneous CoP velocity
%       
%   The total contributions are normalized so that they add up to 1. Individual contributions can be negative or > 1.
%
%   Example 1: example.m is an example for quiet standing with eyes closed.
%
%   Example 2: example_leftRestricted.m is an example for standing with the left foot on a small cylinder (roll of tape)
%       to restrict CoP movement.
%
%   Example 3: example_bothRestricted.m is an example for standing with both feet on small cylinders to restrict
%       CoP movement. Feet were also displaced in the anterior-posterior direction to allow the weight shift mechanism
%       to act.
%
%   See also VISUALIZELIMBCONTRIBUTIONS

    % validate arguments
    arguments
        cop_ap_l (:,1) double
        cop_ap_r (:,1) double
        f_vert_l (:,1) double
        f_vert_r (:,1) double
        sampling_frequency (1,1) double
    end

    % calculate body weight
    w_total = (f_vert_r + f_vert_l);
    w_r = f_vert_r./w_total;
    w_l = f_vert_l./w_total;
    
    % calculate net center of pressure
    cop_ap_total = cop_ap_r.*w_r + cop_ap_l.*w_l;

    % calculate time derivatives
    number_of_data_points = numel(cop_ap_l);
    total_time = number_of_data_points / sampling_frequency;
    time = linspace(1/sampling_frequency, total_time, number_of_data_points)';
    diff_t = diff(time);
    time_resampling = time(1:end-1) + diff_t*0.5;
    cop_ap_dot = spline(time_resampling, diff(cop_ap_total)./diff_t, time);
    cop_ap_l_dot = spline(time_resampling, diff(cop_ap_l)./diff_t, time);
    cop_ap_r_dot = spline(time_resampling, diff(cop_ap_r)./diff_t, time);
    w_l_dot = spline(time_resampling, diff(w_l)./diff_t, time);

    % calculate contribution timeseries
    c_l_timeseries = w_l .* cop_ap_l_dot .* cop_ap_dot ./ abs(cop_ap_dot);
    c_r_timeseries = (1-w_l) .* cop_ap_r_dot .* cop_ap_dot ./ abs(cop_ap_dot);
    c_w_timeseries = (cop_ap_l - cop_ap_r) .* w_l_dot .* cop_ap_dot ./ abs(cop_ap_dot);
    
    % integrate contributions over time
    C_l = trapz(time, c_l_timeseries);
    C_r = trapz(time, c_r_timeseries);
    C_w = trapz(time, c_w_timeseries);
    cop_ap_dot_abs_integrated = trapz(time, abs(cop_ap_dot));
    
    % normalize to get total relative contributions
    C_l_total = C_l * 1/cop_ap_dot_abs_integrated;
    C_r_total = C_r * 1/cop_ap_dot_abs_integrated;
    C_w_total = C_w * 1/cop_ap_dot_abs_integrated;
end