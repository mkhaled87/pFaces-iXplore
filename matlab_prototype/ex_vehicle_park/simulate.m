close all
clear
clc

bestTraces_fw = load('bestTraces_fw.mat');
bestTraces_bw = load('bestTraces_bw.mat');

fw_best_idx = max(find(isnan(bestTraces_fw.bestTraces(:,1)) == 0));
bw_best_idx = max(find(isnan(bestTraces_bw.bestTraces(:,1)) == 0));


bestTrace_fw = bestTraces_fw.bestTraces(fw_best_idx,:);
bestTrace_bw = bestTraces_bw.bestTraces(bw_best_idx,:);

bestTrace_fw = bestTrace_fw(~isnan(bestTrace_fw));
bestTrace_bw = bestTrace_bw(~isnan(bestTrace_bw));

% FW trajectory
is_lb_fw = [-0.4, -1.0];
is_ub_fw = [+0.4, +1.0];
is_eta_fw = [0.2,  2.0];
options_fw.is_quantizer = NdQuantizer(is_lb_fw,is_ub_fw, is_eta_fw, zeros(size(is_lb_fw)));
options_fw.Ts = 0.100;
options_fw.initial_state = [1 1 0 0 0 0 0];
options_fw.AvoidSet_lb = [0 2.25];
options_fw.AvoidSet_ub = [5 2.75];
options_fw.TargetSet_lb = [8.75 2.25 -0.25 -0.25 -0.25];
options_fw.TargetSet_ub = [9.25 2.75 +0.25 +0.25 +0.25];
options_fw.SpaceDiameter = 12;
options_fw.TargetSetCenter = [9 2.5 0 0 0 0 0];
[~, trajectory_fw] = vehicleCheckSpecs_fw(bestTrace_fw, options_fw);


% BW trajectory
is_lb_bw = [-0.6, -1.0];
is_ub_bw = [+0.6, +0.0];
is_eta_bw = [0.3,  1.0];
options_bw.is_quantizer = NdQuantizer(is_lb_bw,is_ub_bw, is_eta_bw, zeros(size(is_lb_bw)));
options_bw.AvoidSet_lb = [0 2.25];
options_bw.AvoidSet_ub = [5 2.75];
options_bw.TargetSet_lb = [0.5 3];
options_bw.TargetSet_ub = [2.5 4];
options_bw.SpaceDiameter = 12;
options_bw.TargetSetCenter = [1.5 3.5 0 0 pi];
options_bw.initial_state = [8.96 2.43 0 0 0];
options_bw.Ts = 0.100;
[~, trajectory_bw] = vehicleCheckSpecs_bw(bestTrace_bw, options_bw);


%prepare
trajectory = trajectory_fw(1:5,:);
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory_bw(1:5,:)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];
trajectory = [trajectory trajectory(:,end)];


% simple plot
figure;
title('XY Trajectory');
hold on;

avoid_hr = ...
   [options_fw.AvoidSet_lb(1) options_fw.AvoidSet_ub(1) ...
    options_fw.AvoidSet_lb(2) options_fw.AvoidSet_ub(2)];

target_hr = ...
   [options_bw.TargetSet_lb(1) options_bw.TargetSet_ub(1) ...
    options_bw.TargetSet_lb(2) options_bw.TargetSet_ub(2)];    

rectangle('Position',[target_hr(1) target_hr(3) (target_hr(2)-target_hr(1)) (target_hr(4)-target_hr(3))], 'FaceColor', 'blue' ,'LineWidth',3);
rectangle('Position',[avoid_hr(1) avoid_hr(3) (avoid_hr(2)-avoid_hr(1)) (avoid_hr(4)-avoid_hr(3))], 'FaceColor', 'red' ,'LineWidth',3);    

plot(trajectory(1,:),trajectory(2,:));

axis([-1 10 -1 10]);
grid on;


% moving car by simulink
time_values = 0:options_fw.Ts:(length(trajectory(1,:))-1)*options_fw.Ts;
end_time = time_values(end);
vehicleXvalues = timeseries(trajectory(1,:), time_values);
vehicleYvalues = timeseries(trajectory(2,:), time_values);
vehicleAvalues = timeseries(trajectory(5,:), time_values);
open('../vehicleXYsim/vehicleXYsim.slx');



