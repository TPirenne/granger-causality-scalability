function [params, error_cov, info] = sbl(data, order, prior, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SBL
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   The estimation is done via an implementation of Sparse Bayesian
%   Learning named BA-GCA [1]. Prior is a Bayesian prior of the information
%   known a priori of the causality. It must have the dimensions (nc x nc)
%   where nc is the number of time series in data.
%
% [1] P. Li, X. Huang, X. Zhu, et. al., "Robust brain causality network
% construction based on Bayesian multivariate autoregression", Biomedical
% Signal Processing and Control, 2020.
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
    % nc: number of channels
    % ns: number of samples
    [nc, ns] = size(data);

    if ~exist("info", "var"), info = struct(); end
    if ~isfield(info, "prior_on_A"), info.prior_on_A = true; end
    if ~isfield(info, "conv_criteria"), info.conv_criteria = 1e-6; end

    data = demean(data);        % no constant term

    %% Format data MVAR as Y = XA + epsilon
    % Y is the future of the time serie (to predict)
    % X is the past of the time serie from which to predict Y (design matrix)
    % A (approximated as beta) are parameters to optimize by fitting (coefficient matrix)
    % epsilon is the error to minimize by fitting -> after optimisation,
        % epsilon is leftover prediction error due to lack of information
        % and noise.
    X = zeros(order * nc, ns - order);

    for j = 1:order
        X((j - 1) * nc + 1: (j * nc), 1:ns - order) = data(:, order + 1 - j : ns - j);
    end
    
    X = X';
    
    Y = data(:, order + 1 : ns)';

    %% Derive X from Y and A
    % Initial parameters
    beta = ones(nc, order * nc);        % reshape for params
    prior = repmat(prior', 1, order);    % replicate prior for all delays in order
    
    if isfield(info, "accumulate")
        info.accumulatedBeta = nan(nc, order * nc, 2000);
        info.iterations = nan(1, nc);
        info.expectations = nan(nc, 2000);
    end

    for chanid = 1 : nc
        priork = prior(chanid, :)';
        A = ones(order * nc); % square matrix
        Yk = Y(:, chanid);
        sigma2 = 1;
        betak = ones(order * nc, 1);
        Sigma = (A + sigma2 * (X' * X))^(-1); % A size
        m = sigma2 * Sigma * X' * Yk; % Yk
        alpha = 1 ./ (m.^2 + diag(Sigma));
        
        % Loop config
        count = 0;
        expectation = 0;
        expectation_prev = 1;
        max_iters = 100;

        if isfield(info, "accumulate"), info.accumulatedBeta(chanid, :, 1) = betak; end
    
        while (count < max_iters && abs((expectation - expectation_prev) / expectation_prev) >= info.conv_criteria)
            count = count + 1;
            expectation_prev = expectation;
    
            % === Expectation - Calculate expected complete data log likelihood === %
            expectation = 0.5 * ( (ns - order) * log(sigma2) - sigma2 * (norm(Yk - betak' * X')^2 + trace(X' * X * Sigma)) + sum(log(alpha)) - trace(A' * (m * m' + Sigma)) );
            if isfield(info, "accumulate"), info.expectations(chanid, count) = expectation; end

            % === Maximization - Maximize expectation wrt beta === %
            Sigma = (A + sigma2 * (X' * X))^(-1); % A size
            m = sigma2 * Sigma * X' * Yk; % Yk
            
            if ~info.prior_on_A
                m = m .* priork;
            end
            
            alpha = 1 ./ (m.^2 + diag(Sigma));

            % A (prior * alphai)
            if info.prior_on_A
                A = diag(alpha .* priork);
            else
                A = diag(alpha);
            end
            % A = diag(alpha.^2 .* priork); % dot() or * or .*
    
            % sigma2
            sigma2 = (norm(Yk - betak' * X')^2 + trace(X' * X * Sigma)) / nc;
    
            % === Output === %
            betak = mvnrnd(m, Sigma, 1)';

            if isfield(info, "accumulate"), info.accumulatedBeta(chanid, :, count + 1) = betak; end
        end

        beta(chanid, :) = betak;
        if isfield(info, "accumulate"), info.iterations(chanid) = count; end
    end

    %% Format output
    % format beta into params
    params = reshape(beta, nc, nc, order);

    % from params, get error covariance
    error_cov = cov(Y - X * beta'); % residuals covariance matrix

    % Log into info
    info.beta = beta;

    %% Crop long containers
    if isfield(info, "accumulate")
        cropindex = find(squeeze(any(any(isnan(info.accumulatedBeta), 2), 1)), 1);
        info.accumulatedBeta = info.accumulatedBeta(:, :, 1:cropindex);
        info.expectations = info.expectations(:, 1:cropindex);
    end

end

