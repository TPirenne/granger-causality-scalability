function [cm, info] = mvgc(data, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MVGC
%   From input time series, estimates a binary causal map using the
%   MultiVariate Granger Causality estimation method described in [1]. MVAR
%   parameters are estimated by the method in 'info.est_method'.
%   'info':
%       info.est_method: "SBL" | "OLS" | "LWR" | "LAPPS" | "LASSO"
%       info.order: integer
%       info.prior: matrix (nc x nc) of prior knowledge on causal est.
%       info.pthresh: threshold for p-values to get binary causal map.
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

    if ~isfield(info, "prior")
        info.prior = ones(size(data, 1));
    end

    % dynamic threshold pvalues
    orig_pthresh = 0.001;
    nc = size(data, 1);
    info.pthresh = orig_pthresh / (nc * nc);
    pthresh = info.pthresh;
    
    %% Full regression
    [fullparams, fullcov, info] = estimate_var(data, order, info.prior, info);
    
    if isfield(info, "iterations")
        info.total_iterations = sum(info.iterations);
    end

    %% F-stat -- from MVGC by L. Barnett and A. K. Seth (2014)
    nc = size(data, 1);
    ns  = size(data, 2) - order;    % number of observations
    d2 = ns - order * nc - 1;       % F df2
    K  = d2 / order;                % F scaling factor
    stat = nan(nc);                 % init stat

    for j = 1:nc
	    jo = [1:j-1 j+1:nc];                                             % omit j
	    [~, redcov, redinfo] = estimate_var(data(jo,:), order, info.prior(jo, jo), info);   % reduced regression
        
        % LOG %
        % info.reduced_info{j} = redinfo;

        if isfield(redinfo, "iterations")
            info.total_iterations = info.total_iterations + sum(redinfo.iterations);
        end

        % F-test statistic
	    stat(jo, j) = diag(redcov) ./ diag(fullcov(jo, jo)) - 1;
    end

    pval = (1 - fcdf(K * stat, order, d2))';

    %% Threshold p-values
    cm = (pval < pthresh);

    % Diagonal to NaN because we do not try to predict autocausality
    cm = double(cm);
    cm(1:size(cm,1) + 1:end) = NaN;

    %% Output
    % Log info
    info.full_regression_params = fullparams;
    info.pval = pval;
    info.threshold = pthresh;
end