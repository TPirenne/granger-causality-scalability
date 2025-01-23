function [params, error_cov, info] = lapsbl(data, order, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lap-SBL
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   The estimation is done via an implementation of Sparse Bayesian
%   Learning named lap-SBL [1]. Prior is a Bayesian prior of the
%   information known a priori of the causality. It must have the
%   dimensions (nc x nc) where nc is the number of time series in data.
%
% [1] K. Liu, et. al., "Robust Bayesian Estimation of EEG-based Brain 
% Causality Networks", IEEE Transactions on Biomedical Engineering, 2023.
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
    if ~isfield(info, "conv_criteria"), info.conv_criteria = 1e-6; end

    data = demean(data);        % no constant term

    %% Format data MVAR as Y = XA + epsilon
    % Y is the future of the time serie (to predict)
    % X is the past of the time serie from which to predict Y (design matrix)
    % A are parameters to optimize by fitting (coefficient matrix)
    % epsilon is the error to minimize by fitting -> after optimisation,
        % epsilon is leftover prediction error due to lack of information
        % and noise.
    X = zeros(order * nc, ns - order);

    for j = 1:order
        X((j - 1) * nc + 1: (j * nc), 1:ns - order) = data(:, order + 1 - j : ns - j);
    end
    
    X = X';
    
    Y = data(:, order + 1 : ns)';

    %% Call code from [1]
    A = zeros(order * nc, nc);
    for cid = 1:nc
        A(:, cid) = LAP_SBL_estimate(Y(:, cid), X);
    end

    %% Format output
    % format beta into params
    params = reshape(A', nc, nc, order);

    % from params, get error covariance
    error_cov = cov(Y - X * A); % residuals covariance matrix

    % Log into info
    info.A = A;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Utils from [1]
function [ X, evidence] = LAP_SBL_estimate( Y,A )
    % Model: Y = A*X + epsilon.
    % Dimension of the inverse problem
    [n,T] = size(Y);
    m = size(A,2);
    
    % Default Control Parameters
    lamda = 1+rand();
    gamma = ones(m,1); 
    beta = ones(n,1);
    
    % iteration                                                                                                                                                                                                                         
    count = 0;
    cost = 1;
    max_iters = 100;
    prune_gama = 1e-5;
    prune_beta = 1e-5;
    epsilon = 1e-6;
    prune_hyperparameter = 0;
    keep_list = (1:m)';
    keep_list_beta = 1:n;
    
    while (1)
        
        % *** Prune weights as their hyperparameters go to zero ***
        if ( prune_hyperparameter )
            %index = find(gamma > PRUNE_GAMMA);
            index = find(gamma > max(gamma)*prune_gama); %prue-gamma的方式为根据gamma相对值prune
            gamma = gamma(index);  % use all the elements larger than MIN_GAMMA to form new 'gamma'
            A = A(:,index);       % corresponding columns in A
            keep_list = keep_list(index);
            if (isempty(gamma)) 
                break;   
            end
            
            index1 = find(beta > max(beta)*prune_beta); %prue-beta的方式为根据beta相对值prune
            beta = beta(index1);  % use all the elements larger than MIN_GAMMA to form new 'beta'
            A = A(index1,:);       % corresponding rows in A
            Y = Y(index1,:);
            keep_list_beta = keep_list_beta(index1);
            if (isempty(beta)) 
                break;   
            end   
        end
    %         s = length(gamma);
            
         Gamma = diag(gamma);
         Beta  = diag(beta);
         
        % ****** estimate the solution matrix *****
        Sigma_y = Beta + A*Gamma*A';    % the marginal covariance of Y
    %     Sigma = Gamma - Gamma*A'/Sigma_y*A*Gamma;%inv(A'*pinv(Beta)*A + inv(Gamma)); %posterior covariance of MVAR parameters
        Mu = Gamma*A'/Sigma_y*Y;     
      
        count = count + 1;
        cost_old = cost;
        
        % cost function
        cost = lamda^2*trace(Beta) - 2*n*T*log(lamda) + T*log(det(Sigma_y/Beta)) + trace(Y'/Sigma_y*Y); 
        evidence(count,1) = cost;
        % *** Update hyperparameters***
        lamda = sqrt(n*T/sum(beta));    % update lamda
        Res = Y-A*Mu;
    
        beta = sqrt(sum(Res.^2,2))./ lamda;
        beta(beta < eps) = eps;
        
        Z = diag(A'/Sigma_y*A);   % upadte z
        
        gamma  = sqrt(sum(Mu.^2,2)) ./ sqrt(T*Z);
        
        % print
        % disp(['iters: ',num2str(count),'   cost change: ',num2str(abs((cost-cost_old)/cost_old))]);
        
        % *** Check stopping conditions
        if (count >= max_iters)
            break;
        end
        
        if ( abs((cost-cost_old)/cost_old) < epsilon )
            break;
        end
    
    end
    
    X = zeros(m,T);
    X(keep_list,:) = Mu;
end