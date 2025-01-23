function [cm, info] = estimate_causality(data, order, est_method, caus_measure, prior, pthresh, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimate_causality
%   From input time series, estimates a binary causal map.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters
    [nc, ~] = size(data);

    if ~exist("info", "var")
        info = struct();
    end

    % info.reduced_info = cell(nc, 1);
    info.est_method = est_method;
    info.order = order;
    info.caus_measure = caus_measure;

    if ~exist('prior', 'var') || ~all(size(prior) == [nc, nc])
        info.prior = ones(nc, nc);
    end

    % % threshold pvalues
    % if ~exist('pthresh', 'var') || pthresh == false
    %     info.pthresh = 0.001;
    % 
    % elseif pthresh == true
    %     % dynamic pthresh
    %     orig_pthresh = 0.001;
    %     info.pthresh = orig_pthresh / (nc * nc);
    % end

    if strcmpi(caus_measure, 'MVGC')
        [cm, info] = mvgc(data, info);

    elseif strcmpi(caus_measure, 'PDC')
        [cm, info] = pdc(data, info);

    elseif strcmpi(caus_measure, 'single')
        %% Single run
        [params, cov, info] = estimate_var(data, order, prior, info);

        info.covariance_error = cov;
        info.mvar_parameters = params;
        info.threshold = pthresh;
        if isfield(info, "iterations"), info.total_iterations = sum(info.iterations); end

        cm = any(params > 0.5, 3)';

        % Diagonal to NaN because causality cannot be instantaneous
        cm = double(cm);
        cm(1:size(cm,1) + 1:end) = NaN;

    else
        error('Invalid causality measure');
    end
end
