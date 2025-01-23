function [params, error_cov] = ols(data, order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OLS
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   The estimation is done via an implementation of the OLS solution to the
%   regression via QR decomposition. Its implementation is an edited
%   version of the one used in Barnett and Seth [1]. It must have the
%   dimensions (nc x nc) where nc is the number of time series in data.
%
% [1] L. Barnett and A. K. Seth, "Multivariate Granger Causality Toolbox: A
% New Approach to Granger-causal Inference", J. Neurosci. Methods 223, 2014
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

    %% OLS
    Y = data(:, order + 1 : ns);
    X = zeros(order * nc, ns - order);

    for j = 1:order
        X((j - 1) * nc + 1: (j * nc), 1:ns - order) = data(:, order + 1 - j : ns - j);
        
        % Next lines are the same but does not use matlab matrix operations
        % so is much slower
        % for i = 1:nc
        %     X((j - 1) * nc + i, 1:ns - order) = data(i, order + 1 - j : ns - j);
        % end
    end

    A = Y / X;          % OLS using QR decomposition
    E = Y - A * X;      % residuals

    %% Outputs
    params = reshape(A, nc, nc, order);
    error_cov = cov(E');                    % equiv to (E * E') / (M - 1)
end