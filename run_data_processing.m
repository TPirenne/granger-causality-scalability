%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_data_processing
%
% This script loads the data in /data/[method]/, processes it, generates
% relevant figures, and saves them in /data/results.
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
%% Fig.2a %%
% Parameters
timestr = "202409051456";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 800;
fig_height = 1000;
plotspan = {[1,2], [3,4], [5,6], 7,8, [9,10], [11,12]};
SAVE = true;
save_path = sprintf('data/results/F02a');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Display f1
for eid = 1 : length(draft{mid}.exn)
    f = figure();

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    for mid = 1 : length(methods)
        subplot(6, 2, plotspan{mid});
        hold("on");

        % title(methods{mid});
        xlabel("ns");
        % ylabel(methods{mid});
        % ylabel("f1 score");
        ylabel({sprintf("\\fontsize{14}%s", methods{mid}),'\fontsize{10} f1-score'});

        for cid = 1 : length(draft{mid}.nc)
            color_shades = get_colors(colors{mid}, []);
            color = color_shades{end+1-cid};

            % Compute mean and std
            mean_f1 = squeeze(mean(draft{mid}.f1s(eid, cid, :, 1, :), 5));
            std_f1 = squeeze(std(draft{mid}.f1s(eid, cid, :, 1, :), [], 5));

            plot(draft{mid}.ns, mean_f1, "DisplayName", sprintf("nc=%d", draft{mid}.nc(cid)), "Marker", ".", "MarkerSize", 10, "LineWidth", 1, "Color", color);
        end

        xlim([draft{mid}.ns(1), draft{mid}.ns(end)]);
        ylim([0, 1]);
        legend("AutoUpdate", "off", "Location", "eastoutside");
        yline(0.9, "LineStyle", ":", "Color", get_colors("red"));
    end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('fig2_perf_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

%% Fig 2b %%
% Parameters
timestr = "202412222218";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};
plotspan = {1:1:48, 52:1:89, 93:1:96, 100:1:103, 107:1:109, 113:1:117, 121:1:125};

% Save parameters
fig_width = 600;
fig_height = 1500;
SAVE = true;
save_path = sprintf('data/results/F02b');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    % load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    % draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Display f1s
for eid = 1 : length(draft{1}.exn)
    % Printing params
    f = figure();

    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);

    for mid = 1 : length(methods)
        % Open subfig
        subplot(125, 1, plotspan{mid});
        % subid = eid + (mid - 1) * length(draft{1}.exn);
        % subplot(length(methods), length(draft{1}.exn), subid);

        % Color
        color_red = get_colors("red", 600);
        color_green = get_colors("green", 600);
        color_light_green = get_colors("green", 50);

        % Process data
        % fail_mask = any(squeeze(cellfun(@(c) isfield(c, 'error') , draft{mid}.results(eid, :, :, :))), 3);
        % fail_mask = any(squeeze(isnan(draft{mid}.f1s(eid, :, :, :))), 3);
        perf_mask = draft{mid}.f1s(:, :); % perf_mask = mean(squeeze(draft{mid}.f1s(eid, :, :, :)), 3);
        % time_mask = draft{mid}.runtimes(:, :);
        ns = draft{mid}.ns;

        % Skipped perfs > 0.9 in same nc need to be added manually
        for cid = 1 : size(perf_mask, 1)
            fillstart = NaN;

            for sid = 1 : size(perf_mask, 2)
                if ~isnan(fillstart) && ~isnan(perf_mask(cid, sid))
                    perf_mask(cid, fillstart:1:sid-1) = perf_mask(cid, sid);
                    fillstart = NaN;
                end

                if perf_mask(cid, sid) > 0.9 && sid < size(perf_mask, 2) && isnan(perf_mask(cid, sid + 1))
                    fillstart = sid + 1;
                end
            end
        end

        % Identify skipped values because of overtime in previous ns
        overtime_mask = false(size(perf_mask));
        rts = draft{mid}.runtimes(:, :) > 1000; % rts = any(squeeze(draft{mid}.runtimes(eid, :, :, :) > 1200), 3);
        for maskncid = 1 : size(rts, 1)
            overflow = false;
            for masknsid = 1 : size(rts, 2)
                if overflow
                    overtime_mask(maskncid, masknsid) = true;
                elseif rts(maskncid, masknsid)
                    % overtime_mask(maskncid, masknsid) = true;
                    overflow = true;
                end
            end
        end

        % Identify overtimed nc
        overtime_nc = all(isnan(draft{mid}.runtimes(:, :)), 2);
        overtime_mask(overtime_nc, :) = 1;

        % Remove skipped values from perf_mask
        failed_mask = isnan(perf_mask) & ~overtime_mask;
        perf_mask(failed_mask) = -1;

        %%% Fetch border values for feasibility %%%
        % Horizontally
        draft{mid}.feasibility_data{eid} = [];
        for fcid = 1 : size(failed_mask, 1)
            for fsid = 1 : size(failed_mask, 2)
                if fsid == 1
                    % Init
                    prev = failed_mask(fcid, fsid);
                end

                if failed_mask(fcid, fsid) ~= prev
                    % Found two sides of border
                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data{eid} = cat(1, draft{mid}.feasibility_data{eid}, tuple);

                    tuple = [draft{mid}.ns(fsid-1), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data{eid} = cat(1, draft{mid}.feasibility_data{eid}, tuple);
                    break;
                end

                % Update prev
                prev = failed_mask(fcid, fsid);
            end
        end

        % Vertically
        for fsid = 1 : size(failed_mask, 2)
            for fcid = 1 : size(failed_mask, 1)
                if fcid == 1
                    % Init
                    prev = failed_mask(fcid, fsid);
                end

                if failed_mask(fcid, fsid) ~= prev
                    % Found two sides of border
                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data{eid} = cat(1, draft{mid}.feasibility_data{eid}, tuple);

                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid-1)];
                    draft{mid}.feasibility_data{eid} = cat(1, draft{mid}.feasibility_data{eid}, tuple);
                    break;
                end

                % Update prev
                prev = failed_mask(fcid, fsid);
            end
        end

        % Remove doubles
        draft{mid}.feasibility_data{eid} = unique(draft{mid}.feasibility_data{eid}, 'rows');

        % Linear regression
        if ~isempty(draft{mid}.feasibility_data{eid})
            x = draft{mid}.feasibility_data{eid}(:, 1);
            y = draft{mid}.feasibility_data{eid}(:, 2);
            draft{mid}.feasibility_border{eid} = fitlm(x, y);
        end

        % Crop all NaN lines
        perf_mask(all(isnan(perf_mask), 2), :) = [];
        draft{mid}.nc = draft{mid}.nc(1:size(perf_mask, 1));

        %%% For display, spread values to fit continuous spectrum %%%
        % 1 - original scope ; 2 - extended scope
        nc1 = draft{mid}.nc;
        ns1 = draft{mid}.ns;
        nc2 = nc1(1):nc1(1):nc1(end);
        ns2 = ns1(1):ns1(1):ns1(end);
        perf_mask1 = perf_mask;
        perf_mask2 = zeros(length(nc2), length(ns2));

        cid1 = 1;
        for cid2 = 1 : length(nc2)
            if cid1 < length(nc1) && nc1(cid1 + 1) == nc2(cid2)
                cid1 = cid1 + 1;
            end

            sid1 = 1;
            for sid2 = 1 : length(ns2)
                if sid1 < length(ns1) && ns1(sid1 + 1) == ns2(sid2)
                    sid1 = sid1 + 1;
                end

                perf_mask2(cid2, sid2) = perf_mask1(cid1, sid1);
            end
        end

        % Crop ns at 12000
        ns2 = ns2(1:find(ns2 == 10000));
        perf_mask2 = perf_mask2(:, 1:length(ns2));

        %%% Plot %%%
        hx = ns2;
        hy = fliplr(nc2);
        h = heatmap(hx, hy, double(flipud(perf_mask2)), "CellLabelColor", "none");
        if mid == length(methods), h.XLabel = "ns"; else, h.XLabel = ""; end
        if mid < 3, h.YLabel = "nc"; else, h.YLabel = ""; end
        h.FontSize = 10;
        h.GridVisible = 'off';
        cmap = get_colormap(color_red, color_light_green, color_green);
        colormap(f, cmap);
        if mid ~= 1, colorbar('off'); end
        clim([-1,1]);
        title(sprintf("\\rm %s", methods{mid}));

        % Only subset of ticks
        if mid == length(methods), show_idx = mod(find(hx), 10) == 0; else, show_idx = false(size(hx)); end
        h.XDisplayLabels(~show_idx) = {''};

        if mid < 3, show_idy = mod(hy, 50) == 0; else, show_idy = mod(hy, 25) == 0; end
        h.YDisplayLabels(~show_idy) = {''};
    end

    % Save figure as fig and png
    if SAVE
        filename = strrep(sprintf('f1s_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

%%% Feasibility plots %%%
fig_width = 800;
fig_height = 400;
for eid = 1 : length(draft{1}.exn)
    f = figure();
    hold("on");

    % Figure format
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);

    for mid = 1 : length(methods)
        if ~isempty(draft{mid}.feasibility_data{eid})
            % Color
            color_shades = get_colors(colors{mid}, []);
            shade_prop = 0.6;
            color = color_shades{round(length(color_shades) * shade_prop)};

            % Fit information
            x = draft{mid}.feasibility_data{eid}(:,1);
            y = draft{mid}.feasibility_data{eid}(:,2);
            mdl = draft{mid}.feasibility_border{eid};

            % Border points
            scatter(x, y, 20, color, "filled", "o", "HandleVisibility", "off", "MarkerFaceAlpha", 0.3, "MarkerEdgeAlpha", 0.3);

            % Linear regression
            x = (0:20:5000)';
            y = predict(mdl, x);
            plot(x, y, "Color", color, "DisplayName", methods{mid}, "LineWidth", 2);

            % Figure meta
            xlim([0,5000]);
            ylim([0,400]);
            title("Feasibility border estimation");
            xlabel("ns");
            ylabel("nc");
        end
    end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('feasibility_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

%% Fig 2c %%
% Parameters
timestr = "202412121736";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 800;
fig_height = 1000;
SAVE = true;
save_path = sprintf('data/results/F02c');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    % load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    % draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Display f1s
for eid = 1 : length(draft{1}.exn)
    % Printing params
    f = figure();

    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);

    % Display f1s
    for mid = 1 : length(methods)
        % Open subfig
        subid = mid;
        subplot(length(methods), length(draft{1}.exn), subid);

        % Color
        color_red = get_colors("red", 600);
        color_green = get_colors("green", 600);
        color_light_green = get_colors("green", 50);

        % Process data
        perf_mask = mean(squeeze(draft{mid}.f1s), 3);
        ns = draft{mid}.ns;

        % Remove skipped values from perf_mask
        failed_mask = isnan(perf_mask);
        perf_mask(failed_mask) = -1;

        %%% Fetch border values for feasibility %%% ---> Failed mask !! And
        %%% figure out how to get last true instead of first
        % Horizontally
        draft{mid}.feasibility_data = [];
        for fcid = 1 : size(failed_mask, 1)
            for fsid = 1 : size(failed_mask, 2)
                if fsid == 1
                    % Init
                    prev = failed_mask(fcid, fsid);
                end

                if failed_mask(fcid, fsid) ~= prev
                    % Found two sides of border
                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data = cat(1, draft{mid}.feasibility_data, tuple);

                    tuple = [draft{mid}.ns(fsid-1), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data = cat(1, draft{mid}.feasibility_data, tuple);
                    break;
                end

                % Update prev
                prev = failed_mask(fcid, fsid);
            end
        end

        % Vertically
        for fsid = 1 : size(failed_mask, 2)
            for fcid = 1 : size(failed_mask, 1)
                if fcid == 1
                    % Init
                    prev = failed_mask(fcid, fsid);
                end

                if failed_mask(fcid, fsid) ~= prev
                    % Found two sides of border
                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid)];
                    draft{mid}.feasibility_data = cat(1, draft{mid}.feasibility_data, tuple);

                    tuple = [draft{mid}.ns(fsid), draft{mid}.nc(fcid-1)];
                    draft{mid}.feasibility_data = cat(1, draft{mid}.feasibility_data, tuple);
                    break;
                end

                % Update prev
                prev = failed_mask(fcid, fsid);
            end
        end

        % Remove doubles
        draft{mid}.feasibility_data = unique(draft{mid}.feasibility_data, 'rows');

        % Linear regression
        if ~isempty(draft{mid}.feasibility_data)
            x = draft{mid}.feasibility_data(:, 1);
            y = draft{mid}.feasibility_data(:, 2);
            draft{mid}.feasibility_border = fitlm(x,y);
        end

        %%% Plot %%%
        h = heatmap(ns, fliplr(draft{mid}.nc), double(flipud(perf_mask)), "CellLabelColor", "none");
        h.XLabel = "ns";
        h.YLabel = "nc";
        cmap = get_colormap(color_red, color_light_green, color_green);
        colormap(f, cmap);
        colorbar('off');
        clim([-1,1]);
        title(methods{mid});
    end
    
    % Save figure as fig and pdf
    if SAVE
        saveas(f, sprintf("%s/f1s.fig", save_path));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/f1s.png", save_path));
        close(f);
    end
    
    %%% Feasibility plots %%%
    fig_width = 800;
    fig_height = 300;
    f = figure();
    hold("on");
    fontsize(f, 10, "points");

    % Figure format
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);

    for mid = 1 : length(methods)
        if ~isempty(draft{mid}.feasibility_data)
            % Color
            color_shades = get_colors(colors{mid}, []);
            shade_prop = 0.6;
            color = color_shades{round(length(color_shades) * shade_prop)};

            % Fit information
            x = draft{mid}.feasibility_data(:,1);
            y = draft{mid}.feasibility_data(:,2);
            mdl = draft{mid}.feasibility_border;

            % Border points
            scatter(x, y, 20, color, "filled", "o", "HandleVisibility", "off", "MarkerFaceAlpha", 0.3, "MarkerEdgeAlpha", 0.3);

            % Linear regression
            x = (0:20:5000)';
            y = predict(mdl, x);
            plot(x, y, "Color", color, "DisplayName", sprintf("%s (%.3f)", methods{mid}, mdl.Coefficients.Estimate(2)), "LineWidth", 2);

            % Figure meta
            xlim([0,5000]);
            ylim([0,400]);
            % title("Feasibility border estimation");
            xlabel("ns*");
            ylabel("nc");
        end
    end
    
    % Save figure as fig and pdf
    if SAVE
        saveas(f, sprintf("%s/feasibility.fig", save_path));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/feasibility.png", save_path));
        close(f);
    end
end

%% Fig.3a %%
% Parameters
timestr = "202411241722";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 600;
fig_height = 600;
SAVE = true;
save_path = sprintf('data/results/F03a');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Create container for the complexities estimations
powfit = struct();
powfit.data_y = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.data_x = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.powers = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.types = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.powers_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.powers_std = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.rsqs = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.rsqs_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.fits = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc));
powfit.exn = draft{mid}.exn;
powfit.methods = methods;
powfit.nc = draft{mid}.nc;

% Estimate complexities
for mid = 1 : length(methods)
    for eid = 1 : length(draft{mid}.exn)
        for cid = 1 : length(draft{mid}.nc)
            % Get the raw data
            data_y = squeeze(draft{mid}.runtimes(eid, cid, :, 1, :));
            data_x = draft{mid}.ns;

            % Run the complexity test by fitting
            [p, rs, results] = test_complexity(data_x, data_y');

            % Store results in the containers
            powfit.data_y{eid,mid,cid} = data_y;
            powfit.data_x{eid,mid,cid} = data_y;
            powfit.powers{eid,mid,cid} = p;
            powfit.rsqs{eid,mid,cid} = rs;
            powfit.fits{eid,mid,cid} = results;
            powfit.powers_mn(eid,mid,cid) = mean(p);
            powfit.powers_std(eid,mid,cid) = std(p);
            powfit.rsqs_mn(eid,mid,cid) = mean(rs);
        end
    end
end

% Display
for eid = 1 : length(draft{mid}.exn)
    f = figure();

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    % for logid = 1 : 2
        for cid = 1 : length(draft{1}.nc)
            % plotid =  logid + 2 * cid - 2;  % To draw subplots col,row insead of row,col like standard
            % ax = subplot(length(draft{1}.nc), 2, plotid);
            ax = subplot(length(draft{1}.nc), 1, cid);
            ax.FontSize = 11;
            hold("on");
    
            xlabel("ns");

            % if logid == 1
                ylabel({sprintf("\\bf nc=%d", draft{1}.nc(cid)),'\rm computation time (s)'});
            % end

            for mid = 1 : length(methods)
                if size(draft{mid}.runtimes, 2) >= cid
                    color_shades = get_colors(colors{mid}, []);
                    shade_prop = 0.6;
                    color = color_shades{round(length(color_shades) * shade_prop)};
                    color_light = color_shades{round(length(color_shades) * 0.1)};

                    % Extract relevant runtimes and f1s
                    runtimes = squeeze(draft{mid}.runtimes(eid, cid, :));
                    f1s = squeeze(draft{mid}.f1s(eid, cid, :));
            
                    % Mask trials where run failed completely
                    fail_mask = squeeze(cellfun(@(c) isfield(c, 'error') , draft{mid}.results(eid, cid, :)));
                    masked_runtimes = runtimes;
                    masked_runtimes = masked_runtimes(~fail_mask);
                    masked_f1s = f1s;
                    masked_f1s(isnan(masked_f1s)) = 0;
                    masked_f1s = masked_f1s(~fail_mask);
                    masked_ns = draft{mid}.ns(~fail_mask);

                    % Get performance color from colormap
                    cmap = get_colormap(color_light, color);
                    fcolors = use_colormap(masked_f1s, cmap);
                    
                    % Display masked line
                    plot(masked_ns, masked_runtimes, "DisplayName", methods{mid}, "LineWidth", 1, "Color", color);

                    % Display markers
                    marker_size = 15;
                    scatter(masked_ns, masked_runtimes, marker_size, fcolors, 'filled', 'HandleVisibility', 'off');
                    scatter(masked_ns, masked_runtimes, marker_size, color, 'HandleVisibility', 'off', "Marker", "o");
                    clim([0,1]);
                end
            end
            % 
            % if logid == 1
            %     % legend("Location", "northeast", "AutoUpdate","off");
            % else
            %     % ax.XScale = 'log';
            %     ax.YScale = 'log';
            % end

            yline(1000, "LineStyle", ":", "Color", get_colors("red"), "DisplayName", "");
            xlim([0, 10000]);
            ylim([0, 1200]);
        end
    % end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('runtimes_ns_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        save(sprintf("%s/powfit.mat", save_path), 'powfit', '-v7.3');
        close(f);
    end
end

%% Fig.3b %%
% Parameters
timestr = "202411260638";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 600;
fig_height = 600;
SAVE = true;
save_path = sprintf('data/results/F03b');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Create container for the complexities estimations
powfit = struct();
powfit.data_y = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.data_x = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.powers = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.types = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.powers_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.powers_std = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.rsqs = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.rsqs_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.fits = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.ns));
powfit.exn = draft{mid}.exn;
powfit.methods = methods;
powfit.ns = draft{mid}.ns;

% Estimate complexities
for mid = 1 : length(methods)
    for eid = 1 : length(draft{mid}.exn)
        for sid = 1 : length(draft{mid}.ns)
            % Get the raw data
            data_y = squeeze(draft{mid}.runtimes(eid, :, sid, 1, :));
            data_x = draft{mid}.nc;

            % Run the complexity test by fitting
            [p, rs, results] = test_complexity(data_x, data_y');

            % Store results in the containers
            powfit.data_y{eid,mid,sid} = data_y;
            powfit.data_x{eid,mid,sid} = data_y;
            powfit.powers{eid,mid,sid} = p;
            powfit.rsqs{eid,mid,sid} = rs;
            powfit.fits{eid,mid,sid} = results;
            powfit.powers_mn(eid,mid,sid) = mean(p);
            powfit.powers_std(eid,mid,sid) = std(p);
            powfit.rsqs_mn(eid,mid,sid) = mean(rs);
        end
    end
end

% Display
for eid = 1 : length(draft{mid}.exn)
    f = figure();

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    for sid = 1 : length(draft{1}.ns)
        ax = subplot(length(draft{1}.ns), 1, sid);
        ax.FontSize = 11;
        hold("on");

        xlabel("nc");

        ylabel({sprintf("\\bf ns=%d", draft{1}.ns(sid)),'\rm computation time (s)'});

        for mid = 1 : length(methods)
            if size(draft{mid}.runtimes, 3) >= sid
                color_shades = get_colors(colors{mid}, []);
                shade_prop = 0.6;
                color = color_shades{round(length(color_shades) * shade_prop)};
                color_light = color_shades{round(length(color_shades) * 0.1)};

                % Extract relevant runtimes and f1s
                runtimes = draft{mid}.runtimes(eid, :, sid);
                f1s = draft{mid}.f1s(eid, :, sid);
        
                % Mask trials where run failed completely
                fail_mask = cellfun(@(c) isfield(c, 'error') , draft{mid}.results(eid, :, sid));
                masked_runtimes = runtimes;
                masked_runtimes = masked_runtimes(~fail_mask);
                masked_f1s = f1s;
                masked_f1s(isnan(masked_f1s)) = 0;
                masked_f1s = masked_f1s(~fail_mask);
                masked_nc = draft{mid}.nc(~fail_mask);

                % Get performance color from colormap
                cmap = get_colormap(color_light, color);
                fcolors = use_colormap(masked_f1s, cmap);
                
                % Display masked line
                plot(masked_nc, masked_runtimes, "DisplayName", methods{mid}, "LineWidth", 1, "Color", color);

                % Display markers
                marker_size = 15;
                scatter(masked_nc, masked_runtimes, marker_size, fcolors, 'filled', 'HandleVisibility', 'off');
                scatter(masked_nc, masked_runtimes, marker_size, color, 'HandleVisibility', 'off', "Marker", "o");
                clim([0,1]);
            end
        end

        % legend("Location", "northeast", "AutoUpdate","off");

        yline(1000, "LineStyle", ":", "Color", get_colors("red"), "DisplayName", "");
        xlim([0, 400]);
        ylim([0, 1200]);
    end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('runtimes_nc_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        save(sprintf("%s/powfit.mat", save_path), 'powfit', '-v7.3');
        close(f);
    end
end

%% Fig.3c %%
% Parameters
timestr = "202411282215";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 600;
fig_height = 600;
SAVE = true;
save_path = sprintf('data/results/F03c');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Create container for the complexities estimations
powfit = struct();
powfit.data_y = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.data_x = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.powers = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.types = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.powers_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.powers_std = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.rsqs = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.rsqs_mn = nan(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.fits = cell(length(draft{mid}.exn), length(methods), length(draft{mid}.nc), length(draft{mid}.ns));
powfit.exn = draft{mid}.exn;
powfit.methods = methods;
powfit.nc = draft{mid}.nc;
powfit.ns = draft{mid}.ns;

% Estimate complexities
for mid = 1 : length(methods)
    for eid = 1 : length(draft{mid}.exn)
        for cid = 1 : length(draft{mid}.nc)
            for sid = 1 : length(draft{mid}.ns)
                % Get the raw data
                data_y = squeeze(draft{mid}.runtimes(eid, cid, sid, :, 1));
                data_x = draft{mid}.no;

                % Run the complexity test by fitting
                [p, rs, results] = test_complexity(data_x, data_y');

                % Store results in the containers
                powfit.data_y{eid,mid,cid,sid} = data_y;
                powfit.data_x{eid,mid,cid,sid} = data_y;
                powfit.powers{eid,mid,cid,sid} = p;
                powfit.rsqs{eid,mid,cid,sid} = rs;
                powfit.fits{eid,mid,cid,sid} = results;
                powfit.powers_mn(eid,mid,cid,sid) = mean(p);
                powfit.powers_std(eid,mid,cid,sid) = std(p);
                powfit.rsqs_mn(eid,mid,cid,sid) = mean(rs);
            end
        end
    end
end

% Display
for eid = 1 : length(draft{1}.exn)
    for sid = 1 : length(draft{1}.ns)
        f = figure();

        % Printing params
        set(gcf,'PaperPositionMode','auto');         
        set(gcf,'PaperOrientation','landscape');
        set(gcf, 'Position',  [1, 1, 100 + fig_width, 100 + fig_height]);   % Resize fig window
        
        for cid = 1 : length(draft{1}.nc)
            % plotid =  sid + (cid - 1) * length(draft{1}.ns);
            ax = subplot(length(draft{1}.nc), 1, cid);
            ax.FontSize = 11;
            hold("on");
    
            xlabel("no");
    
            if sid == 1
                ylabel({sprintf("\\bf nc=%d", draft{1}.nc(cid)),'\rm computation time (s)'});
            end

            if cid == 1
                title(sprintf("ns=%d", draft{1}.ns(sid)));
            end

            for mid = 1 : length(methods)
                if size(draft{mid}.runtimes, 3) >= sid && size(draft{mid}.runtimes, 2) >= cid
                    color_shades = get_colors(colors{mid}, []);
                    shade_prop = 0.6;
                    color = color_shades{round(length(color_shades) * shade_prop)};
                    color_light = color_shades{round(length(color_shades) * 0.1)};
    
                    % Extract relevant runtimes and f1s
                    runtimes = squeeze(draft{mid}.runtimes(eid, cid, sid, :));
                    f1s = squeeze(draft{mid}.f1s(eid, cid, sid, :));
            
                    % Mask trials where run failed completely
                    fail_mask = squeeze(cellfun(@(c) isfield(c, 'error') , draft{mid}.results(eid, cid, sid, :)));
                    masked_runtimes = runtimes;
                    masked_runtimes = masked_runtimes(~fail_mask);
                    masked_f1s = f1s;
                    masked_f1s(isnan(masked_f1s)) = 0;
                    masked_f1s = masked_f1s(~fail_mask);
                    masked_no = draft{mid}.no(~fail_mask);
    
                    % Get performance color from colormap
                    cmap = get_colormap(color_light, color);
                    fcolors = use_colormap(masked_f1s, cmap);
                    
                    % Display masked line
                    plot(masked_no, masked_runtimes, "DisplayName", methods{mid}, "LineWidth", 1, "Color", color);
    
                    % Display markers
                    marker_size = 15;
                    scatter(masked_no, masked_runtimes, marker_size, fcolors, 'filled', 'HandleVisibility', 'off');
                    scatter(masked_no, masked_runtimes, marker_size, color, 'HandleVisibility', 'off', "Marker", "o");
                    clim([0,1]);
                end
            end
    
            % legend("Location", "northeast", "AutoUpdate","off");
    
            yline(1000, "LineStyle", ":", "Color", get_colors("red"), "DisplayName", "");
            xlim([0, 200]);
            ylim([0, 1200]);
        end

        % Save figure as fig and pdf
        if SAVE
            filename = strrep(sprintf('runtimes_no_%d_%#1.1f', draft{1}.ns(sid), draft{mid}.exn(eid)), '.', '');
            saveas(f, sprintf("%s/%s.fig", save_path, filename));
            print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
            save(sprintf("%s/powfit.mat", save_path), 'powfit', '-v7.3');
            close(f);
        end
    end
end

%% Fig.3.legend %%
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};

% Save parameters
fig_width = 1000;
fig_height = 600;
SAVE = true;
save_path = sprintf('data/results/F03l');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

f = figure();
hold("on");
set(f, 'Position', [0,0,1024,1024]);

for mid = 1 : length(methods)
    color_shades = get_colors(colors{mid}, []);
    shade_prop = 0.6;
    color = color_shades{round(length(color_shades) * shade_prop)};
    
    % Display masked line
    plot(1:10, 1:10, "DisplayName", methods{mid}, "LineWidth", 2, "Color", color);
end

leg = legend("Location", "northeast", "AutoUpdate","off");

% Make legend the whole figure
set(f,'Position',(get(leg,'Position').*[0, 0, 1, 1].*get(f,'Position')));
set(leg,'Position',[0,0,1,1]);
set(f, 'Position', get(f,'Position') + [500, 400, 0, 0]);

% Save figure as fig and pdf
if SAVE
    saveas(f, sprintf("%s/legend.fig", save_path));
    print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/legend.png", save_path));
    close(f);
end

%%%% Color bars %%%%
for mid = 1 : length(methods)
    color_shades = get_colors(colors{mid}, []);
    shade_prop = 0.6;
    color = color_shades{round(length(color_shades) * shade_prop)};
    color_light = color_shades{round(length(color_shades) * 0.1)};
    cmap = get_colormap(color_light, color);
    
    % Display masked line
    fcb = figure('Units','normalized');
    colormap(fcb, cmap);
    hCB = colorbar('north');
    set(gca,'Visible',false)
    hCB.Position = [0.15 0.3 0.74 0.4];
    fcb.Position(4) = 0.1000;

    % Save figure as fig and pdf
    if SAVE
        saveas(fcb, sprintf("%s/cbar_%s.fig", save_path, methods{mid}));
        print(fcb, '-dpng','-loose','-image','-r600', sprintf("%s/cbar_%s.png", save_path, methods{mid}));
        close(fcb);
    end
end

%% Fig.4abc %%
% Parameters
timestr = "202411191733";
methods = {"mvgc-lwr", "mvgc-ols", "mvgc-lasso", "mvgc-sbl", "mvgc-lapsbl", "pdc-lwr", "pdc-ols"};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};
fit_attempts = 100;
fig_width = 1500;
fig_height = 400;

% Save parameters
SAVE = true;
save_path_a = sprintf('data/results/F04a');
save_path_b = sprintf('data/results/F04b');
save_path_c = sprintf('data/results/F04c');
if (SAVE && ~exist(save_path_a, 'dir')), mkdir(save_path_a); end
if (SAVE && ~exist(save_path_b, 'dir')), mkdir(save_path_b); end
if (SAVE && ~exist(save_path_c, 'dir')), mkdir(save_path_c); end

% Load data to display
draft = cell(1, length(methods));
for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/f1s.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/runtimes.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.f1s = f1s;
    draft{mid}.runtimes = runtimes;
    draft{mid}.results = results;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;
end

% Output fit container
fitted = cell(length(draft{mid}.exn), length(methods));
table_ngood = {nan(length(methods), 5), nan(length(methods), 5)};
table_MSEavg_good = {nan(length(methods), 5), nan(length(methods), 5)};
table_MSEstd_good = {nan(length(methods), 5), nan(length(methods), 5)};
table_AICavg_good = {nan(length(methods), 5), nan(length(methods), 5)};
table_AICstd_good = {nan(length(methods), 5), nan(length(methods), 5)};
table_coef_t0_good = {nan(length(methods), 4), nan(length(methods), 4)};
table_coef_t1_good = {nan(length(methods), 5), nan(length(methods), 5)};
table_coef_t2_good = {nan(length(methods), 7), nan(length(methods), 7)};
table_coef_t3_good = {nan(length(methods), 11), nan(length(methods), 11)};
table_coef_t4_good = {nan(length(methods), 4), nan(length(methods), 4)};

for eid = 1 : length(draft{1}.exn)
    for mid = 1 : length(methods)
        cft = struct();
        cft.method = methods{mid};

        % Format data into X ([c,s,o]), y(runtime)
        cft.y_raw = reshape(draft{mid}.runtimes(eid, :, :, :), [], 1);
        cft.X_raw = combinations(draft{mid}.no, draft{mid}.ns, draft{mid}.nc);
        cft.X_raw = table2array(cft.X_raw(:, [3,2,1]));

        % Remove data points where run failed (too low ns for nc/no)
        cft.isNaN = isnan(reshape(draft{mid}.f1s(eid, :, :, :), [], 1));
        cft.y = cft.y_raw(~cft.isNaN);
        cft.X = cft.X_raw(~cft.isNaN, :);

        % Create the function to fit -> t1(c,s,o) = a1 + a2 * c^(ac) * s^(as) * o^(ao)
        cft.t0.fctn = @(a, X) a(1) + a(2) .* (X(:,1).^(a(3))) .* (X(:,3).^(a(4)));
        cft.t1.fctn = @(a, X) a(1) + a(2) .* (X(:,1).^(a(3))) .* (X(:,2).^(a(4))) .* (X(:,3).^(a(5)));
        cft.t2.fctn = @(a, X) a(1) + (a(2).*X(:,1).^(a(5))) + (a(3).*X(:,2).^(a(6))) + (a(4).*X(:,3).^(a(7)));
        cft.t3.fctn = @(a, X) a(1) + (a(2).*X(:,1).^(a(6))) + (a(3).*X(:,2).^(a(7))) + (a(4).*X(:,3).^(a(8))) + (a(5) .* (X(:,1).^(a(9))) .* (X(:,2).^(a(10))) .* (X(:,3).^(a(11))));
        cft.t4.fctn = @(a, X) a(1) + a(2) .* X(:,1) + a(3) .* X(:,2) + a(4) .* X(:,3);

        %%%% Fit 0 %%%%
        cft.t0.all_models = cell(fit_attempts, 1);
        cft.t0.iswarning = false(fit_attempts, 1);
        cft.t0.warnings = cell(fit_attempts, 1);

        for aid = 1 : fit_attempts
            % Warning reset -> warning catching to exclude bad fits
            lastwarn('', '');

            % Try fit
            try
                a0 = rand(1,4);
                cft.t0.all_models{aid} = fitnlm(cft.X, cft.y, cft.t0.fctn, a0);
            catch e
                cur = struct();
                cur.error = e;
                cur.Coefficients.Estimate = nan(length(a0), 1);
                cur.Coefficients.SE = nan(length(a0), 1);
                cur.CoefficientNames = {"a1", "a2", "a3", "a4"};
                cur.ModelCriterion.AIC = NaN;
                cur.ModelCriterion.BIC = NaN;
                cur.MSE = NaN;
                cur.Rsquared.Ordinary = NaN;
                cur.Rsquared.Adjusted = NaN;
                cft.t0.all_models{aid} = cur;
            end

            % For each attempt, check if wanring was triggered
            [warnmsg, warnid] = lastwarn();

            if ~isempty(warnid)
                cft.t0.iswarning(aid) = true;
                cft.t0.warnings(aid) = {[warnmsg, warnid]};
            end
        end

        % Process models to keep converged ones
        cft.t0.all_coefs = cell2mat(cellfun(@(c) c.Coefficients.Estimate', cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_coefs_se = cell2mat(cellfun(@(c) c.Coefficients.SE', cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_AIC = cell2mat(cellfun(@(c) c.ModelCriterion.AIC, cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_BIC = cell2mat(cellfun(@(c) c.ModelCriterion.BIC, cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_MSE = cell2mat(cellfun(@(c) c.MSE, cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_RS = cell2mat(cellfun(@(c) c.Rsquared.Ordinary, cft.t0.all_models, 'UniformOutput', false));
        cft.t0.all_RS_adj = cell2mat(cellfun(@(c) c.Rsquared.Adjusted, cft.t0.all_models, 'UniformOutput', false));

        % Mask unreliable fits
        bad = any(isoutlier(cft.t0.all_coefs), 2);
        bad = any(cat(2, bad, isnan(cft.t0.all_MSE)), 2);
        cft.t0.goodness_mask = ~bad;

        %%%% Fit 1 %%%%
        cft.t1.all_models = cell(fit_attempts,1);
        cft.t1.iswarning = false(fit_attempts, 1);
        cft.t1.warnings = cell(fit_attempts, 1);

        for aid = 1 : fit_attempts
            % Warning reset -> warning catching to exclude bad fits
            lastwarn('', '');

            % Try fit
            try
                a0 = rand(1,5);
                cft.t1.all_models{aid} = fitnlm(cft.X, cft.y, cft.t1.fctn, a0);
            catch e
                cur = struct();
                cur.error = e;
                cur.Coefficients.Estimate = nan(length(a0), 1);
                cur.Coefficients.SE = nan(length(a0), 1);
                cur.CoefficientNames = {"a1", "a2", "a3", "a4", "a5"};
                cur.ModelCriterion.AIC = NaN;
                cur.ModelCriterion.BIC = NaN;
                cur.MSE = NaN;
                cur.Rsquared.Ordinary = NaN;
                cur.Rsquared.Adjusted = NaN;
                cft.t1.all_models{aid} = cur;
            end

            % For each attempt, check if wanring was triggered
            [warnmsg, warnid] = lastwarn();

            if ~isempty(warnid)
                cft.t1.iswarning(aid) = true;
                cft.t1.warnings(aid) = {[warnmsg, warnid]};
            end
        end

        % Process models to keep converged ones
        cft.t1.all_coefs = cell2mat(cellfun(@(c) c.Coefficients.Estimate', cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_coefs_se = cell2mat(cellfun(@(c) c.Coefficients.SE', cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_AIC = cell2mat(cellfun(@(c) c.ModelCriterion.AIC, cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_BIC = cell2mat(cellfun(@(c) c.ModelCriterion.BIC, cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_MSE = cell2mat(cellfun(@(c) c.MSE, cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_RS = cell2mat(cellfun(@(c) c.Rsquared.Ordinary, cft.t1.all_models, 'UniformOutput', false));
        cft.t1.all_RS_adj = cell2mat(cellfun(@(c) c.Rsquared.Adjusted, cft.t1.all_models, 'UniformOutput', false));

        % Mask unreliable fits
        bad = any(isoutlier(cft.t1.all_coefs), 2);
        bad = any(cat(2, bad, isnan(cft.t1.all_MSE)), 2);
        cft.t1.goodness_mask = ~bad;

        %%%% Fit 2 %%%%
        cft.t2.all_models = cell(fit_attempts,1);
        cft.t2.iswarning = false(fit_attempts, 1);
        cft.t2.warnings = cell(fit_attempts, 1);

        for aid = 1 : fit_attempts
            % Warning reset -> warning catching to exclude bad fits
            lastwarn('', '');

            % Try fit
            try
                a0 = rand(1,7);
                cft.t2.all_models{aid} = fitnlm(cft.X, cft.y, cft.t2.fctn, a0);
            catch e
                cur = struct();
                cur.error = e;
                cur.Coefficients.Estimate = nan(length(a0), 1);
                cur.Coefficients.SE = nan(length(a0), 1);
                cur.CoefficientNames = {"a1", "a2", "a3", "a4", "a5", "a6", "a7"};
                cur.ModelCriterion.AIC = NaN;
                cur.ModelCriterion.BIC = NaN;
                cur.MSE = NaN;
                cur.Rsquared.Ordinary = NaN;
                cur.Rsquared.Adjusted = NaN;
                cft.t2.all_models{aid} = cur;
            end

            % For each attempt, check if wanring was triggered
            [warnmsg, warnid] = lastwarn();

            if ~isempty(warnid)
                cft.t2.iswarning(aid) = true;
                cft.t2.warnings(aid) = {[warnmsg, warnid]};
            end
        end

        % Process models to select one good/representative
        cft.t2.all_coefs = cell2mat(cellfun(@(c) c.Coefficients.Estimate', cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_coefs_se = cell2mat(cellfun(@(c) c.Coefficients.SE', cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_AIC = cell2mat(cellfun(@(c) c.ModelCriterion.AIC, cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_BIC = cell2mat(cellfun(@(c) c.ModelCriterion.BIC, cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_MSE = cell2mat(cellfun(@(c) c.MSE, cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_RS = cell2mat(cellfun(@(c) c.Rsquared.Ordinary, cft.t2.all_models, 'UniformOutput', false));
        cft.t2.all_RS_adj = cell2mat(cellfun(@(c) c.Rsquared.Adjusted, cft.t2.all_models, 'UniformOutput', false));

        % Mask unreliable fits
        bad = any(isoutlier(cft.t2.all_coefs), 2);
        bad = any(cat(2, bad, isnan(cft.t2.all_MSE)), 2);
        cft.t2.goodness_mask = ~bad;

        %%%% Fit 3 %%%%
        cft.t3.all_models = cell(fit_attempts,1);
        cft.t3.iswarning = false(fit_attempts, 1);
        cft.t3.warnings = cell(fit_attempts, 1);

        for aid = 1 : fit_attempts
            % Warning reset -> warning catching to exclude bad fits
            lastwarn('', '');

            % Try fit
            try
                a0 = rand(1,11);
                cft.t3.all_models{aid} = fitnlm(cft.X, cft.y, cft.t3.fctn, a0);
            catch e
                cur = struct();
                cur.error = e;
                cur.Coefficients.Estimate = nan(length(a0), 1);
                cur.Coefficients.SE = nan(length(a0), 1);
                cur.CoefficientNames = {"a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"};
                cur.ModelCriterion.AIC = NaN;
                cur.ModelCriterion.BIC = NaN;
                cur.MSE = NaN;
                cur.Rsquared.Ordinary = NaN;
                cur.Rsquared.Adjusted = NaN;
                cft.t3.all_models{aid} = cur;
            end

            % For each attempt, check if wanring was triggered
            [warnmsg, warnid] = lastwarn();

            if ~isempty(warnid)
                cft.t3.iswarning(aid) = true;
                cft.t3.warnings(aid) = {[warnmsg, warnid]};
            end
        end

        % Process models to select one good/representative
        cft.t3.all_coefs = cell2mat(cellfun(@(c) c.Coefficients.Estimate', cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_coefs_se = cell2mat(cellfun(@(c) c.Coefficients.SE', cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_AIC = cell2mat(cellfun(@(c) c.ModelCriterion.AIC, cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_BIC = cell2mat(cellfun(@(c) c.ModelCriterion.BIC, cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_MSE = cell2mat(cellfun(@(c) c.MSE, cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_RS = cell2mat(cellfun(@(c) c.Rsquared.Ordinary, cft.t3.all_models, 'UniformOutput', false));
        cft.t3.all_RS_adj = cell2mat(cellfun(@(c) c.Rsquared.Adjusted, cft.t3.all_models, 'UniformOutput', false));

        % Mask unreliable fits
        bad = any(isoutlier(cft.t3.all_coefs), 2);
        bad = any(cat(2, bad, isnan(cft.t3.all_MSE)), 2);
        cft.t3.goodness_mask = ~bad;

        %%%%% Fit 4 %%%%
        cft.t4.all_models = cell(fit_attempts,1);
        cft.t4.iswarning = false(fit_attempts, 1);
        cft.t4.warnings = cell(fit_attempts, 1);

        for aid = 1 : fit_attempts
            % Warning reset -> warning catching to exclude bad fits
            lastwarn('', '');

            % Try fit
            try
                a0 = rand(1,4);
                cft.t4.all_models{aid} = fitnlm(cft.X, cft.y, cft.t4.fctn, a0);
            catch e
                cur = struct();
                cur.error = e;
                cur.Coefficients.Estimate = nan(length(a0), 1);
                cur.Coefficients.SE = nan(length(a0), 1);
                cur.CoefficientNames = {"a1", "a2", "a3", "a4"};
                cur.ModelCriterion.AIC = NaN;
                cur.ModelCriterion.BIC = NaN;
                cur.MSE = NaN;
                cur.Rsquared.Ordinary = NaN;
                cur.Rsquared.Adjusted = NaN;
                cft.t4.all_models{aid} = cur;
            end

            % For each attempt, check if wanring was triggered
            [warnmsg, warnid] = lastwarn();

            if ~isempty(warnid)
                cft.t4.iswarning(aid) = true;
                cft.t4.warnings(aid) = {[warnmsg, warnid]};
            end
        end

        % Process models to select one good/representative
        cft.t4.all_coefs = cell2mat(cellfun(@(c) c.Coefficients.Estimate', cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_coefs_se = cell2mat(cellfun(@(c) c.Coefficients.SE', cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_AIC = cell2mat(cellfun(@(c) c.ModelCriterion.AIC, cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_BIC = cell2mat(cellfun(@(c) c.ModelCriterion.BIC, cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_MSE = cell2mat(cellfun(@(c) c.MSE, cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_RS = cell2mat(cellfun(@(c) c.Rsquared.Ordinary, cft.t4.all_models, 'UniformOutput', false));
        cft.t4.all_RS_adj = cell2mat(cellfun(@(c) c.Rsquared.Adjusted, cft.t4.all_models, 'UniformOutput', false));

        % Mask unreliable fits
        bad = any(isoutlier(cft.t4.all_coefs), 2);
        bad = any(cat(2, bad, isnan(cft.t4.all_MSE)), 2);
        cft.t4.goodness_mask = ~bad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fig.4a - tables on good fits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ngood table
        table_ngood{eid}(mid, 1) = sum(cft.t0.goodness_mask);
        table_ngood{eid}(mid, 2) = sum(cft.t1.goodness_mask);
        table_ngood{eid}(mid, 3) = sum(cft.t2.goodness_mask);
        table_ngood{eid}(mid, 4) = sum(cft.t3.goodness_mask);
        table_ngood{eid}(mid, 5) = sum(cft.t4.goodness_mask);

        % MSE avg table
        table_MSEavg_good{eid}(mid, 1) = mean(cft.t0.all_MSE(cft.t0.goodness_mask));
        table_MSEavg_good{eid}(mid, 2) = mean(cft.t1.all_MSE(cft.t1.goodness_mask));
        table_MSEavg_good{eid}(mid, 3) = mean(cft.t2.all_MSE(cft.t2.goodness_mask));
        table_MSEavg_good{eid}(mid, 4) = mean(cft.t3.all_MSE(cft.t3.goodness_mask));
        table_MSEavg_good{eid}(mid, 5) = mean(cft.t4.all_MSE(cft.t4.goodness_mask));

        % MSE std table
        table_MSEstd_good{eid}(mid, 1) = std(cft.t0.all_MSE(cft.t0.goodness_mask));
        table_MSEstd_good{eid}(mid, 2) = std(cft.t1.all_MSE(cft.t1.goodness_mask));
        table_MSEstd_good{eid}(mid, 3) = std(cft.t2.all_MSE(cft.t2.goodness_mask));
        table_MSEstd_good{eid}(mid, 4) = std(cft.t3.all_MSE(cft.t3.goodness_mask));
        table_MSEstd_good{eid}(mid, 5) = std(cft.t4.all_MSE(cft.t4.goodness_mask));

        % AIC avg table
        table_AICavg_good{eid}(mid, 1) = mean(cft.t0.all_AIC(cft.t0.goodness_mask));
        table_AICavg_good{eid}(mid, 2) = mean(cft.t1.all_AIC(cft.t1.goodness_mask));
        table_AICavg_good{eid}(mid, 3) = mean(cft.t2.all_AIC(cft.t2.goodness_mask));
        table_AICavg_good{eid}(mid, 4) = mean(cft.t3.all_AIC(cft.t3.goodness_mask));
        table_AICavg_good{eid}(mid, 5) = mean(cft.t4.all_AIC(cft.t4.goodness_mask));

        % AIC std table
        table_AICstd_good{eid}(mid, 1) = std(cft.t0.all_AIC(cft.t0.goodness_mask));
        table_AICstd_good{eid}(mid, 2) = std(cft.t1.all_AIC(cft.t1.goodness_mask));
        table_AICstd_good{eid}(mid, 3) = std(cft.t2.all_AIC(cft.t2.goodness_mask));
        table_AICstd_good{eid}(mid, 4) = std(cft.t3.all_AIC(cft.t3.goodness_mask));
        table_AICstd_good{eid}(mid, 5) = std(cft.t4.all_AIC(cft.t4.goodness_mask));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fig.4c - table t1 avg params
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Coefs avg
        table_coef_t0_good{eid}(mid, :) = mean(cft.t0.all_coefs(cft.t0.goodness_mask, :), 1);
        table_coef_t1_good{eid}(mid, :) = mean(cft.t1.all_coefs(cft.t1.goodness_mask, :), 1);
        table_coef_t2_good{eid}(mid, :) = mean(cft.t2.all_coefs(cft.t2.goodness_mask, :), 1);
        table_coef_t3_good{eid}(mid, :) = mean(cft.t3.all_coefs(cft.t3.goodness_mask, :), 1);
        table_coef_t4_good{eid}(mid, :) = mean(cft.t4.all_coefs(cft.t4.goodness_mask, :), 1);

        % Save cft
        fitted{eid, mid} = cft;
    end

    % Convert containers into table data structures
    table_ngood{eid} = array2table(table_ngood{eid}, "RowNames", [methods{:}], "VariableNames", ["t0","t1","t2","t3","t4"]);
    table_MSEavg_good{eid} = array2table(table_MSEavg_good{eid}, "RowNames", [methods{:}], "VariableNames", ["t0","t1","t2","t3","t4"]);
    table_MSEstd_good{eid} = array2table(table_MSEstd_good{eid}, "RowNames", [methods{:}], "VariableNames", ["t0","t1","t2","t3","t4"]);
    table_AICavg_good{eid} = array2table(table_AICavg_good{eid}, "RowNames", [methods{:}], "VariableNames", ["t0","t1","t2","t3","t4"]);
    table_AICstd_good{eid} = array2table(table_AICstd_good{eid}, "RowNames", [methods{:}], "VariableNames", ["t0","t1","t2","t3","t4"]);
    table_coef_t0_good{eid} = array2table(table_coef_t0_good{eid}, "RowNames", [methods{:}], "VariableNames", ["a1","a2","a3","a5"]);
    table_coef_t1_good{eid} = array2table(table_coef_t1_good{eid}, "RowNames", [methods{:}], "VariableNames", ["a1","a2","a3","a4","a5"]);
    table_coef_t2_good{eid} = array2table(table_coef_t2_good{eid}, "RowNames", [methods{:}], "VariableNames", ["a1","a2","a3","a4","a5","a6","a7"]);
    table_coef_t3_good{eid} = array2table(table_coef_t3_good{eid}, "RowNames", [methods{:}], "VariableNames", ["a1","a2","a3","a4","a5","a6","a7","a8","a9","a10","a11"]);
    table_coef_t4_good{eid} = array2table(table_coef_t4_good{eid}, "RowNames", [methods{:}], "VariableNames", ["a1","a2","a3","a4"]);
end

 % Save fits
if SAVE
    save(sprintf("%s/fitted.mat", save_path_a), 'fitted', '-v7.3');
    for eid = 1 : length(draft{1}.exn)
        exn_str = strrep(sprintf('%#1.1f', draft{1}.exn(eid)), '.', '');
        writetable(table_ngood{eid}, sprintf("%s/table_ngood_%s.csv", save_path_a, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_MSEavg_good{eid}, sprintf("%s/table_MSEavg_good_%s.csv", save_path_a, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_MSEstd_good{eid}, sprintf("%s/table_MSEstd_good_%s.csv", save_path_a, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_AICavg_good{eid}, sprintf("%s/table_AICavg_good_%s.csv", save_path_a, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_AICstd_good{eid}, sprintf("%s/table_AICstd_good_%s.csv", save_path_a, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_coef_t0_good{eid}, sprintf("%s/table_coef_t0_good_%s.csv", save_path_c, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_coef_t1_good{eid}, sprintf("%s/table_coef_t1_good_%s.csv", save_path_c, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_coef_t2_good{eid}, sprintf("%s/table_coef_t2_good_%s.csv", save_path_c, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_coef_t3_good{eid}, sprintf("%s/table_coef_t3_good_%s.csv", save_path_c, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
        writetable(table_coef_t4_good{eid}, sprintf("%s/table_coef_t4_good_%s.csv", save_path_c, exn_str), 'Delimiter', ',', 'WriteRowNames', true);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig.4b - good fits swarm chart
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for eid = 1 : length(draft{1}.exn)
    f1 = figure();

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    for aid = 1 : 5
        ax = subplot(1, 5, aid);

        x = [];
        y = [];
        c = [];
        tab_swarm = table(x, y, c);
        for mid = 1 : length(methods)
            % if (strcmp(methods{mid}, 'pdc-lwr') || strcmp(methods{mid}, 'pdc-ols'))
            %     if aid < 4
            %         y = fitted{eid, mid}.t0.all_coefs(fitted{eid, mid}.t0.goodness_mask, aid);
            %     elseif aid == 4
            %         y = zeros(50,1);
            %     elseif aid == 5
            %         y = fitted{eid, mid}.t0.all_coefs(fitted{eid, mid}.t0.goodness_mask, 4);
            %     end
            % else
            %     y = fitted{eid, mid}.t1.all_coefs(fitted{eid, mid}.t1.goodness_mask, aid);
            % end
            y = fitted{eid, mid}.t1.all_coefs(fitted{eid, mid}.t1.goodness_mask, aid);

            x = mid .* ones(size(y));
            c = repmat(get_colors(colors{mid}, 600), length(y), 1);

            tab_swarm = [tab_swarm; table(x, y, c)];
        end

        % Make x categorical in table
        tab_swarm.x = categorical(tab_swarm.x, 1:length(methods), string(methods));

        swarmchart(tab_swarm, 'x', 'y', 'filled', 'ColorVariable','c', 'MarkerFaceAlpha', 0.1, 'MarkerEdgeAlpha', 0.1, 'SizeData', 75);
        xlabel(fitted{eid, 1}.t1.all_models{1}.CoefficientNames{aid});
        ylabel("");
        
        if aid == 1
            ylim([-100,100]);
        elseif aid == 2
            ylim([-5e-6, 6e-5]);
        elseif aid > 2
            ylim([-0.8, 7]);
        end
    end

    if SAVE
        filename = strrep(sprintf('t1_coef_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f1, sprintf("%s/%s.fig", save_path_b, filename));
        print(f1, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path_b, filename));
        close(f1);
    end
end

%% Fig.4d %%
% Save params
SAVE = true;
save_path = sprintf('data/results/F04d');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Baseline parameter combination
a0 = [100, 5e-2, 2];

% Parameter combinations init
a1 = repmat(a0, 10, 1);
a2 = repmat(a0, 10, 1);
a3 = repmat(a0, 10, 1);

% Combination values
a1(:, 1) = -200:100:700;
a2(:, 2) = [0.01:0.02:0.2];
a3(:, 3) = [1, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5];

% Function formalisation
fct = @(a, x) a(:,1) + a(:,2) .* (x.^a(:,3));
x = -5:.1:105;
t1 = fct(a1, x);
t2 = fct(a2, x);
t3 = fct(a3, x);

% Figure parameters
f = figure();
fig_width = 1000;
fig_height = 600;
colors = {"blueGrey", "yellow", "red", "blue", "green"};

set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

%%% Plot a1 %%%
subplot(2, 6, [1:3]);
hold("on");

color_shades = get_colors(colors{1}, []);

for rid = 1 : size(t1, 1)
    if isequal(a1(rid,:), a0)
        a0_shade = color_shades{rid};
        plot(x, t1(rid,:), "Color", color_shades{rid}, "LineWidth", 5);
    else
        plot(x, t1(rid,:), "Color", color_shades{rid}, "LineWidth", 2);
    end
end

xlim([-1,100]);
ylim([-1,1000]);
xlabel("c (s,o)");
ylabel("time (s)");
title("a0");
annotation('textarrow', [.32, .32], [.6, .92], "Color", a0_shade, "LineWidth", 4, "LineStyle", ":", "HeadWidth", 20, "HeadLength", 20);

%%% Plot a2 %%%
subplot(2, 6, [4:1:6]);
hold("on");

color_shades = get_colors(colors{2}, []);

for rid = 1 : size(t2, 1)
    if isequal(a2(rid,:), a0)
        a0_shade = color_shades{rid};
        plot(x, t2(rid,:), "Color", color_shades{rid}, "LineWidth", 5);
    else
        plot(x, t2(rid,:), "Color", color_shades{rid}, "LineWidth", 2);
    end
end

xlim([-1,100]);
ylim([-1,1000]);
xlabel("c (s,o)");
% ylabel("time (s)");
title("a2");
annotation('textarrow', [.88, .65], [.65, .80], "Color", a0_shade, "LineWidth", 4, "LineStyle", ":", "HeadWidth", 20, "HeadLength", 20);

%%% Plot ac %%%
subplot(2, 6, [7,8]);
hold("on");

color_shades = get_colors(colors{3}, []);

for rid = 1 : size(t3, 1)
    if isequal(a3(rid,:), a0)
        a0_shade = color_shades{rid};
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 5);
    else
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 2);
    end
end

xlim([-1,100]);
ylim([-1,1000]);
xlabel("c");
ylabel("time (s)");
title("a3");
annotation('textarrow', [.28, .14], [.13, .42], "Color", a0_shade, "LineWidth", 4, "LineStyle", ":", "HeadWidth", 20, "HeadLength", 20);

%%% Plot as %%%
subplot(2, 6, [9,10]);
hold("on");

color_shades = get_colors(colors{4}, []);

for rid = 1 : size(t3, 1)
    if isequal(a3(rid,:), a0)
        a0_shade = color_shades{rid};
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 5);
    else
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 2);
    end
end

xlim([-1,100]);
ylim([-1,1000]);
xlabel("s");
% ylabel("time (s)");
title("a4");
annotation('textarrow', [.55, .41], [.13, .42], "Color", a0_shade, "LineWidth", 4, "LineStyle", ":", "HeadWidth", 20, "HeadLength", 20);

%%% Plot ao %%%
subplot(2, 6, [11,12]);
hold("on");

color_shades = get_colors(colors{5}, []);

for rid = 1 : size(t3, 1)
    if isequal(a3(rid,:), a0)
        a0_shade = color_shades{rid};
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 5);
    else
        plot(x, t3(rid,:), "Color", color_shades{rid}, "LineWidth", 2);
    end
end

xlim([-1,100]);
ylim([-1,1000]);
xlabel("o");
% ylabel("time (s)");
title("a5");
annotation('textarrow', [.82, .68], [.13, .42], "Color", a0_shade, "LineWidth", 4, "LineStyle", ":", "HeadWidth", 20, "HeadLength", 20);

% Save figure as fig and pdf
if SAVE
    saveas(f, sprintf("%s/funparams.fig", save_path));
    print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/funparams.png", save_path));
    close(f);
end

%% Fig.5 %%
% Parameters
timestr = "202408281750";
methods = {'mvgc-lwr', 'mvgc-ols', 'mvgc-lasso', 'mvgc-sbl', 'mvgc-lapsbl', 'pdc-lwr', 'pdc-ols'};
colors = {"red", "purple", "blue", "yellow", "orange", "green", "blueGrey"};
fig_width = 1000;
fig_height = 300;
green = get_colors("green", 700);
red = get_colors("red", 800);
pink = get_colors("pink", 500);
grey = get_colors("grey", 400);

% Save parameters
SAVE = true;
save_path = sprintf('data/results/F05');
if (SAVE && ~exist(save_path, 'dir')), mkdir(save_path); end

% Create containers for results of all methods
draft = cell(1, length(methods));

for mid = 1 : length(methods)
    method = methods{mid};

    % Load results
    load(sprintf('data/%s/%s/caus_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/exn.mat', method, timestr));
    load(sprintf('data/%s/%s/fn.mat', method, timestr));
    load(sprintf('data/%s/%s/fp.mat', method, timestr));
    load(sprintf('data/%s/%s/tn.mat', method, timestr));
    load(sprintf('data/%s/%s/tp.mat', method, timestr));
    load(sprintf('data/%s/%s/mvar_est_method.mat', method, timestr));
    load(sprintf('data/%s/%s/nc.mat', method, timestr));
    load(sprintf('data/%s/%s/ns.mat', method, timestr));
    load(sprintf('data/%s/%s/no.mat', method, timestr));
    load(sprintf('data/%s/%s/nt.mat', method, timestr));
    load(sprintf('data/%s/%s/results.mat', method, timestr));
    load(sprintf('data/%s/%s/weights.mat', method, timestr));

    draft{mid} = struct();
    draft{mid}.fn = fn;
    draft{mid}.fp = fp;
    draft{mid}.tp = tp;
    draft{mid}.tn = tn;
    draft{mid}.weights = weights;
    draft{mid}.ns = ns;
    draft{mid}.nc = nc;
    draft{mid}.no = no;
    draft{mid}.nt = nt;
    draft{mid}.exn = exn;

    % Extract weights of fp, fn, tp, tn across trials
    for eid = 1 : length(exn)
         % Init containers
        draft{mid}.tp_wghts{eid} = [];
        draft{mid}.tn_wghts{eid} = [];
        draft{mid}.fp_wghts{eid} = [];
        draft{mid}.fn_wghts{eid} = [];

        for tid = 1 : nt
            tp_tmp = tp{eid,:,:,:,tid};
            tn_tmp = tn{eid,:,:,:,tid};
            fp_tmp = fp{eid,:,:,:,tid};
            fn_tmp = fn{eid,:,:,:,tid};
            w_tmp = weights{eid,:,:,:,tid};

            draft{mid}.tp_wghts{eid} = cat(1, draft{mid}.tp_wghts{eid}, reshape(w_tmp(tp_tmp), [], 1));
            draft{mid}.tn_wghts{eid} = cat(1, draft{mid}.tn_wghts{eid}, reshape(w_tmp(tn_tmp), [], 1));
            draft{mid}.fp_wghts{eid} = cat(1, draft{mid}.fp_wghts{eid}, reshape(w_tmp(fp_tmp), [], 1));
            draft{mid}.fn_wghts{eid} = cat(1, draft{mid}.fn_wghts{eid}, reshape(w_tmp(fn_tmp), [], 1));
        end

        % Format as a table for boxchart
        Weights = cat(1, draft{mid}.tp_wghts{eid}, draft{mid}.fn_wghts{eid});
        Type = cat(1, zeros(length(draft{mid}.tp_wghts{eid}), 1), ones(length(draft{mid}.fn_wghts{eid}), 1));
        draft{mid}.table_wgths{eid} = table(Weights, Type);
    end
end

% Display weights values wrt fn,fp,tn,tp of all methods
for eid = 1 : length(exn)
    f = figure();
    colororder(cat(1, green, red));

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    type_var = [];
    weights = [];
    method = [];
    for mid = 1 : length(methods)
        type_var = cat(1, type_var, draft{mid}.table_wgths{eid}.Type);
        weights = cat(1, weights, draft{mid}.table_wgths{eid}.Weights);
        method = cat(1, method, mid * ones(length(draft{mid}.table_wgths{eid}.Weights), 1));
    end

    type_var = categorical(logical(type_var), logical([0 1]), {'tp' 'fn'});
    method = categorical(method, 1:length(methods), methods);

    b = boxchart(method, abs(weights), "GroupByColor", type_var);
    title(sprintf("Exn = %.2f", exn(eid)));
    ylabel("absolute causal weights");
    ylim([0,1]);
    legend();

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('weights_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

% Same but corrected weights based on external noise
% Display weights values wrt fn,fp,tn,tp of all methods
for eid = 1 : length(exn)
    f = figure();
    colororder(cat(1, green, red));

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    title(sprintf("Exn = %.2f", exn(eid)));

    type_var = [];
    weights = [];
    method = [];
    for mid = 1 : length(methods)
        type_var = cat(1, type_var, draft{mid}.table_wgths{eid}.Type);
        weights = cat(1, weights, draft{mid}.table_wgths{eid}.Weights);
        method = cat(1, method, mid * ones(length(draft{mid}.table_wgths{eid}.Weights), 1));
    end

    type_var = categorical(logical(type_var), logical([0 1]), {'tp' 'fn'});
    method = categorical(method, 1:length(methods), methods);

    boxchart(method, abs(weights) * (1 - exn(eid)), "GroupByColor", type_var);
    title(sprintf("Exn = %.2f (corrected)", exn(eid)));
    ylabel("corrected absolute causal weights");
    ylim([0,1]);
    yline(1 - exn(eid),  "LineWidth", 3, "LineStyle", "--", "Color", grey, "DisplayName", "signal proportion");
    legend();

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('weights_corrected_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

% Swarm chart to visualise intercept
for eid = 1 : length(exn)
    f = figure();
    hold("on");

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    tiledlayout(1, length(methods));

    for mid = 1 : length(methods)
        ax = nexttile;
        colormap(get_colormap(green, red));

        type_var = draft{mid}.table_wgths{eid}.Type;
        Type_names = categorical(logical(type_var), logical([0 1]), {'tp' 'fn'});
        Colors = type_var;
        Weights = abs(draft{mid}.table_wgths{eid}.Weights);

        tmp_table = table(Weights, Type_names, Colors);

        swarmchart(ax, tmp_table, 'Type_names', 'Weights', 'filled', 'ColorVariable', 'Colors', 'SizeData', 5, 'MarkerEdgeAlpha', 0.0, 'MarkerFaceAlpha', 0.5);
        ylabel(methods{mid});
        xlabel("");
        ylim([0,1]);

        % Find detectability threshold
        thresh = threshold_distributions(Weights(~logical(type_var)), Weights(logical(type_var)));
        yline(thresh, "LineWidth", 2, "LineStyle", ":", "Color", pink);
    end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('swarm_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end

% Swarm chart to visualise intercept - corrected
snr_caption_string = {"noiseless", "SNR=3", "SNR=1", "SNR=1/3"};
for eid = 1 : length(exn)
    f = figure();
    hold("on");

    % Printing params
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf, 'Position',  [100, 100, 100 + fig_width, 100 + fig_height]);   % Resize fig window

    tiledlayout(1, length(methods));

    for mid = 1 : length(methods)
        ax = nexttile;
        colormap(get_colormap(green, red));

        type_var = draft{mid}.table_wgths{eid}.Type;
        Type_names = categorical(logical(type_var), logical([0 1]), {'tp' 'fn'});
        Colors = type_var;
        Weights = abs(draft{mid}.table_wgths{eid}.Weights) * (1 - draft{mid}.exn(eid));

        tmp_table = table(Weights, Type_names, Colors);
    
        swarmchart(ax, tmp_table, 'Type_names', 'Weights', 'filled', 'ColorVariable', 'Colors', 'SizeData', 5, 'MarkerEdgeAlpha', 0.0, 'MarkerFaceAlpha', 0.5);
        ylim([0,1]);

        if eid == length(exn)
            xlabel(sprintf("\\fontsize{12}%s", methods{mid}), "Color", get_colors(colors{mid}, 600));
        else
            xlabel("");
        end

        if mid == 1
            ylabel({sprintf("\\fontsize{14}%s", snr_caption_string{eid}),'\fontsize{10} effective coupling strength'});
        else
            ylabel("");
        end

        % Find detectability threshold
        thresh = threshold_distributions(Weights(~logical(type_var)), Weights(logical(type_var)));
        yline(thresh, "LineWidth", 2, "LineStyle", ":", "Color", pink);
        yline(1 - exn(eid),  "LineWidth", 3, "LineStyle", "--", "Color", grey, "DisplayName", "signal proportion");
    end

    % Save figure as fig and pdf
    if SAVE
        filename = strrep(sprintf('swarm_corrected_%#1.1f', draft{mid}.exn(eid)), '.', '');
        saveas(f, sprintf("%s/%s.fig", save_path, filename));
        print(gcf, '-dpng','-loose','-image','-r600', sprintf("%s/%s.png", save_path, filename));
        close(f);
    end
end