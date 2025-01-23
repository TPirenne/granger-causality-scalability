function mc = use_colormap(m, cmap)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use_colormap
%   From color map cmap, return colors of each value in matrix m. Scaling
%   of m is between [0,1].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mc = round(m * size(cmap, 1));
    mc(mc < 1) = 1;
    mc(mc > size(cmap, 1)) = size(cmap, 1);
    mc = mc(~isnan(mc));
    mc = cmap(mc, :);
end

