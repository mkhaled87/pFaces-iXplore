function [best_traces, best_qualities, finished_slots] = solveBranchAndBound(specsChecker, options)

   
    % branch N bound
    % ---------------
    % global_time_bound (in time steps) represents the upper bound on the length of any trace
    % max_traces represents the maximum number of traces we can process in
    % one branch episode. we then need is_size^branch_depth <= max_traces.
    global_time_bound = options.global_time_bound;
    max_traces = options.max_traces;
    branch_depth = floor(log(max_traces)/log(options.is_quantizer.getNumSymbols()));
    num_slots = global_time_bound/branch_depth;
    traces_per_slot = (options.is_quantizer.getNumSymbols())^branch_depth;
    
    if options.verbose
        disp(['solveBranchAndBound: Input space size: ' num2str(options.is_quantizer.getNumSymbols())]);
        disp(['solveBranchAndBound: Number of slots: ' num2str(num_slots)]);
        disp(['solveBranchAndBound: Time depth of each slot: ' num2str(branch_depth)]);
        disp(['solveBranchAndBound: Number of traces searched in each slot: ' num2str(traces_per_slot)]);
        disp(['solveBranchAndBound: Non-optimized search space size: ' num2str((options.is_quantizer.getNumSymbols())^(branch_depth*num_slots))]);
        disp(['solveBranchAndBound: Optimized search space size: <= ' num2str((options.is_quantizer.getNumSymbols())^(branch_depth)*num_slots)]);
        
    end

    % memory for the traces and their qualities
    full_traces = nan*ones(traces_per_slot^2, global_time_bound);
    traces_quality = zeros(traces_per_slot^2,1);
    best_traces = nan*ones(num_slots,global_time_bound);
    best_qualities = zeros(num_slots,1);

    % format for conversion
    format = ['%0' num2str(branch_depth) 'd'];

    % for each slot
    for s=1:num_slots

        % for all of the traces in the two slot
        for previous_u_trace_flat=1:traces_per_slot
            for u_trace_flat=1:traces_per_slot

                % convert trance idex to u_flat sequences
                f = u_trace_flat-1;
                f = num2str(f, format);
                f = f - '0';
                u_flat_seq = base2base(f, 10, options.is_quantizer.getNumSymbols());
                for n = 1:branch_depth-length(u_flat_seq)
                    u_flat_seq = [0 u_flat_seq];
                end

                % the full seq from the beginning
                trace_idx = (previous_u_trace_flat-1)*traces_per_slot + u_trace_flat;
                if s == 1
                    full_u_flat_seq = u_flat_seq;
                else
                    full_u_flat_seq = [full_traces(trace_idx,1:(s-1)*branch_depth) u_flat_seq];
                end

                % compute its quality
                q = specsChecker(full_u_flat_seq, options);

                % put the trace in mem
                start_time = (s-1)*branch_depth + 1;

                if s == 1 % replicate the line in
                    full_traces((u_trace_flat-1)*traces_per_slot+1:u_trace_flat*traces_per_slot,1:branch_depth) = repmat(u_flat_seq, traces_per_slot, 1);
                    traces_quality((u_trace_flat-1)*traces_per_slot+1:u_trace_flat*traces_per_slot,1) = q*ones(traces_per_slot,1);
                else % do normally once
                    full_traces(trace_idx, start_time:start_time+branch_depth-1) = u_flat_seq;
                    traces_quality(trace_idx,1) = q;    
                end

            end
            % only need once at s=1 as we already expanded the traces
            if s == 1
                break;
            end
        end

        % sort the traces
        [sorted_qualities, sorted_indicies] = sort(traces_quality,'descend');

        % sort the blobal memory based on current sprt results
        full_traces = full_traces(sorted_indicies,:);
        best_traces(s,:) = full_traces(1,:);
        best_qualities(s) = sorted_qualities(1,1);
        
        finished_slots = s;
        
        if options.break_if_found && sorted_qualities(1,1) == 1
            if options.verbose
                disp(['solveBranchAndBound: Finshed because no traces were found !']);
            end           
            return;
        end
        
        if options.break_if_all_traces_fail && sorted_qualities(1,1) == 0
            if options.verbose
                disp(['solveBranchAndBound: Finshed because a trace wss found !']);
            end
            return;
        end
        
        if options.verbose
            disp(['solveBranchAndBound: Slot #' num2str(s) ' is done (reached t = ' num2str(s*branch_depth) ' steps)!']);
        end
    end
end