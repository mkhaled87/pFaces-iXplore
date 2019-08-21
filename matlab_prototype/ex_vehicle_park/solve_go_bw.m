clear
clc
addpath('../src/');


is_lb = [-0.6, -1.0];
is_ub = [+0.6, +0.0];
is_eta = [0.3,  1.0];

options.is_quantizer = NdQuantizer(is_lb,is_ub, is_eta, zeros(size(is_lb)));
options.global_time_bound = 150;
options.max_traces = 650;
options.break_if_all_traces_fail = true;
options.break_if_found = true;
options.verbose = true;
options.AvoidSet_lb = [0 2.25];
options.AvoidSet_ub = [5 2.75];
options.TargetSet_lb = [0.5 3];
options.TargetSet_ub = [2.5 4];
options.SpaceDiameter = 12;
options.TargetSetCenter = [1.5 3.5 0 0 pi];
options.initial_state = [8.96704944893547 ...
                         2.43652682576407 ...
                         0 0 0];
options.Ts = 0.100;


[bestTraces, bestQualities, finished_slots] = ...
    solveBranchAndBound(@vehicleCheckSpecs_bw, options);

% info
if(bestQualities(finished_slots) == 0)
    disp('Done [FAILURE]: destiny took us to place where all traces fails the specs !');
elseif(bestQualities(finished_slots) == 1)
    disp('Done [SUCCESS]: found one or more traces that satisfy the specs: ');

    figure;
    title('XY Trajectory');
    hold on;

    bestTrace = bestTraces(finished_slots,:);
    [how_good, trajectory] = vehicleCheckSpecs_bw(bestTrace, options);

    avoid_hr = ...
       [options.AvoidSet_lb(1) options.AvoidSet_ub(1) ...
        options.AvoidSet_lb(2) options.AvoidSet_ub(2)];
    
    target_hr = ...
       [options.TargetSet_lb(1) options.TargetSet_ub(1) ...
        options.TargetSet_lb(2) options.TargetSet_ub(2)];    
    
    rectangle('Position',[target_hr(1) target_hr(3) (target_hr(2)-target_hr(1)) (target_hr(4)-target_hr(3))], 'FaceColor', 'blue' ,'LineWidth',3);
    rectangle('Position',[avoid_hr(1) avoid_hr(3) (avoid_hr(2)-avoid_hr(1)) (avoid_hr(4)-avoid_hr(3))], 'FaceColor', 'red' ,'LineWidth',3);    
    
    plot(trajectory(1,:),trajectory(2,:));
    
    axis([-1 10 -1 10]);
    grid on;
    
    
    figure;
    title('All state valyues over time');
    hold on;
    dim = length(options.initial_state);
    end_time = options.Ts*(length(trajectory(1,:)) - 1);
    time = 0:options.Ts:end_time;
    for i=1:dim
        subplot(dim,1,i);
        plot(time, trajectory(i,:));
    end
    
else
    disp('Done [UNKNOWN]: We couldt find a trace satisfying the specs in the given time !');
end
    