function [cm, info] = smvgc(data, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subproblem-MVGC
%   From input time series, estimates a binary causal map using a
%   Segmented alternative to the MultiVariate Granger Causality estimation 
%   method described in [1]. MVAR parameters are estimated by the method in
%   'info.est_method'.
%   'info':
%       info.est_method: "SBL" | "OLS" | "LWR" | "LAPPS" | "LASSO"
%       info.order: integer
%       info.prior: matrix (nc x nc) of prior knowledge on causal est.
%       info.prior_thresh: minimum prior value indicating a potential 
%                          causal connection. 
%
% [1] Barnett and Seth, 2014
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
    %% Parse parameters
    order = info.order;
    prior = info.prior;
    nc = size(data, 1);

    % dynamically threshold pvalues
    orig_pthresh = 0.01;
    logisprior = prior > 0;

    % Output containers
    info.degrees = zeros(nc, 1);

    %% Full-thresholded subprblem-ftest
    if (~isfield(info, "timereversed") || ~info.timereversed)
        nc = size(data, 1);
        ns = size(data, 2) - order;    % number of observations
    
        stat = zeros(nc, nc);
        pval = ones(nc, nc);
        log_cov_ratio = zeros(nc, nc);
    
        %%% Wait bar %%%
        f = waitbar(0, 'Starting');
        %%%%%%%%%%%%%%%%
    
        for c = 1:nc
            %%% Wait bar %%%
            waitbar(c/nc, f, sprintf("Progress (%d/%d)", c, nc));
            %%%%%%%%%%%%%%%%
    
            % From prior get relevant channels for c
            cs = logisprior(c, :)';
            cs(c) = true;
            local_cso = ~(find(cs) == c);
    
            % omit j
	        cso = cs;
            cso(c) = false;
    
            % Log degree
            info.degrees(c) = sum(cso);
    
            % Filter data
            data_sub = data(cs,:);
    
            % Full regression
	        [~, fullcov, ~] = estimate_var(data_sub, order, info.prior(cs, cs), info);   % full regression
    
            % Reduced regression
	        [~, redcov, ~] = estimate_var(data_sub(local_cso,:), order, info.prior(cso, cso), info);   % reduced regression
    
            % Statistical test
            snc = sum(cs);
            d2 = ns - order * snc - 1;              % F df2
            K = d2 / order;                         % F scaling factor
    
	        stat(cso, c) = (diag(redcov) ./ diag(fullcov(local_cso, local_cso)) - 1);
            pval(cso, c) = 1 - fcdf(K * stat(cso, c), order, d2);
            log_cov_ratio(cso, c) = log(stat(cso, c) + 1);
        end
    
        %%% Wait bar %%%
        close(f);
        %%%%%%%%%%%%%%%%
    
        % Flip stat
        info.stat = stat';
        info.pval = pval';
        info.log_cov_ratio = log_cov_ratio';
    
        % Threshold into CM
        cm = info.pval < (orig_pthresh / sum(logisprior, "all"));
    end
    
    %% Full-thresholded subprblem-ftest time-reversed
    if isfield(info, "timereversed") && info.timereversed
        nc = size(data, 1);
        ns = size(data, 2) - order;    % number of observations
    
        stat = zeros(nc, nc);
        pval = ones(nc, nc);
        log_cov_ratio = zeros(nc, nc);
        stat_r = zeros(nc, nc);
        pval_r = ones(nc, nc);
        log_cov_ratio_r = zeros(nc, nc);
    
        %%% Wait bar %%%
        f = waitbar(0, 'Starting');
        %%%%%%%%%%%%%%%%
    
        % Reversal
        data_r = fliplr(data);
    
        for c = 1:nc
            %%% Wait bar %%%
            waitbar(c/nc, f, sprintf("Progress (%d/%d)", c, nc));
            %%%%%%%%%%%%%%%%
    
            % From prior get relevant channels for c
            cs = logisprior(c, :)';
            cs(c) = true;
            local_cso = ~(find(cs) == c);
    
            % omit j
	        cso = cs;
            cso(c) = false;
    
            % Log degree
            info.degrees(c) = sum(cso);

            % Filter data
            data_sub = data(cs,:);
            data_r_sub = data_r(cs,:);
    
            % Full regression
	        [~, fullcov, ~] = estimate_var(data_sub, order, info.prior(cs, cs), info);   % full regression
            [~, fullcov_r, ~] = estimate_var(data_r_sub, order, info.prior(cs, cs), info);   % full regression
    
            % Reduced regression
	        [~, redcov, ~] = estimate_var(data_sub(local_cso,:), order, info.prior(cso, cso), info);   % reduced regression
            [~, redcov_r, ~] = estimate_var(data_r_sub(local_cso,:), order, info.prior(cso, cso), info);   % reduced regression
    
            % Statistical test
            snc = sum(cs);
            d2 = ns - order * snc - 1;              % F df2
            K = d2 / order;                         % F scaling factor
    
	        stat(cso, c) = (diag(redcov) ./ diag(fullcov(local_cso, local_cso)) - 1);
            stat_r(cso, c) = (diag(redcov_r) ./ diag(fullcov_r(local_cso, local_cso)) - 1);
            pval(cso, c) = 1 - fcdf(K * stat(cso, c), order, d2);
            pval_r(cso, c) = 1 - fcdf(K * stat_r(cso, c), order, d2);
            log_cov_ratio(cso, c) = log(stat(cso, c) + 1);
            log_cov_ratio_r(cso, c) = log(stat_r(cso, c) + 1);
        end
    
        %%% Wait bar %%%
        close(f);
        %%%%%%%%%%%%%%%%
    
        % Flip stat
        stat = stat';
        stat_r = stat_r';
        pval = pval';
        pval_r = pval_r';
        log_cov_ratio = log_cov_ratio';
        log_cov_ratio_r = log_cov_ratio_r';
    
        % Threshold
        F = pval < (orig_pthresh / sum(logisprior, "all"));
        F_r = pval_r < (orig_pthresh / sum(logisprior, "all"));
    
        % Reversed output
        cm = F & F_r';

        %%% Output %%%
        % Log info
        info.stat = (stat + stat_r') / 2;
        info.pval = (pval + pval_r') / 2;
        info.log_cov_ratio = (log_cov_ratio + log_cov_ratio_r') / 2;
    end
end