%% The post function
function xp = sys_post(x, u, options)
    
    Ts = options.Ts;
    
    % coordinate !
    if all(size(x) == [1 5])
        xp = sys_post_5d(Ts, x, u);
    elseif all(size(x) == [1 7])
        xp = sys_post_7d(Ts, x, u);
    else
        error('invalid dim !');
    end
    
end