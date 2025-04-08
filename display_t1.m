%% Models
t_mvgclwr = @(c,s,o) (-0.5 + 8e-6 * c.^(2.1) * s.^(0.2) * o.^(1.6));
t_mvgcols = @(c,s,o) (-0.8 + 2e-5 * c.^(2.8) * s.^(-0.3) * o.^(1.7));
t_mvgclasso = @(c,s,o) (1.6 + 4e-7 * c.^(3.5) * s.^(0.1) * o.^(1.9));
t_mvgcsbl = @(c,s,o) (-73.8 + 6e-8 * c.^(2.1) * s.^(2.3) * o.^(0.1));
t_pdclwr = @(c,s,o) (49.9 + 3e-7 * c.^(5.3) * s.^(-0.1) * o.^(1.2));

% s = 14 * c - 200
t_mvgclwr = @(c,o) (-0.5 + 8e-6 .* c.^(2.1) .* (14.*c-200).^(0.2) .* o.^(1.6));
t_mvgcols = @(c,o) (-0.8 + 2e-5 .* c.^(2.8) .* (14.*c-200).^(-0.3) .* o.^(1.7));
t_mvgclasso = @(c,o) (1.6 + 4e-7 .* c.^(3.5) .* (14.*c-200).^(0.1) .* o.^(1.9));
t_mvgcsbl = @(c,o) (-73.8 + 6e-8 .* c.^(2.1) .* (14.*c-200).^(2.3) .* o.^(0.1));
t_pdclwr = @(c,o) (49.9 + 3e-7 .* c.^(5.3) .* (14.*c-200).^(-0.1) .* o.^(1.2));

daytime = 60 * 60 * 24;
weektime = daytime * 7;
monthtime = daytime * 30;
yeartime = daytime * 365;

%% Display
% Params
cs = 1:1:100000;
% s = 20000;
o = 10;

% Display
figure();
hold("on");

plot(cs, t_mvgclwr(cs,o), "DisplayName", "mvgc-lwr");
plot(cs, t_mvgcols(cs,o), "DisplayName", "mvgc-ols");
plot(cs, t_mvgclasso(cs,o), "DisplayName", "mvgc-lasso");
plot(cs, t_mvgcsbl(cs,o), "DisplayName", "mvgc-sbl");
plot(cs, t_pdclwr(cs,o), "DisplayName", "pdc-lwr");

legend("AutoUpdate", "off");

yline(daytime, ":", "Color", "black");
yline(weektime, ":", "Color", "black");
yline(monthtime, ":", "Color", "black");
yline(yeartime, ":", "Color", "black");

ylim([0, yeartime + 100]);
xlabel("nc");
ylabel("computation time");