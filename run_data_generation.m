%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_data_generation
%
% This script runs causality simulation and estimations, then saves the 
% resulting data in /data/[method]/.
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
%% Fig.2a (202409051456) - ns x nc
%%%% With multiple trials %%%%
nt = 5;

% % Get current timestamp
NOW = string(datetime('now'), 'yyyyMMddHHmm');

% mvgc-lwr ; mvgc-ols
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100:100:1000, 1500:500:10000];
exp1.nc = [10:10:50, 100:100:500];
exp1.exn = [0.0, 0.50];
exp1.no = [10];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-lasso
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lasso"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100:100:1000, 1500:500:10000];
exp1.nc = [10,30,50,60,70,80,90];
exp1.exn = [0.0, 0.50];
exp1.no = [10];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-lapsbl
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lapsbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100:100:3000];
exp1.nc = [5:5:30];
exp1.exn = [0.0, 0.50];
exp1.no = [10];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-sbl
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"sbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100:100:3000];
exp1.nc = [5:5:30];
exp1.exn = [0.0, 0.50];
exp1.no = [10];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc"];
exp1.timestamp = NOW;

experiments(exp1);

% pdc-lwr ; pdc-ols
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"pdc"};
exp1.ns = [100, 200, 500, 1000, 2500, 5000, 10000];
exp1.nc = [5:5:35, 38];
exp1.exn = [0.0, 0.50];
exp1.no = [10];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc"];
exp1.timestamp = NOW;

experiments(exp1);

%% Fig.2b (202412222218) - feasibility area
% Get current timestamp
NOW = string(datetime('now'), 'yyyyMMddHHmm');

% Parameters
exp6 = struct();
exp6.run = true;
exp6.ns = [50:50:1000, 1100:100:10000, 11000:1000:20000];
exp6.nc = [5:5:50, 60:10:200, 220:20:500];
exp6.no = 10;
exp6.exn = 0.0;
exp6.timestamp = NOW;

% mvgc
exp6.mvar_est_methods = {"lwr", "ols", "lasso", "sbl", "lapsbl"};
exp6.caus_est_methods = {"mvgc"};
experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp6);

% pdc
exp6.mvar_est_methods = {"lwr", "ols"};
exp6.caus_est_methods = {"pdc"};
exp6.ns_indep = true;
experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp6);

%% Fig.2c (202412121736) - feasibility threshold
% Get current timestamp
NOW = string(datetime('now'), 'yyyyMMddHHmm');

% mvgc
exp5 = struct();
exp5.run = true;
exp5.mvar_est_methods = {"ols", "lasso", "sbl", "lapsbl"};
exp5.caus_est_methods = {"mvgc"};
exp5.ns = [50:50:1000, 1100:100:10000, 11000:1000:50000];
exp5.nc = [5:5:50,60:10:200, 300:50:1000];
exp5.timestamp = NOW;

experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp5);

% pdc
exp5 = struct();
exp5.run = true;
exp5.mvar_est_methods = {"lwr", "ols"};
exp5.caus_est_methods = {"pdc"};
exp5.ns = [10:10:1000, 1100:100:10000, 11000:1000:50000];
exp5.nc = [5:5:50,60:10:200, 300:50:1000];
exp5.timestamp = NOW;

experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp5);

%% Fig.3abc (202411-241722,-260638,-282215) - ns, nc, no
%%% 1D search space: (3 x ns), (3 x nc), (3 x no)
%%%% With single trial %%%%
nt = 1;

%%%%%%%%
%  ns  %
%%%%%%%%
% Get current timestamp
NOW_ns = string(datetime('now'), 'yyyyMMddHHmm');
exp3 = struct();
exp3.run = true;
exp3.exn = [0.0, 0.50];
exp3.no = [10];
exp3.nt = nt;
exp3.cutoff_time_trial = 1200;
exp3.timestamp = NOW_ns;
exp3.skip_cut_of = ["nc", "no"];

% mvgc-lwr ; mvgc-ols
exp3.mvar_est_methods = {"lwr", "ols"};
exp3.caus_est_methods = {"mvgc"};
exp3.ns = [100:100:1000, 1500:500:20000];
exp3.nc = [10, 30, 200];
experiments(struct("run", false), struct("run", false), exp3, struct("run", false));

% mvgc-lasso
exp3.mvar_est_methods = {"lasso"};
exp3.caus_est_methods = {"mvgc"};
exp3.ns = [100:100:1000, 1500:500:20000];
exp3.nc = [10, 30];
experiments(struct("run", false), struct("run", false), exp3, struct("run", false));

% mvgc-sbl
exp3.mvar_est_methods = {"sbl"};
exp3.caus_est_methods = {"mvgc"};
exp3.ns = [100:100:10000];
exp3.nc = [10, 30];
experiments(struct("run", false), struct("run", false), exp3, struct("run", false));

% mvgc-lapsbl
exp3.mvar_est_methods = {"lapsbl"};
exp3.caus_est_methods = {"mvgc"};
exp3.ns = [100:100:10000];
exp3.nc = [10, 30];
experiments(struct("run", false), struct("run", false), exp3, struct("run", false));

% pdc-lwr ; pdc-ols
exp3.mvar_est_methods = {"lwr", "ols"};
exp3.caus_est_methods = {"pdc"};
exp3.ns = [500:500:10000];
exp3.nc = [10, 30];
experiments(struct("run", false), struct("run", false), exp3, struct("run", false));

%%%%%%%%
%  nc  %
%%%%%%%%
% Get current timestamp
NOW_nc = string(datetime('now'), 'yyyyMMddHHmm');
exp4 = struct();
exp4.run = true;
exp4.exn = [0.0, 0.50];
exp4.no = [10];
exp4.nt = nt;
exp4.cutoff_time_trial = 1200;
exp4.timestamp = NOW_nc;
exp4.skip_cut_of = ["ns", "no"];

% mvgc-lwr ; mvgc-ols
exp4.mvar_est_methods = {"lwr", "ols"};
exp4.caus_est_methods = {"mvgc"};
exp4.ns = [1000, 2000, 10000];
exp4.nc = [10:10:400];
experiments(struct("run", false), struct("run", false), struct("run", false), exp4);

% mvgc-lasso
exp4.mvar_est_methods = {"lasso"};
exp4.caus_est_methods = {"mvgc"};
exp4.ns = [1000, 2000, 10000];
exp4.nc = [5:5:400];
experiments(struct("run", false), struct("run", false), struct("run", false), exp4);

% mvgc-sbl
exp4.mvar_est_methods = {"sbl"};
exp4.caus_est_methods = {"mvgc"};
exp4.ns = [1000, 2000];
exp4.nc = [2:1:15, 16:2:40, 45:5:400];
experiments(struct("run", false), struct("run", false), struct("run", false), exp4);

% mvgc-lapsbl
exp4.mvar_est_methods = {"lapsbl"};
exp4.caus_est_methods = {"mvgc"};
exp4.ns = [1000, 2000];
exp4.nc = [2:1:30, 35:5:400];
experiments(struct("run", false), struct("run", false), struct("run", false), exp4);

% pdc-lwr ; pdc-ols
exp4.mvar_est_methods = {"lwr", "ols"};
exp4.caus_est_methods = {"pdc"};
exp4.ns = [1000, 2000, 10000];
exp4.nc = [2:2:40, 45:5:400];
experiments(struct("run", false), struct("run", false), struct("run", false), exp4);

%%%%%%%%
%  no  %
%%%%%%%%
% Get current timestamp
NOW_no = string(datetime('now'), 'yyyyMMddHHmm');
exp1 = struct();
exp1.run = true;
exp1.exn = [0.0, 0.50];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.timestamp = NOW_no;
exp1.skip_cut_of = ["nc", "ns"];

% mvgc-lwr ; mvgc-ols
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [1000, 10000];
exp1.nc = [10, 30, 200];
exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
experiments(exp1);

% mvgc-lasso
exp1.mvar_est_methods = {"lasso"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [1000, 10000];
exp1.nc = [10, 30];
exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
experiments(exp1);

% mvgc-sbl
exp1.mvar_est_methods = {"sbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [1000];
exp1.nc = [10, 30];
exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
experiments(exp1);

% mvgc-lapsbl
exp1.mvar_est_methods = {"lapsbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [1000];
exp1.nc = [10, 30];
exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
experiments(exp1);

% pdc-lwr ; pdc-ols
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"pdc"};
exp1.ns = [1000, 10000];
exp1.nc = [10, 30];
exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
experiments(exp1);

%% Fig.4 (202411191733) - ns x nc x no
%%%% With multiple trials %%%%
nt = 1;

Get current timestamp
NOW = string(datetime('now'), 'yyyyMMddHHmm');

% mvgc-lwr ; mvgc-ols
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100, 500, 1000, 5000];
exp1.nc = [10, 20, 50, 200];
exp1.exn = [0.0, 0.50];
exp1.no = [5, 10, 20, 50];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc", "ns", "no"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-lasso
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lasso"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [100, 200, 500, 2000];
exp1.nc = [10, 20, 30, 50];
exp1.exn = [0.0, 0.50];
exp1.no = [5, 10, 20, 50];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc", "ns", "no"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-sbl
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"sbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [500, 750, 1000, 2000];
exp1.nc = [10, 20, 25, 30];
exp1.exn = [0.0, 0.50];
exp1.no = [5, 10, 20, 50];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc", "ns", "no"];
exp1.timestamp = NOW;

experiments(exp1);

% mvgc-lapsbl
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lapsbl"};
exp1.caus_est_methods = {"mvgc"};
exp1.ns = [500, 750, 1000, 1250];
exp1.nc = [5, 10, 15, 20];
exp1.exn = [0.0, 0.50];
exp1.no = [5, 10, 20, 30];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc", "ns", "no"];
exp1.timestamp = NOW;

experiments(exp1);

% pdc-lwr ; pdc-ols
exp1 = struct();
exp1.run = true;
exp1.mvar_est_methods = {"lwr", "ols"};
exp1.caus_est_methods = {"pdc"};
exp1.ns = [100, 500, 1000, 2000, 5000];
exp1.nc = [5, 15, 25, 35, 40];
exp1.exn = [0.0, 0.50];
exp1.no = [5, 10, 20, 50];
exp1.nt = nt;
exp1.cutoff_time_trial = 1200;
exp1.skip_cut_of = ["nc", "ns", "no"];
exp1.timestamp = NOW;

experiments(exp1);

%% Fig.5 (202408281750) - coupling strength detectability threshold
% Trials
nt = 100;

% Get current timestamp
NOW = string(datetime('now'), 'yyyyMMddHHmm');

% mvgc-lwr ; mvgc-ols ; pdc-lwr ; pdc-ols
exp2 = struct();
exp2.run = true;
exp2.mvar_est_methods = {"lwr", "ols"};
exp2.caus_est_methods = {"mvgc", "pdc"};
exp2.ns = [5000];
exp2.nc = [20];
exp2.exn = [0.0, 0.25, 0.50, 0.75];
exp2.no = [10];
exp2.nt = nt;
exp2.timestamp = NOW;

experiments(struct("run", false), exp2);

% mvgc-lasso
exp2.mvar_est_methods = {"lasso"};
exp2.caus_est_methods = {"mvgc"};

experiments(struct("run", false), exp2);

% mvgc-sbl ; mvgc-lapsbl
exp2 = struct();
exp2.run = true;
exp2.mvar_est_methods = {"sbl", "lapsbl"};
exp2.caus_est_methods = {"mvgc"};
exp2.ns = [500];
exp2.nc = [15];
exp2.exn = [0.0, 0.25, 0.50, 0.75];
exp2.no = [10];
exp2.nt = nt;
exp2.timestamp = NOW;

experiments(struct("run", false), exp2);


%% LASSO %%
% % Fig.2a (202409051456) - ns x nc
% exp1 = struct();
% exp1.run = true;
% exp1.mvar_est_methods = {"lasso"};
% exp1.caus_est_methods = {"mvgc"};
% exp1.ns = [100:100:1000, 1500:500:10000];
% exp1.nc = [5:5:50];
% exp1.exn = [0.0, 0.50];
% exp1.no = [10];
% exp1.nt = 5;
% exp1.cutoff_time_trial = 1200;
% exp1.skip_cut_of = ["nc"];
% exp1.timestamp = "202409051456";
% 
% experiments(exp1);
% 
% % Fig.2b (202412222218) - feasibility area
% exp6 = struct();
% exp6.run = true;
% exp6.ns = [50:50:1000, 1100:100:10000, 11000:1000:20000];
% exp6.nc = [5:5:50, 60:10:200, 220:20:500];
% exp6.no = 10;
% exp6.exn = 0.0;
% exp6.timestamp = "202412222218";
% exp6.mvar_est_methods = {"lasso"};
% exp6.caus_est_methods = {"mvgc"};
% 
% experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp6);
% 
% % Fig.2c (202412121736) - feasibility threshold
% exp5 = struct();
% exp5.run = true;
% exp5.mvar_est_methods = {"lasso"};
% exp5.caus_est_methods = {"mvgc"};
% exp5.ns = [50:50:1000, 1100:100:10000, 11000:1000:50000];
% exp5.nc = [5:5:50,60:10:200, 300:50:1000];
% exp5.timestamp = "202412121736";
% 
% experiments(struct("run", false), struct("run", false), struct("run", false), struct("run", false), exp5);
% 
% % Fig.3abc (202411-241722,-260638,-282215) - ns, nc, no
% % Get current timestamp
% NOW_ns = string(datetime('now'), 'yyyyMMddHHmm');
% exp3 = struct();
% exp3.run = true;
% exp3.exn = [0.0, 0.50];
% exp3.no = [10];
% exp3.nt = 1;
% exp3.cutoff_time_trial = 1200;
% exp3.timestamp = "202411241722";
% exp3.skip_cut_of = ["nc", "no"];
% exp3.mvar_est_methods = {"lasso"};
% exp3.caus_est_methods = {"mvgc"};
% exp3.ns = [100:100:1000, 1500:500:20000];
% exp3.nc = [10, 30];
% 
% experiments(struct("run", false), struct("run", false), exp3, struct("run", false));
% 
% exp4 = struct();
% exp4.run = true;
% exp4.exn = [0.0, 0.50];
% exp4.no = [10];
% exp4.nt = 1;
% exp4.cutoff_time_trial = 1200;
% exp4.timestamp = "202411260638";
% exp4.skip_cut_of = ["ns", "no"];
% exp4.mvar_est_methods = {"lasso"};
% exp4.caus_est_methods = {"mvgc"};
% exp4.ns = [1000, 2000, 10000];
% exp4.nc = [5:5:400];
% 
% experiments(struct("run", false), struct("run", false), struct("run", false), exp4);
% 
% exp1 = struct();
% exp1.run = true;
% exp1.exn = [0.0, 0.50];
% exp1.nt = 1;
% exp1.cutoff_time_trial = 1200;
% exp1.timestamp = "202411282215";
% exp1.skip_cut_of = ["nc", "ns"];
% exp1.mvar_est_methods = {"lasso"};
% exp1.caus_est_methods = {"mvgc"};
% exp1.ns = [1000, 10000];
% exp1.nc = [10, 30];
% exp1.no = [5:1:15, 16:2:30, 35:5:100, 110:10:200];
% 
% experiments(exp1);
% 
% % Fig.4 (202411191733) - ns x nc x no
% exp1 = struct();
% exp1.run = true;
% exp1.mvar_est_methods = {"lasso"};
% exp1.caus_est_methods = {"mvgc"};
% exp1.ns = [100, 200, 500, 2000];
% exp1.nc = [10, 20, 30, 50];
% exp1.exn = [0.0, 0.50];
% exp1.no = [5, 10, 20, 50];
% exp1.nt = 1;
% exp1.cutoff_time_trial = 1200;
% exp1.skip_cut_of = ["nc", "ns", "no"];
% exp1.timestamp = "202411191733";
% 
% experiments(exp1);
% 
% % Fig.5 (202408281750) - coupling strength detectability threshold
% exp2 = struct();
% exp2.run = true;
% exp2.mvar_est_methods = {"lasso"};
% exp2.caus_est_methods = {"mvgc"};
% exp2.ns = [5000];
% exp2.nc = [20];
% exp2.exn = [0.0, 0.25, 0.50, 0.75];
% exp2.no = [10];
% exp2.nt = 100;
% exp2.timestamp = "202408281750";
% 
% experiments(struct("run", false), exp2);