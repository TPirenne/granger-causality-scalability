function display_std(f, x, std_data, mean_data, color)
    % Crop NaNs
    rm_idx = isnan(std_data) | isnan(mean_data);
    x(rm_idx) = [];
    std_data(rm_idx) = [];
    mean_data(rm_idx) = [];

    % Make column vectors if not already
    if iscolumn(x)
        x = x';
    end

    if iscolumn(std_data)
        std_data = std_data';
    end

    if iscolumn(mean_data)
        mean_data = mean_data';
    end

    % Display
    xconf = [x, x(end:-1:1)];
    
    upper = mean_data + std_data;
    lower = mean_data - std_data;
    yconf = [upper, lower(end:-1:1)];
    
    fill(f, xconf, yconf, color, "EdgeColor", "none", "FaceAlpha", 0.2, "HandleVisibility", "off");
end

