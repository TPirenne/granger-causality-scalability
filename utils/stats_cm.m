function stats = stats_cm(cm, gt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATS_CM
%   Compares cm (causal map) with gt (ground truth) and return the true
%   positive, true negative, false positive, false negative and derived
%   measures. The NW-SE diagonal is ignored as we are not interested in
%   autocausality.
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

    % Replace NaN in diagonal of CM by anything else (is ignored anyways)
    gt(isnan(gt)) = 0;
    cm(isnan(cm)) = 0;

    % Init stats
    stats = struct();

    % Maps
    tp_map = (cm == gt & gt & ~diag(ones(1, size(cm, 1))));
    tn_map = (cm == gt & ~gt & ~diag(ones(1, size(cm, 1))));
    fp_map = (cm ~= gt & cm & ~diag(ones(1, size(cm, 1))));
    fn_map = (cm ~= gt & ~cm & ~diag(ones(1, size(cm, 1))));

    stats.tp_map = tp_map;
    stats.tn_map = tn_map;
    stats.fp_map = fp_map;
    stats.fn_map = fn_map;
    
    % Basic stats
    tp = sum(sum(tp_map));
    tn = sum(sum(tn_map));
    fp = sum(sum(fp_map));
    fn = sum(sum(fn_map));
    p = fn + tp;
    n = fp + tn;
    predp = fp + tp;
    predn = fn + tn;
    tot = fp + fn + tp + tn;
    
    stats.tp = tp;
    stats.tn = tn;
    stats.fp = fp;
    stats.fn = fn;
    stats.p = p;
    stats.n = n;
    stats.predp = predp;
    stats.predn = predn;
    stats.tot = tot;
    
    % Advanced stats
    stats.accuracy = (tn + tp) / tot; % true rate
    stats.precision = tp / predp;   % positive predictive value
    stats.recall = tp / p;          % true positive rate
    stats.specificity = tn / n;     % true negative rate
    stats.f1 = (2 * stats.precision * stats.recall) / ( stats.precision + stats.recall );
    stats.balanced_accuracy = ( (tp / p) + (tn / n) ) / 2;
end

