%% The post function
function xp = sys_post_5d(Ts, x, u)

    if nargin ~= 3
        error('Invalid input !');
    end 
    
    if length(x) ~= 5
        error('Invalid size of x !');
    end     
    if length(u) ~= 2
        error('Invalid size of x !');
    end         

    lwb = 2.578912800000000; 

    % rhs of $\dot x = f(x,u)$
    f(1) = x(4)*cos(x(5));
    f(2) = x(4)*sin(x(5));
    f(3) = u(1);
    f(4) = u(2);
    f(5) = x(4)/lwb*tan(x(3));
    
    % post state for the given Ts
    xp = x + Ts.*f;
     
end