function [tss, caus_matrix] = drafted_model(n_samples, draft_delays, draft_weights, external_noise, internal_noise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAFTED_MODEL
%   Generates time series n_samples-long (assumed 1000Hz sampling rate)
%   with their causality defined by the draft_delays map. Draft_delays
%   describes causal relationships, with the delay they entail. It is a
%   matrix of integers of dims (n_src x n_src). Links with no causality are
%   represented by 0. draft_weights is parallel to draft_delays, but
%   represents the weights in proportion to 1 of the source causing the
%   other.
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

    % For stabilisation purposes, crop first samples needed for all the ts
    % to have causality
    prefix = max(max(draft_delays));
    n_samples = n_samples + prefix;

    % Parameters
    n_sources = size(draft_delays, 1);
    
    if ~exist('external_noise', 'var')
        external_noise = 0.0;
    end
    
    % Model
    tss = generate_noise(n_sources, n_samples, 'gwn', 1);
    
    % Create causality
    for tid = 1 : n_samples
        for sid = 1 : n_sources
            delays = draft_delays(:, sid);
            caus_ids = find(delays > 0);
            delays = delays(caus_ids);
            weights = draft_weights(caus_ids, sid);

            % Check that weights do not add up higher than 1 unless
            % internal_noise was specified
            if (1 - abs(sum(weights)) < 0) && ~exist('internal_noise', 'var')
                error("Weights of one source add up to more than 1.");
            end

            % If internal_noise was not specified, use leftover weight
            if ~exist('internal_noise', 'var')
                internal_noise = (1 - abs(sum(weights)));
            end

            % First weight tss by internal noise
            new_tp = internal_noise * tss(sid, tid);

            % Add causal contributions
            for iid = 1 : length(caus_ids)
                new_tp = new_tp + weights(iid) * tss_delay(tss, caus_ids(iid), tid, delays(iid));
            end

            % Set new time point into return matrix
            tss(sid, tid) = new_tp;
        end
    end
    
    % Add external noise to the resulting time series
    if external_noise ~= 0
        tss = (1 - external_noise) * tss + generate_noise(n_sources, n_samples, 'gwn', external_noise);
    end

    % Remove prefix
    tss = tss(:, (prefix+1):end);
    
    % Causality matrix
    caus_matrix = logical(draft_delays);
    caus_matrix = caus_matrix .* (diag(NaN(n_sources, 1)) + ones(n_sources, n_sources));
end

%% Utils
% Returns tss(sid, tid - delay) if it exists, otherwise return tss(sid, tid)
function tp = tss_delay(tss, sid, tid, delay)
    if (tid - delay) > 0
        tp = tss(sid, tid - delay);
    else
        tp = tss(sid, tid);
    end
end