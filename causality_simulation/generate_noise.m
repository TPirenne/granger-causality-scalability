function noise = generate_noise(n, m, noise_type, scaling)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE_NOISE
%   Generates an array (n x m) of white or pink noise. n is the number of 
%   instances of noise to generate. m is the number of samples in one 
%   instance of noise to generate
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

    if ~exist('scaling', 'var'), scaling = 1; end
    
    % Gaussian white noise
    if (strcmp(noise_type, 'gwn'))
        mu = 0;
        sigma = 1;
        noise = sigma * randn(n, m) + mu;
        
    % Pink noise
    elseif (strcmp(noise_type, 'pink'))
        noise = pink_noise(n, m);
        
    % None    
    else
        noise = zeros(n, m);
    end
    
    noise = noise * scaling;
end

function x = pink_noise(n, m)
% Generates n sequences of m-sample-long pink noise
    %%% Adapted from Hristo Zhivomirov (version 1.9.0.0)
    % https://de.mathworks.com/matlabcentral/fileexchange/42919-pink-red-blue-and-violet-noise-generation-with-matlab
    
    x = randn(m, n); % because fft works on columns rather than rows
    
    unique_pts = ceil((m + 1) / 2);
    unique_pts_idx = (1:unique_pts)';
    
    X = fft(x);
    X = X(1:unique_pts, :);
    X = X.*repmat((unique_pts_idx.^(-0.5)), 1, n);
    
    if mod(m, 2)
       X = cat(1, X, conj(X(end:-1:2, :)));
    else
       X = cat(1, X, conj(X(end-1:-1:2, :)));
    end
    
    x = real(ifft(X));
    x = x - repmat(mean(x, 1), m, 1);
    x = x ./ repmat(std(x, 1), m, 1);
    x = x';
end