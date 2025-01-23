function [params, error_cov] = lwr(data, order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LWR
%   Estimates VAR parameters from data. Looks ahead for order time points.
%   The estimation is done via an implementation of the Levinson-Durbin
%   algorithm extended to multivariate by Whittle, Wiggins and Robinson.[2]
%   Its implementation is an edited version of the one used in Barnett and
%   Seth [1]. It must have the dimensions (nc x nc) where nc is the number
%   of time series in data.
%
% [1] L. Barnett and A. K. Seth, "Multivariate Granger Causality Toolbox: A
% New Approach to Granger-causal Inference", J. Neurosci. Methods 223, 2014
%
% [2] M. Morf, A. Viera, D. T. L. Lee and T. Kailath, "Recursive Multichannel
% Maximum Entropy Spectral Estimation", IEEE Trans. Geosci. Elec., 16(2), 1978.
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
    pn = (order + 1) * nc;
    I = eye(nc);
    
    data = demean(data); % no constant term

    % store lags
    X = zeros(nc, order + 1, ns + order);

    for k = 0:order
        X(:, k+1, k+1:k+ns) = data; % k-lagged observations
    end

    %% initialise recursion
    EE = reshape(data, nc, ns);
    IC = inv(chol(EE*EE','lower')); % inverse covariance square root

    k  = 1;
    kn = k*nc;
    M  = ns-k;
    kk = 1:k;
    kf = 1:kn;         % forward  indices
    kb = pn-kn+1:pn; % backward indices

    AF = zeros(nc,pn); AF(:,kf) = IC; % forward  AR coefficients
    AB = zeros(nc,pn); AB(:,kb) = IC; % backward AR coefficients (reversed compared with [2])

    %% LWR recursion
    while k <= order

        EF = AF(:, kf)*reshape(X(:, kk, k+1:ns), kn, M); % forward  prediction errors
        EB = AB(:, kb)*reshape(X(:, kk, k:ns-1), kn, M); % backward prediction errors

        R = (chol(EF*EF','lower')\EF)*(chol(EB*EB','lower')\EB)'; % normalised reflection coefficients

        k  = k+1;
        kn = k*nc;
        M  = ns-k;
		kk = 1:k;
        kf = 1:kn;
        kb = pn-kn+1:pn;

        AFPREV = AF(:,kf);
        ABPREV = AB(:,kb);

        AF(:,kf) = chol(I-R*R','lower')\(AFPREV-R*ABPREV);
        AB(:,kb) = chol(I-R'*R,'lower')\(ABPREV-R'*AFPREV);

    end

	A0 = AF(:, 1:nc);
    E = A0\EF;

    %% Outputs
    params = reshape(-A0\AF(:,nc+1:pn),nc,nc,order);
    error_cov = (E*E')/(M-1); % residuals covariance matrix (unbiased estimator)
end