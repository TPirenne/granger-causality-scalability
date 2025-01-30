function [params, error_cov, info] = estimate_var(data, order, prior, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESTIMATE_VAR
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   If prior is stated, uses it for the relevant method (SBL). Info allows
%   to log some information about the estimation process (SBL) and allows
%   to choose which estimation method to use.
%   
%   info.est_method:
%       - "SBL": Sparse Bayesian Learning
%       - "LAPSBL": Laplace-Sparse Bayesian Learning
%       - "OLS": Ordinary Least Square Regression
%       - "LWR": Levison Wiggins Robinson algorithm
%       - "LASSO": Least Absolute Shrinkage and Selection Operator (regr.)
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
    if strcmpi(info.est_method, "SBL")
        [params, error_cov, info] = sbl(data, order, prior, info);

    elseif strcmpi(info.est_method, "LAPSBL")
        [params, error_cov] = lapsbl(data, order, info);
        
    elseif strcmpi(info.est_method, "OLS")
        [params, error_cov] = ols(data, order);

    elseif strcmpi(info.est_method, "LWR")
        [params, error_cov] = lwr(data, order);

    elseif strcmpi(info.est_method, "LASSO")
        [params, error_cov] = lasso_reg(data, order);
    else
        error("Unrecognised VAR estimation method.");
    end
end