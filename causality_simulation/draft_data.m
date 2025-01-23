function [tss, caus_matrix, info] = draft_data(n_samples, n_sources, external_noise, maxdelay, seed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAFT_DATA
%   Generates time series n_samples-long (assumed 1000Hz sampling rate)
%   with their causality drafted either randomly (no seed argument), or
%   following a fix draft referenced by seed.
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
    % Set seed if needed
    if exist("seed", "var"), rng(seed); end

    % Select connections randomly and remove diag (auto-caus)
    caus_per_chan = 2;
    selected_proportion = min(caus_per_chan * 2 / n_sources, 0.5);    % * 2 because tril removes half connections
    rand_selected = (rand(n_sources) < selected_proportion) & ~diag(ones(n_sources, 1));

    % Remove all tril connections to make acyclic causality
    rand_selected(logical(tril(ones(n_sources)))) = false;

    % Get random delays for selected connections
    draft_delays = randi(maxdelay, n_sources, n_sources);
    draft_delays(~rand_selected) = 0.0;

    % Get random weights for selected connections
    mean_weight = 0.0;
    span_weights = 2;
    draft_weights = (rand(n_sources) - 0.5 + mean_weight) * span_weights;
    draft_weights(~rand_selected) = 0.0;

    % Reset seed
    rng("shuffle");

    % Log output details
    info = struct();
    info.draft_delays = draft_delays;
    info.draft_weights = draft_weights;
    info.maxdelay = maxdelay;
    
    [tss, caus_matrix] = drafted_model(n_samples, draft_delays, draft_weights, external_noise);
end
