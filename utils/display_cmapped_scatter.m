function display_cmapped_scatter(ax, x, y, z, color_name)
    x_nonan = x(~isnan(z));
    z_nonan = z(~isnan(z));
    y_nonan = y(~isnan(z));
    
    color_shades = get_colors(color_name, []);
    shade_prop = 0.6;
    color = color_shades{round(length(color_shades) * shade_prop)};
    color_light = color_shades{round(length(color_shades) * 0.1)};
    cmap = get_colormap(color_light, color);
    fcolors = use_colormap(z_nonan, cmap);
    
    % Display markers
    marker_size = 20;
    scatter(ax, x_nonan, y_nonan, marker_size, fcolors, 'filled', 'HandleVisibility', 'off');
    scatter(ax, x_nonan, y_nonan, marker_size, color, 'HandleVisibility', 'off', "Marker", "o");
    clim([0,1]);
end

