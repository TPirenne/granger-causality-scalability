function map = get_colormap(c1, c2, c3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_colormap
%   Returns custom colormap interpolating colors between c1 and c2. They
%   must be specified in hex format ("#16b654") or as rgb array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(c1) ~= 3
        c1 = hex2rgb(c1);
    end

    if length(c2) ~= 3
        c2 = hex2rgb(c2);
    end

    if exist("c3", "var")
        if length(c3) ~= 3
            c3 = hex2rgb(c3);
        end

        % from c1 to c2
        vec = [ 50; 0];
        raw = cat(1, c1, c2);
        N = 128;
        map1 = interp1(vec,raw,linspace(50,0,N),'pchip');

        % from c2 to c3
        vec = [ 50; 0];
        raw = cat(1, c2, c3);
        N = 128;
        map2 = interp1(vec,raw,linspace(50,0,N),'pchip');

        % output
        map = cat(1, map1, map2);
    else
        vec = [ 100; 0];
        raw = cat(1, c1, c2);
        N = 128;
        map = interp1(vec,raw,linspace(100,0,N),'pchip');
    end
end

