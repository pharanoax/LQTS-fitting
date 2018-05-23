close;
clear;
clc;

[VOI, STATES, ALGEBRAIC, CONSTANTS] = Paci();

is_baseline = islocalmin(STATES(:,1),'MaxNumExtrema', 3);

baseline_idx = find(is_baseline);

plot(VOI,STATES(:,1))

hold on

AP_start = baseline_idx(1);
AP_end = baseline_idx(2);

plot(VOI(AP_start:AP_end),STATES(AP_start:AP_end,1),'magenta')
