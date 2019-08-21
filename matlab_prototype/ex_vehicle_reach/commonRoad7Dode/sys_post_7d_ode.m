function x_acc_st = sys_post_7d_ode(tFinal, x0, u)

    persistent p;
    if isempty(p)
        p = parameters_vehicle2;
    end


    %simulate single-track model
    [~,x_acc_st] = ode45(getfcn(@vehicleDynamics_ST,u,p),[0, tFinal],x0);
    x_acc_st = x_acc_st(end,:);

    % add input and parameters to ode 
    function [handle] = getfcn(fctName,u,p)

        function dxdt = f(t,x)
            dxdt = fctName(x,u,p);
        end

        handle = @f;
    end
end