% returns a value from 0 to one ranking the trace's qualitty
% in satisfying the problem
% 0: has subtrace that violates the speccs.
% +: the trace satisfys fully the speccs.
function [q,xs] = vehicleCheckSpecs_bw(u_flat_trace, options)

    T = length(u_flat_trace);
    xs = nan*ones(length(options.initial_state),T+1);
    
    % reachability
    x = options.initial_state;
    q = 1;
    xs(:,1) = x';    
    for t=1:T
        u = options.is_quantizer.desymbolize(options.is_quantizer.unflatten(u_flat_trace(t)));
        x = sys_post(x,u,options);
        xs(:,t+1) = x';
        
%        ref_vec = options.TargetSetCenter(1:2) - x(1:2);
%        ref_vec = [ref_vec 0];
%        curr_vec = (xs(1:2,t+1) - xs(1:2,t))'; 
%        curr_vec = [curr_vec 0];
%        angle_deviation_1 = atan2(norm(cross(ref_vec,curr_vec)), dot(ref_vec,curr_vec));
%        angle_deviation_2 = atan2(norm(cross(curr_vec,ref_vec)), dot(curr_vec,ref_vec));
%        angle_deviation = min(angle_deviation_1, angle_deviation_2);
        
        if isInsideHyperRect(x(1:length(options.AvoidSet_lb)),[options.AvoidSet_lb; options.AvoidSet_ub])
            q = 0;
            xs = xs(:,1:t+1);
            return;
        elseif isInsideHyperRect(x(1:length(options.TargetSet_lb)),[options.TargetSet_lb; options.TargetSet_ub])
            q = 1;
            xs = xs(:,1:t+1);
            return;
        elseif x(1) < 0 || x(2) < 0 % prevent negative sides
            q = 0;
            xs = xs(:,1:t+1);
            return;
%        elseif x(2) < 3 && xs(1,t) > xs(1,t+1) % are we moving left when we are below the obstacle ?
%            q = 0;
%            xs = xs(:,1:t+1);
%            return;            
        elseif x(2) > 3 && xs(1,t) < xs(1,t+1) % are we moving right when we are above the obstacle ?
            q = 0;
            xs = xs(:,1:t+1);
            return;                        
%        elseif x(2) >= 5 % more restrictive: prevent exceding y=5
%            q = 0;
%            xs = xs(:,1:t+1);
%            return;  
%        elseif all(xs(:,t) == xs(:,t+1)) % am i not moving ?
%            q = 0;
%            xs = xs(:,1:t+1);
%            return;              
%        elseif angle_deviation > 0.50 % max deviation from target orientation is 23 deg angle
%            q = 0;
%            xs = xs(:,1:t+1);
%            return;                          
        else
            new_q = 1-distance(x, options.TargetSetCenter)/options.SpaceDiameter;
            q = (q + new_q)/2;
        end
    end
    
    
    % a distanc function
    function d=distance(x,y)
        
        %old
        %d = norm(x-y);
        
        % new: weighted one
        d1 = x(1:2)-y(1:2);
        d2 = x(3:end)-y(3:end);
        
        w1 = 0.8;
        w2 = 0.2;
        
        d = sqrt(sum(w1*(d1.^2)) + sum(w2*(d2.^2)));
    end
    
end

