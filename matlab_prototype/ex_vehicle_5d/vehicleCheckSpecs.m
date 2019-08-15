% returns a value from 0 to one ranking the trace's qualitty
% in satisfying the problem
% 0: has subtrace that violates the speccs.
% +: the trace satisfys fully the speccs.
function [q,xs] = vehicleCheckSpecs(u_flat_trace, options)

    T = length(u_flat_trace);
    xs = nan*ones(length(options.initial_state),T+1);
    
    % reachability
    x = options.initial_state;
    q = 1;
    xs(:,1) = x';
    for t=1:T
        u = options.is_quantizer.desymbolize(options.is_quantizer.unflatten(u_flat_trace(t)));
        x = sys_post(x,u);
        xs(:,t+1) = x';
        if isInsideHyperRect(x(1:2),[options.AvoidSet_lb; options.AvoidSet_ub])
            q = 0;
            xs = xs(:,1:t+1);
            return;
        elseif isInsideHyperRect(x(1:2),[options.TargetSet_lb; options.TargetSet_ub])
            q = 1;
            xs = xs(:,1:t+1);
            return;
        elseif x(1) < 0 || x(2) < 0 % prevent negative sides
            q = 0;
            xs = xs(:,1:t+1);
            return;
        else
            new_q = 1-norm(x(1:2)-options.TargetSetCenter)/options.SpaceDiameter;
            q = (q + new_q)/2;
        end
    end
end

