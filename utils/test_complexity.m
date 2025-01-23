function [powers, rsqs, results] = test_complexity(data_x, data_y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test_complexity
%   Fits each row with polyfit of each order in "order_to_test", and for
%   each, returns the order which fits best.
%
% NOTE - power1 fits f(x) = a*x^b       i.e. it must go through (0,0)
%        power2 fits f(x) = a*x^b+c     i.e. it is flexible
%        exp1 fits f(x) = a*exp(b*x)
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
    % Save warning state and (temporarily) disable all warnings
    w = warning();
    warning('off', 'all');

    % Containers
    results = struct();

    results.x = cell(size(data_y, 1), 1);
    results.y = cell(size(data_y, 1), 1);

    results.power1 = struct();
    results.power1.fits = cell(size(data_y, 1), 1);
    results.power1.rsqs = nan(size(data_y, 1), 1);
    results.power1.coef = nan(size(data_y, 1), 1);
    results.power1.a1 = nan(size(data_y, 1), 1);
    results.power1.a2 = nan(size(data_y, 1), 1);

    results.power2 = struct();
    results.power2.fits = cell(size(data_y, 1), 1);
    results.power2.rsqs = nan(size(data_y, 1), 1);
    results.power2.coef = nan(size(data_y, 1), 1);
    results.power2.a1 = nan(size(data_y, 1), 1);
    results.power2.a2 = nan(size(data_y, 1), 1);
    results.power2.a3 = nan(size(data_y, 1), 1);

    results.exp1 = struct();
    results.exp1.fits = cell(size(data_y, 1), 1);
    results.exp1.rsqs = nan(size(data_y, 1), 1);
    results.exp1.coef = nan(size(data_y, 1), 1);

    results.lin = struct();
    results.lin.fits = cell(size(data_y, 1), 1);
    results.lin.rsqs = nan(size(data_y, 1), 1);
    results.lin.coef = nan(size(data_y, 1), 1);

    results.poly2 = struct();
    results.poly2.fits = cell(size(data_y, 1), 1);
    results.poly2.rsqs = nan(size(data_y, 1), 1);
    results.poly2.coef = nan(size(data_y, 1), 1);

    results.poly3 = struct();
    results.poly3.fits = cell(size(data_y, 1), 1);
    results.poly3.rsqs = nan(size(data_y, 1), 1);
    results.poly3.coef = nan(size(data_y, 1), 1);

    % Fit
    for yid = 1 : size(data_y, 1)
        % Copy current data vectors
        cur_x = data_x;
        cur_y = data_y(yid, :);

        % Remove NaNs because it breaks the fitting procedure
        cur_x(isnan(cur_y)) = [];
        cur_y(isnan(cur_y)) = [];

        % Skip if less than 4 data points
        if (length(cur_y) < 4)
            continue;
        end

        % Fit data with order
        [obj_pow1, gof_pow1] = fit(cur_x', cur_y', 'power1');
        [obj_pow2, gof_pow2] = fit(cur_x', cur_y', 'power2');
        [obj_exp1, gof_exp1] = fit(cur_x', cur_y', 'exp1');
        [obj_lin, gof_lin] = fit(cur_x', cur_y', 'poly1');
        [obj_poly2, gof_poly2] = fit(cur_x', cur_y', 'poly2');
        [obj_poly3, gof_poly3] = fit(cur_x', cur_y', 'poly3');
        
        % Store results
        results.x{yid} = cur_x;
        results.y{yid} = cur_y;

        % power1 = a1 * x ^ a2
        a = coeffvalues(obj_pow1);
        results.power1.fits{yid} = struct();
        results.power1.fits{yid}.fit = obj_pow1;
        results.power1.fits{yid}.gof = gof_pow1;
        results.power1.coef(yid) = a(2);
        results.power1.a1(yid) = a(1);
        results.power1.a2(yid) = a(2);
        results.power1.rsqs(yid) = gof_pow1.rsquare;

        % power2 = a1 * x ^ a2 + a3
        a = coeffvalues(obj_pow2);
        results.power2.fits{yid} = struct();
        results.power2.fits{yid}.fit = obj_pow2;
        results.power2.fits{yid}.gof = gof_pow2;
        results.power2.coef(yid) = a(2);
        results.power2.a1(yid) = a(1);
        results.power2.a2(yid) = a(2);
        results.power2.a3(yid) = a(3);
        results.power2.rsqs(yid) = gof_pow2.rsquare;

        % exp1 = a1 * exp ^ (a2 * x)
        a = coeffvalues(obj_exp1);
        results.exp1.fits{yid} = struct();
        results.exp1.fits{yid}.fit = obj_exp1;
        results.exp1.fits{yid}.gof = gof_exp1;
        results.exp1.coef(yid) = a(2);
        results.exp1.rsqs(yid) = gof_exp1.rsquare;

        % lin = p1 * x + p2
        a = coeffvalues(obj_lin);
        results.lin.fits{yid} = struct();
        results.lin.fits{yid}.fit = obj_lin;
        results.lin.fits{yid}.gof = gof_lin;
        results.lin.coef(yid) = a(1);
        results.lin.rsqs(yid) = gof_lin.rsquare;

        % poly2 = p1 * x ^ 2 + p2 * x + p3
        a = coeffvalues(obj_poly2);
        results.poly2.fits{yid} = struct();
        results.poly2.fits{yid}.fit = obj_poly2;
        results.poly2.fits{yid}.gof = gof_poly2;
        results.poly2.coef(yid) = a(1);
        results.poly2.rsqs(yid) = gof_poly2.rsquare;

        % poly3 = p1 * x ^ 3 + p2 * x ^ 2 + p3 * x + p4
        a = coeffvalues(obj_poly3);
        results.poly3.fits{yid} = struct();
        results.poly3.fits{yid}.fit = obj_poly3;
        results.poly3.fits{yid}.gof = gof_poly3;
        results.poly3.coef(yid) = a(1);
        results.poly3.rsqs(yid) = gof_poly3.rsquare;
    end

    % Set shortcut outputs
    powers = results.power1.coef;
    rsqs = results.power1.rsqs;

    % Reset warnings to original state
    warning(w);
end

