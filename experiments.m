function NOW = experiments(exp1, exp2, exp3, exp4, exp5, exp6)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scaling Causality
%   Tests multiple MVAR parameter estimation methods to derive causality
%   estimations from simulated time series with increasingly large causal
%   networks.
%       - Exp1: For each causality measure with each MVAR estimation method,
%       determine performance and runtime of the estimation on nt trials of
%       data with ns samples, nc channels, no order and exn external noise
%       proportion. Loops are nc -> ns -> no.
%       - Exp2: For all methods, identify the tp, tn, fp, fn of each
%       predicted causality, and its corresponding coupling strength GT.
%       - Exp3: Exp1 but loops are nc -> no -> ns.
%       - Exp4: Exp1 but loops are ns -> no -> nc.
%       - Exp5: Feasibility thresh ns x nc.
%       - Exp6: Feasibility area ns x nc (thresh + timeout).
%
% =========================================================================
% MIT License                                                             %
%                                                                         %
% Copyright (c) 2025, Thomas Pirenne                                      %
%                                                                         %
% Permission is hereby granted, free of charge, to any person obtaining a %
% copy of this software and associated documentation files (the           %
% "Software"), to deal in the Software without restriction, including     %
% without limitation the rights to use, copy, modify, merge, publish,     %
% distribute, sublicense, and/or sell copies of the Software, and to      %
% permit persons to whom the Software is furnished to do so, subject to   %
% the following conditions:                                               %
%                                                                         %
% The above copyright notice and this permission notice shall be included %
% in all copies or substantial portions of the Software.                  %
%                                                                         %
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS %
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF              %
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  %
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY    %
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    %
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       %
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parse exps
    if ~exist("exp1", "var"), exp1 = struct("run", false); end
    if ~exist("exp2", "var"), exp2 = struct("run", false); end
    if ~exist("exp3", "var"), exp3 = struct("run", false); end
    if ~exist("exp4", "var"), exp4 = struct("run", false); end
    if ~exist("exp5", "var"), exp5 = struct("run", false); end
    if ~exist("exp6", "var"), exp6 = struct("run", false); end

    %% Experiment 1
    if exp1.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp1.caus_est_methods;
        mvar_est_methods = exp1.mvar_est_methods;
        ns = exp1.ns;
        nc = exp1.nc;

        % Parse optional parameters (or sets default values)
        if isfield(exp1, "exn"), exn = exp1.exn; else, exn = 0.0; end
        if isfield(exp1, "no"), no = exp1.no; else, no = 10; end
        if isfield(exp1, "nt"), nt = exp1.nt; else, nt = 1; end
        if isfield(exp1, "f1thr"), f1thr = exp1.f1thr; else, f1thr = 1.0; end
        if isfield(exp1, "cutoff"), cutoff = exp1.cutoff; else, cutoff = false; end
        if isfield(exp1, "cutoff_time"), cutoff_time = exp1.cutoff_time; else, cutoff_time = false; end
        if isfield(exp1, "cutoff_time_trial"), cutoff_time_trial = exp1.cutoff_time_trial; else, cutoff_time_trial = false; end
        if isfield(exp1, "cutoffmode"), cutoffmode = exp1.cutoffmode; else, cutoffmode = "following"; end
        if isfield(exp1, "timestamp"), NOW = exp1.timestamp; end
        % if isfield(exp1, "run_all_nc") && exp1.run_all_nc, cut_nc = false; else, cut_nc = true; end
        if isfield(exp1, "skip_cut_of")
            cut_ns = ~any(ismember(exp1.skip_cut_of, 'ns'));
            cut_nc = ~any(ismember(exp1.skip_cut_of, 'nc'));
            cut_no = ~any(ismember(exp1.skip_cut_of, 'no'));
        else
            cut_nc = true;
            cut_ns = true;
            cut_no = true;
        end

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};

                % Saving parameters
                save_path = sprintf('data/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(exn), length(nc), length(ns), length(no), nt);
                f1s = nan(length(exn), length(nc), length(ns), length(no), nt);
                runtimes = nan(length(exn), length(nc), length(ns), length(no), nt);

                % Run estimations
                for eid = 1 : length(exn)
                    % Log advancement
                    % fprintf("exn: %.2f\n", exn(eid));

                    for cid = 1 : length(nc)
                            % Log advancement
                            % fprintf("\t nc: %d\n", nc(cid));

                            % Reset cutoff var to count f1s = 1.0
                            cutoff_count = 0;
                            time_count = 0;
    
                        for sid = 1 : length(ns)
                            % Log advancement
                            % fprintf("\t\t ns: %d (cutoff: %d)\n", ns(sid), cutoff_count);

                            for oid = 1 : length(no)
                                % Log advancement
                                % fprintf("\t\t\t order %d\n", no(oid));

                                % Reset trial_cumulated_time to 0;
                                trial_cumulated_time = 0;

                                for tid = 1 : nt
                                    % Cutoff if over
                                    if (cutoff && cutoff_count > (cutoff - 1)), break; end
        
                                    % Initialize output results
                                    results{eid, cid, sid, oid, tid} = struct();
        
                                    % Simulate data
                                    order = no(oid);
                                    [data, gt] = draft_data(ns(sid), nc(cid), exn(eid), order);
        
                                    % Estimate causality
                                    fprintf("exn: %.2f, nc: %d, ns: %d, order %d, trial %d", exn(eid), nc(cid), ns(sid), no(oid), tid);
                                    timer = tic();
                                    try
                                        [cm, info] = estimate_causality(data, order, est_method, caus_measure);
                                    catch e
                                        cm = nan(nc(cid));
                                        info = struct("error", e);
                                    end
                                    info.runtime = toc(timer);
                                    fprintf("  (%.2f s)\n", info.runtime);

                                    % Keep longest duration among trials
                                    trial_cumulated_time = max([trial_cumulated_time, info.runtime]);
        
                                    % Compute performance results
                                    info.stats = stats_cm(cm, gt);
                                    info.cm = cm;
                                    info.gt = gt;
        
                                    % Store results into containers
                                    results{eid, cid, sid, oid, tid} = info;
                                    f1s(eid, cid, sid, oid, tid) = info.stats.f1;
                                    runtimes(eid, cid, sid, oid, tid) = info.runtime;
                                    time_count = time_count + info.runtime;
        
                                    % Increment cutoff counter if prediction was perfect
                                    if (cutoff_count < cutoff && info.stats.f1 >= f1thr)
                                        cutoff_count = cutoff_count + 1;
                                    elseif (strcmpi(cutoffmode, 'following'))
                                        cutoff_count = 0;
                                    end
                                end

                                % If runtime was too long, break again to stop increasing no
                                if (cut_no && cutoff_time && time_count > cutoff_time), break; end
                                if (cut_no && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                            end

                            % If runtime was too long, break again to stop increasing ns
                            if (cut_ns && cutoff_time && time_count > cutoff_time), break; end
                            if (cut_ns && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                        end
                        % If runtime was too long, break again to stop increasing nc
                        if (cut_nc && cutoff_time && time_count > cutoff_time), break; end
                        if (cut_nc && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/f1s.mat", save_path), 'f1s', '-v7.3');
                    save(sprintf("%s/runtimes.mat", save_path), 'runtimes', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/nt.mat", save_path), 'nt', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end

    %% Experiment 2
    if exp2.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp2.caus_est_methods;
        mvar_est_methods = exp2.mvar_est_methods;
        ns = exp2.ns;
        nc = exp2.nc;
        no = exp2.no;
        exn = exp2.exn;
        nt = exp2.nt;

        % Parse optional parameters (or sets default values)
        if isfield(exp2, "timestamp"), NOW = exp2.timestamp; end

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};

                % Saving parameters
                save_path = sprintf('data-preds/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(exn), length(nc), length(ns), length(no), nt);
                fp = cell(length(exn), length(nc), length(ns), length(no), nt);
                tp = cell(length(exn), length(nc), length(ns), length(no), nt);
                fn = cell(length(exn), length(nc), length(ns), length(no), nt);
                tn = cell(length(exn), length(nc), length(ns), length(no), nt);
                weights = cell(length(exn), length(nc), length(ns), length(no), nt);

                % Run estimations
                for eid = 1 : length(exn)
                    for cid = 1 : length(nc)
                        for sid = 1 : length(ns)
                            for oid = 1 : length(no)
                                for tid = 1 : nt
                                    % Log advancement
                                    fprintf("exn: %.2f, nc: %d, ns: %d, order %d, trial %d\n", exn(eid), nc(cid), ns(sid), no(oid), tid);

                                    % Simulate data
                                    order = no(oid);
                                    [data, gt, info_draft] = draft_data(ns(sid), nc(cid), exn(eid), order);
        
                                    % Estimate causality
                                    try
                                        [cm, info] = estimate_causality(data, order, est_method, caus_measure);
                                    catch e
                                        cm = nan(nc(cid));
                                        info = struct("error", e);
                                    end

                                    % Compute performance results
                                    info.stats = stats_cm(cm, gt);
                                    info.cm = cm;
                                    info.gt = gt;

                                    % Log draft info
                                    info.draft_delays = info_draft.draft_delays;
                                    info.draft_weights = info_draft.draft_weights;
                                    info.maxdelay = info_draft.maxdelay;
        
                                    % Store results into containers
                                    results{eid, cid, sid, oid, tid} = info;
                                    tp{eid, cid, sid, oid, tid} = info.stats.tp_map;
                                    fp{eid, cid, sid, oid, tid} = info.stats.fp_map;
                                    tn{eid, cid, sid, oid, tid} = info.stats.tn_map;
                                    fn{eid, cid, sid, oid, tid} = info.stats.fn_map;
                                    weights{eid, cid, sid, oid, tid} = info_draft.draft_weights;
                                end
                            end
                        end
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/tp.mat", save_path), 'tp', '-v7.3');
                    save(sprintf("%s/fp.mat", save_path), 'fp', '-v7.3');
                    save(sprintf("%s/tn.mat", save_path), 'tn', '-v7.3');
                    save(sprintf("%s/fn.mat", save_path), 'fn', '-v7.3');
                    save(sprintf("%s/weights.mat", save_path), 'weights', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/nt.mat", save_path), 'nt', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end

    %% Experiment 3
    if exp3.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp3.caus_est_methods;
        mvar_est_methods = exp3.mvar_est_methods;
        ns = exp3.ns;
        nc = exp3.nc;

        % Parse optional parameters (or sets default values)
        if isfield(exp3, "exn"), exn = exp3.exn; else, exn = 0.0; end
        if isfield(exp3, "no"), no = exp3.no; else, no = 10; end
        if isfield(exp3, "nt"), nt = exp3.nt; else, nt = 1; end
        if isfield(exp3, "f1thr"), f1thr = exp3.f1thr; else, f1thr = 1.0; end
        if isfield(exp3, "cutoff"), cutoff = exp3.cutoff; else, cutoff = false; end
        if isfield(exp3, "cutoff_time"), cutoff_time = exp3.cutoff_time; else, cutoff_time = false; end
        if isfield(exp3, "cutoff_time_trial"), cutoff_time_trial = exp3.cutoff_time_trial; else, cutoff_time_trial = false; end
        if isfield(exp3, "cutoffmode"), cutoffmode = exp3.cutoffmode; else, cutoffmode = "following"; end
        if isfield(exp3, "timestamp"), NOW = exp3.timestamp; end
        % if isfield(exp3, "run_all_nc") && exp3.run_all_nc, cut_nc = false; else, cut_nc = true; end
        if isfield(exp3, "skip_cut_of")
            cut_ns = ~any(ismember(exp3.skip_cut_of, 'ns'));
            cut_nc = ~any(ismember(exp3.skip_cut_of, 'nc'));
            cut_no = ~any(ismember(exp3.skip_cut_of, 'no'));
        else
            cut_nc = true;
            cut_ns = true;
            cut_no = true;
        end

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};

                % Saving parameters
                save_path = sprintf('data/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(exn), length(nc), length(ns), length(no), nt);
                f1s = nan(length(exn), length(nc), length(ns), length(no), nt);
                runtimes = nan(length(exn), length(nc), length(ns), length(no), nt);

                % Run estimations
                for eid = 1 : length(exn)
                    for cid = 1 : length(nc)
                        % Reset cutoff var to count f1s = 1.0
                        cutoff_count = 0;
                        time_count = 0;
    
                        for oid = 1 : length(no)
                            for sid = 1 : length(ns)

                                % Reset trial_cumulated_time to 0;
                                trial_cumulated_time = 0;

                                for tid = 1 : nt
                                    % Cutoff if over
                                    if (cutoff && cutoff_count > (cutoff - 1)), break; end
        
                                    % Initialize output results
                                    results{eid, cid, sid, oid, tid} = struct();
        
                                    % Simulate data
                                    order = no(oid);
                                    [data, gt] = draft_data(ns(sid), nc(cid), exn(eid), order);
        
                                    % Estimate causality
                                    fprintf("exn: %.2f, nc: %d, ns: %d, order %d, trial %d", exn(eid), nc(cid), ns(sid), no(oid), tid);
                                    timer = tic();
                                    try
                                        [cm, info] = estimate_causality(data, order, est_method, caus_measure);
                                    catch e
                                        cm = nan(nc(cid));
                                        info = struct("error", e);
                                    end
                                    info.runtime = toc(timer);
                                    fprintf("  (%.2f s)\n", info.runtime);

                                    % Keep longest duration among trials
                                    trial_cumulated_time = max([trial_cumulated_time, info.runtime]);
        
                                    % Compute performance results
                                    info.stats = stats_cm(cm, gt);
                                    info.cm = cm;
                                    info.gt = gt;
        
                                    % Store results into containers
                                    results{eid, cid, sid, oid, tid} = info;
                                    f1s(eid, cid, sid, oid, tid) = info.stats.f1;
                                    runtimes(eid, cid, sid, oid, tid) = info.runtime;
                                    time_count = time_count + info.runtime;
        
                                    % Increment cutoff counter if prediction was perfect
                                    if (cutoff_count < cutoff && info.stats.f1 >= f1thr)
                                        cutoff_count = cutoff_count + 1;
                                    elseif (strcmpi(cutoffmode, 'following'))
                                        cutoff_count = 0;
                                    end
                                end

                                % If runtime was too long, break again to stop increasing ns
                                if (cut_ns && cutoff_time && time_count > cutoff_time), break; end
                                if (cut_ns && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                            end

                            % If runtime was too long, break again to stop increasing no
                            if (cut_no && cutoff_time && time_count > cutoff_time), break; end
                            if (cut_no && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                        end
                        % If runtime was too long, break again to stop increasing nc
                        if (cut_nc && cutoff_time && time_count > cutoff_time), break; end
                        if (cut_nc && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/f1s.mat", save_path), 'f1s', '-v7.3');
                    save(sprintf("%s/runtimes.mat", save_path), 'runtimes', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/nt.mat", save_path), 'nt', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end

    %% Experiment 4
    if exp4.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp4.caus_est_methods;
        mvar_est_methods = exp4.mvar_est_methods;
        ns = exp4.ns;
        nc = exp4.nc;

        % Parse optional parameters (or sets default values)
        if isfield(exp4, "exn"), exn = exp4.exn; else, exn = 0.0; end
        if isfield(exp4, "no"), no = exp4.no; else, no = 10; end
        if isfield(exp4, "nt"), nt = exp4.nt; else, nt = 1; end
        if isfield(exp4, "f1thr"), f1thr = exp4.f1thr; else, f1thr = 1.0; end
        if isfield(exp4, "cutoff"), cutoff = exp4.cutoff; else, cutoff = false; end
        if isfield(exp4, "cutoff_time"), cutoff_time = exp4.cutoff_time; else, cutoff_time = false; end
        if isfield(exp4, "cutoff_time_trial"), cutoff_time_trial = exp4.cutoff_time_trial; else, cutoff_time_trial = false; end
        if isfield(exp4, "cutoffmode"), cutoffmode = exp4.cutoffmode; else, cutoffmode = "following"; end
        if isfield(exp4, "timestamp"), NOW = exp4.timestamp; end
        % if isfield(exp4, "run_all_nc") && exp4.run_all_nc, cut_nc = false; else, cut_nc = true; end
        if isfield(exp4, "skip_cut_of")
            cut_ns = ~any(ismember(exp4.skip_cut_of, 'ns'));
            cut_nc = ~any(ismember(exp4.skip_cut_of, 'nc'));
            cut_no = ~any(ismember(exp4.skip_cut_of, 'no'));
        else
            cut_nc = true;
            cut_ns = true;
            cut_no = true;
        end

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};

                % Saving parameters
                save_path = sprintf('data/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(exn), length(nc), length(ns), length(no), nt);
                f1s = nan(length(exn), length(nc), length(ns), length(no), nt);
                runtimes = nan(length(exn), length(nc), length(ns), length(no), nt);

                % Run estimations
                for eid = 1 : length(exn)
                    for sid = 1 : length(ns)
                        for oid = 1 : length(no)
                            for cid = 1 : length(nc)

                                % Reset trial_cumulated_time to 0;
                                trial_cumulated_time = 0;

                                for tid = 1 : nt
                                    % Initialize output results
                                    results{eid, cid, sid, oid, tid} = struct();
        
                                    % Simulate data
                                    order = no(oid);
                                    [data, gt] = draft_data(ns(sid), nc(cid), exn(eid), order);
        
                                    % Estimate causality
                                    fprintf("exn: %.2f, nc: %d, ns: %d, order %d, trial %d", exn(eid), nc(cid), ns(sid), no(oid), tid);
                                    timer = tic();
                                    try
                                        [cm, info] = estimate_causality(data, order, est_method, caus_measure);
                                    catch e
                                        cm = nan(nc(cid));
                                        info = struct("error", e);
                                    end
                                    info.runtime = toc(timer);
                                    fprintf("  (%.2f s)\n", info.runtime);

                                    % Keep longest duration among trials
                                    trial_cumulated_time = max([trial_cumulated_time, info.runtime]);
        
                                    % Compute performance results
                                    info.stats = stats_cm(cm, gt);
                                    info.cm = cm;
                                    info.gt = gt;
        
                                    % Store results into containers
                                    results{eid, cid, sid, oid, tid} = info;
                                    f1s(eid, cid, sid, oid, tid) = info.stats.f1;
                                    runtimes(eid, cid, sid, oid, tid) = info.runtime;
                                end

                                % If runtime was too long, break again to stop increasing nc
                                if (cut_nc && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                            end
                            % If runtime was too long, break again to stop increasing no
                            if (cut_no && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                        end
                        % If runtime was too long, break again to stop increasing ns
                        if (cut_ns && cutoff_time_trial && trial_cumulated_time > cutoff_time_trial), break; end
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/f1s.mat", save_path), 'f1s', '-v7.3');
                    save(sprintf("%s/runtimes.mat", save_path), 'runtimes', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/nt.mat", save_path), 'nt', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end

    %% Experiment 5
    if exp5.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        if isfield(exp5, "timestamp"), NOW = exp5.timestamp; end

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp5.caus_est_methods;
        mvar_est_methods = exp5.mvar_est_methods;
        ns = exp5.ns;
        nc = exp5.nc;
        no = 10;
        exn = 0.0;

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};

                % Saving parameters
                save_path = sprintf('data/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(nc), length(ns));
                f1s = nan(length(nc), length(ns));
                runtimes = nan(length(nc), length(ns));
                perf_bound = false(length(nc), length(ns));

                % Run estimations
                for cid = 1 : length(nc)
                    for sid = 1 : length(ns)
                        % Simulate data
                        [data, gt] = draft_data(ns(sid), nc(cid), exn, no);

                        % Estimate causality
                        fprintf("nc: %d, ns: %d", nc(cid), ns(sid));
                        timer = tic();
                        try
                            [cm, info] = estimate_causality(data, no, est_method, caus_measure);
                        catch e
                            cm = nan(nc(cid));
                            info = struct("error", e);
                        end
                        info.runtime = toc(timer);
                        fprintf("  (%.2f s)\n", info.runtime);

                        % Compute performance results
                        info.stats = stats_cm(cm, gt);
                        info.cm = cm;
                        info.gt = gt;

                        % Store results into containers
                        results{cid, sid} = info;
                        f1s(cid, sid) = info.stats.f1;
                        runtimes(cid, sid) = info.runtime;

                        % Check skip state
                        if ~isnan(info.stats.f1) && info.stats.f1 > 0.5 %% Second part is a test
                            perf_bound(cid, sid) = true;

                            if (sid - 1 > 0)
                                perf_bound(cid, sid - 1) = true;
                            end

                            break;
                        end

                        % If previous runtime is too long, break ns
                        if info.runtime > 1000
                            break;
                        end
                    end

                    % If previous runtime is too long, break nc too
                    if info.runtime > 1000
                        break;
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/f1s.mat", save_path), 'f1s', '-v7.3');
                    save(sprintf("%s/perf_bound.mat", save_path), 'perf_bound', '-v7.3');
                    save(sprintf("%s/runtimes.mat", save_path), 'runtimes', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end

    %% Experiment 6
    if exp6.run
        % General parameters
        SAVE = true;
        NOW = string(datetime('now'), 'yyyyMMddHHmm');

        if isfield(exp6, "timestamp"), NOW = exp6.timestamp; end
        if isfield(exp6, "ns_indep"), ns_indep = exp6.ns_indep; else, ns_indep = false; end

        % Save warning state and (temporarily) disable all warnings
        w = warning();
        warning('off', 'all');

        % Parse required parameters
        caus_est_methods = exp6.caus_est_methods;
        mvar_est_methods = exp6.mvar_est_methods;
        ns = exp6.ns;
        nc = exp6.nc;
        no = exp6.no;
        exn = exp6.exn;

        % For each caus_est_method
        for ceid = 1 : length(caus_est_methods)
            for meid = 1 : length(mvar_est_methods)
                % Log advancement
                fprintf("estimation: %s - %s\n", caus_est_methods{ceid}, mvar_est_methods{meid});
                est_method = mvar_est_methods{meid};
                caus_measure = caus_est_methods{ceid};
                method_skip = false;

                % Saving parameters
                save_path = sprintf('data/%s-%s/%s', caus_est_methods{ceid}, mvar_est_methods{meid}, NOW);
                if SAVE, mkdir(save_path); end
                
                % Result containers
                results = cell(length(nc), length(ns));
                f1s = nan(length(nc), length(ns));
                runtimes = nan(length(nc), length(ns));

                % Run estimations
                for cid = 1 : length(nc)
                    sid = 1;
                    while sid <= length(ns)
                        % Simulate data
                        [data, gt] = draft_data(ns(sid), nc(cid), exn, no);

                        % Estimate causality
                        fprintf("nc: %d, ns: %d", nc(cid), ns(sid));
                        timer = tic();
                        try
                            [cm, info] = estimate_causality(data, no, est_method, caus_measure);
                        catch e
                            cm = nan(nc(cid));
                            info = struct("error", e);
                        end
                        info.runtime = toc(timer);
                        fprintf("  (%.2f s)\n", info.runtime);

                        % Compute performance results
                        info.stats = stats_cm(cm, gt);
                        info.cm = cm;
                        info.gt = gt;

                        % Store results into containers
                        results{cid, sid} = info;
                        f1s(cid, sid) = info.stats.f1;
                        runtimes(cid, sid) = info.runtime;

                        % This nc cannot be solved in decent runtime
                        if isnan(info.stats.f1) && info.runtime > 1000
                            method_skip = true;
                            break;
                        end

                        % This nc saw a big jump out of the blue, stop there
                        if info.runtime > 2000
                            method_skip = true;
                            break;
                        end

                        % If ns sufficient for f1, and expect ns_indep runtime, skip to last ns of this nc 
                        if ns_indep && ~isnan(info.stats.f1) && info.stats.f1 > 0.9 && sid < length(ns)
                            sid = length(ns);
                            continue;
                        end

                        % Decent time border of solving nc is found -> next nc
                        if info.runtime > 1000
                            break;
                        end

                        % While loop increment
                        sid = sid + 1;
                    end

                    % If unsolvable nc in decent runtime, break to next method
                    if method_skip
                        break;
                    end
                end

                % Format outputs to save
                caus_est_methods_save = caus_est_methods{ceid};
                mvar_est_methods_save = mvar_est_methods{meid};

                % Reset warnings to original state
                warning(w);

                % Save
                if SAVE
                    save(sprintf("%s/results.mat", save_path), 'results', '-v7.3');
                    save(sprintf("%s/f1s.mat", save_path), 'f1s', '-v7.3');
                    save(sprintf("%s/runtimes.mat", save_path), 'runtimes', '-v7.3');
                    save(sprintf("%s/ns.mat", save_path), 'ns', '-v7.3');
                    save(sprintf("%s/nc.mat", save_path), 'nc', '-v7.3');
                    save(sprintf("%s/exn.mat", save_path), 'exn', '-v7.3');
                    save(sprintf("%s/no.mat", save_path), 'no', '-v7.3');
                    save(sprintf("%s/caus_est_method.mat", save_path), 'caus_est_methods_save', '-v7.3');
                    save(sprintf("%s/mvar_est_method.mat", save_path), 'mvar_est_methods_save', '-v7.3');
                end
            end
        end
    end
end