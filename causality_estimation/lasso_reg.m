function [params, error_cov] = lasso_reg(data, order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LASSO
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   The estimation is done via the matlab implementation of the LASSO
%   regression. Lambda values are (by default) assigned as a geometric
%   sequence.
%
% [1] Tibshirani, Robert. “Regression Shrinkage and Selection via the 
% Lasso.” Journal of the Royal Statistical Society. Series B
% (Methodological), vol. 58, no. 1, pp. 267–88, (1996).
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
    %% Parameters
    [nc, ns] = size(data);
    
    data = demean(data);        % no constant term

    %% Format optimisation problem inputs
    Y = data(:, order + 1 : ns);
    X = zeros(order * nc, ns - order);

    for j = 1:order
        X((j - 1) * nc + 1: (j * nc), 1:ns - order) = data(:, order + 1 - j : ns - j);
    end

    %% LASSO
    A = nan(nc, order * nc);

    for cid = 1 : nc
        lambda = 1e-3;
        B = lasso(X', Y(cid, :), 'Lambda', lambda);
        A(cid, :) = B;
    end

    % From params and data, estimate error
    E = Y - A * X;      % residuals

    %% Outputs
    params = reshape(A, nc, nc, order);
    error_cov = cov(E');
end