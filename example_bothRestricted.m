% load data
load testdata_bothRestricted.mat

% calculate contributions
[C_l_total, C_r_total, C_w_total, c_l_timeseries, c_r_timeseries, c_w_timeseries, cop_ap_dot] ...
    = calculateLimbContributions(copxl, copxr, fzl_filt, fzr_filt, sampling_frequency);

% visualize results
visualizeLimbContributions(C_l_total, C_r_total, C_w_total, c_l_timeseries, c_r_timeseries, c_w_timeseries, cop_ap_dot, sampling_frequency)
