%% The post function
function xp = sys_post(x, u)
    if nargin ~= 2
        error('Invalid input !');
    end 
    
    % sampling time
    Ts = 0.10;
    
    % coordinate !
    if all(size(x) == [1 5])
        xp = sys_post_5d(Ts, x, u);
    elseif all(size(x) == [1 7])
        xp = sys_post_7d(Ts, x, u);
    else
        error('invalid dim !');
    end 
    
end