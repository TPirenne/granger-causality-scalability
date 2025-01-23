function Y = demean(X, normalise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEMEAN - from MVGC toolbox [1].

% [1] L. Barnett and A. K. Seth, "Multivariate Granger Causality Toolbox: A
% New Approach to Granger-causal Inference", J. Neurosci. Methods 223, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 2 || isempty(normalise), normalise = false; end
    
    [n,m,N] = size(X);
    
    U = ones(1,N*m);
    Y = X(:,:);
    Y = Y-mean(Y,2)*U;
    if normalise
        Y = Y./(std(Y,[],2)*U);
    end

    Y = reshape(Y,n,m,N);
end