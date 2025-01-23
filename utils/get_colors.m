function color = get_colors(name, shade, palette_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_colors
%   Returns color codes for different purposes. Color palettes are from MUI
%   colors for React JS development[1].
%       - name: (string | []) "red" | "pink" | "purple" | "deepPurple" |
%                             "indigo" | "blue" | "lightBlue" | "cyan" | 
%                             "teal" | "green" | "lightGreen" | "lime" |
%                             "yellow" | "amber" | "orange" | deepOrange" |
%                             "brown" | "grey" | "blueGrey" | [] for
%                             palette of a given shade.
%       - shade: (integer | []) returns 10 shades of name in an
%                               object if shade = [], otherwise, returns
%                               the requested shade of name.
%       - palette_id: (integer) number designating how many colors to
%                               return in the palette.
%
%   [1] https://mui.com/material-ui/customization/color/
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
    % Process inputs
    if ~exist("shade", "var") || ~isnumeric(shade)
        shade = 500;
    elseif isempty(shade)
        shade = 0;
    end

    % Get color/colors
    if ~exist("name", "var") || isempty(name)
        % Get palette of colors by shade
        color = get_palette(shade, palette_id);
    else
        % Get color by name and shade
        color = get_color_by_name_and_shade(name, shade);
    end
end

%% Utils
% Get color by name and shade
function color = get_color_by_name_and_shade(name, shade)
    if strcmpi(name, "red")
        switch shade
            case 50
                color = hex2rgb("#ffebee");
            case 100
                color = hex2rgb("#ffcdd2");
            case 200
                color = hex2rgb("#ef9a9a");
            case 300
                color = hex2rgb("#e57373");
            case 400
                color = hex2rgb("#ef5350");
            case 500
                color = hex2rgb("#f44336");
            case 600
                color = hex2rgb("#e53935");
            case 700
                color = hex2rgb("#d32f2f");
            case 800
                color = hex2rgb("#c62828");
            case 900
                color = hex2rgb("#b71c1c");
            otherwise
                color = {hex2rgb("#ffebee"), hex2rgb("#ffcdd2"), hex2rgb("#ef9a9a"), hex2rgb("#e57373"), hex2rgb("#ef5350"),...
                         hex2rgb("#f44336"), hex2rgb("#e53935"), hex2rgb("#d32f2f"), hex2rgb("#c62828"), hex2rgb("#b71c1c")};
        end
    end

    if strcmpi(name, "pink")
        switch shade
            case 50
                color = hex2rgb("#fce4ec");
            case 100
                color = hex2rgb("#f8bbd0");
            case 200
                color = hex2rgb("#f48fb1");
            case 300
                color = hex2rgb("#f06292");
            case 400
                color = hex2rgb("#ec407a");
            case 500
                color = hex2rgb("#e91e63");
            case 600
                color = hex2rgb("#d81b60");
            case 700
                color = hex2rgb("#c2185b");
            case 800
                color = hex2rgb("#ad1457");
            case 900
                color = hex2rgb("#880e4f");
            otherwise
                color = {hex2rgb("#fce4ec"), hex2rgb("#f8bbd0"), hex2rgb("#f48fb1"), hex2rgb("#f06292"), hex2rgb("#ec407a"),...
                         hex2rgb("#e91e63"), hex2rgb("#d81b60"), hex2rgb("#c2185b"), hex2rgb("#ad1457"), hex2rgb("#880e4f")};
        end
    end

    if strcmpi(name, "purple")
        switch shade
            case 50
                color = hex2rgb("#f3e5f5");
            case 100
                color = hex2rgb("#e1bee7");
            case 200
                color = hex2rgb("#ce93d8");
            case 300
                color = hex2rgb("#ba68c8");
            case 400
                color = hex2rgb("#ab47bc");
            case 500
                color = hex2rgb("#9c27b0");
            case 600
                color = hex2rgb("#8e24aa");
            case 700
                color = hex2rgb("#7b1fa2");
            case 800
                color = hex2rgb("#6a1b9a");
            case 900
                color = hex2rgb("#4a148c");
            otherwise
                color = {hex2rgb("#f3e5f5"), hex2rgb("#e1bee7"), hex2rgb("#ce93d8"), hex2rgb("#ba68c8"), hex2rgb("#ab47bc"),...
                         hex2rgb("#9c27b0"), hex2rgb("#8e24aa"), hex2rgb("#7b1fa2"), hex2rgb("#6a1b9a"), hex2rgb("#4a148c")};
        end
    end

    if strcmpi(name, "deepPurple")
        switch shade
            case 50
                color = hex2rgb("#ede7f6");
            case 100
                color = hex2rgb("#d1c4e9");
            case 200
                color = hex2rgb("#b39ddb");
            case 300
                color = hex2rgb("#9575cd");
            case 400
                color = hex2rgb("#7e57c2");
            case 500
                color = hex2rgb("#673ab7");
            case 600
                color = hex2rgb("#5e35b1");
            case 700
                color = hex2rgb("#512da8");
            case 800
                color = hex2rgb("#4527a0");
            case 900
                color = hex2rgb("#311b92");
            otherwise
                color = {hex2rgb("#ede7f6"), hex2rgb("#d1c4e9"), hex2rgb("#b39ddb"), hex2rgb("#9575cd"), hex2rgb("#7e57c2"),...
                         hex2rgb("#673ab7"), hex2rgb("#5e35b1"), hex2rgb("#512da8"), hex2rgb("#4527a0"), hex2rgb("#311b92")};
        end
    end

    if strcmpi(name, "indigo")
        switch shade
            case 50
                color = hex2rgb("#e8eaf6");
            case 100
                color = hex2rgb("#c5cae9");
            case 200
                color = hex2rgb("#9fa8da");
            case 300
                color = hex2rgb("#7986cb");
            case 400
                color = hex2rgb("#5c6bc0");
            case 500
                color = hex2rgb("#3f51b5");
            case 600
                color = hex2rgb("#3949ab");
            case 700
                color = hex2rgb("#303f9f");
            case 800
                color = hex2rgb("#283593");
            case 900
                color = hex2rgb("#1a237e");
            otherwise
                color = {hex2rgb("#e8eaf6"), hex2rgb("#c5cae9"), hex2rgb("#9fa8da"), hex2rgb("#7986cb"), hex2rgb("#5c6bc0"),...
                         hex2rgb("#3f51b5"), hex2rgb("#3949ab"), hex2rgb("#303f9f"), hex2rgb("#283593"), hex2rgb("#1a237e")};
        end
    end

    if strcmpi(name, "blue")
        switch shade
            case 50
                color = hex2rgb("#e3f2fd");
            case 100
                color = hex2rgb("#bbdefb");
            case 200
                color = hex2rgb("#90caf9");
            case 300
                color = hex2rgb("#64b5f6");
            case 400
                color = hex2rgb("#42a5f5");
            case 500
                color = hex2rgb("#2196f3");
            case 600
                color = hex2rgb("#1e88e5");
            case 700
                color = hex2rgb("#1976d2");
            case 800
                color = hex2rgb("#1565c0");
            case 900
                color = hex2rgb("#0d47a1");
            otherwise
                color = {hex2rgb("#e3f2fd"), hex2rgb("#bbdefb"), hex2rgb("#90caf9"), hex2rgb("#64b5f6"), hex2rgb("#42a5f5"),...
                         hex2rgb("#2196f3"), hex2rgb("#1e88e5"), hex2rgb("#1976d2"), hex2rgb("#1565c0"), hex2rgb("#0d47a1")};
        end
    end

    if strcmpi(name, "lightBlue")
        switch shade
            case 50
                color = hex2rgb("#e1f5fe");
            case 100
                color = hex2rgb("#b3e5fc");
            case 200
                color = hex2rgb("#81d4fa");
            case 300
                color = hex2rgb("#4fc3f7");
            case 400
                color = hex2rgb("#29b6f6");
            case 500
                color = hex2rgb("#03a9f4");
            case 600
                color = hex2rgb("#039be5");
            case 700
                color = hex2rgb("#0288d1");
            case 800
                color = hex2rgb("#0277bd");
            case 900
                color = hex2rgb("#01579b");
            otherwise
                color = {hex2rgb("#e1f5fe"), hex2rgb("#b3e5fc"), hex2rgb("#81d4fa"), hex2rgb("#4fc3f7"), hex2rgb("#29b6f6"),...
                         hex2rgb("#03a9f4"), hex2rgb("#039be5"), hex2rgb("#0288d1"), hex2rgb("#0277bd"), hex2rgb("#01579b")};
        end
    end

    if strcmpi(name, "cyan")
        switch shade
            case 50
                color = hex2rgb("#e0f7fa");
            case 100
                color = hex2rgb("#b2ebf2");
            case 200
                color = hex2rgb("#80deea");
            case 300
                color = hex2rgb("#4dd0e1");
            case 400
                color = hex2rgb("#26c6da");
            case 500
                color = hex2rgb("#00bcd4");
            case 600
                color = hex2rgb("#00acc1");
            case 700
                color = hex2rgb("#0097a7");
            case 800
                color = hex2rgb("#00838f");
            case 900
                color = hex2rgb("#006064");
            otherwise
                color = {hex2rgb("#e0f7fa"), hex2rgb("#b2ebf2"), hex2rgb("#80deea"), hex2rgb("#4dd0e1"), hex2rgb("#26c6da"),...
                         hex2rgb("#00bcd4"), hex2rgb("#00acc1"), hex2rgb("#0097a7"), hex2rgb("#00838f"), hex2rgb("#006064")};
        end
    end
    
    if strcmpi(name, "teal")
        switch shade
            case 50
                color = hex2rgb("#e0f2f1");
            case 100
                color = hex2rgb("#b2dfdb");
            case 200
                color = hex2rgb("#80cbc4");
            case 300
                color = hex2rgb("#4db6ac");
            case 400
                color = hex2rgb("#26a69a");
            case 500
                color = hex2rgb("#009688");
            case 600
                color = hex2rgb("#00897b");
            case 700
                color = hex2rgb("#00796b");
            case 800
                color = hex2rgb("#00695c");
            case 900
                color = hex2rgb("#004d40");
            otherwise
                color = {hex2rgb("#e0f2f1"), hex2rgb("#b2dfdb"), hex2rgb("#80cbc4"), hex2rgb("#4db6ac"), hex2rgb("#26a69a"),...
                         hex2rgb("#009688"), hex2rgb("#00897b"), hex2rgb("#00796b"), hex2rgb("#00695c"), hex2rgb("#004d40")};
        end
    end

    if strcmpi(name, "green")
        switch shade
            case 50
                color = hex2rgb("#e8f5e9");
            case 100
                color = hex2rgb("#c8e6c9");
            case 200
                color = hex2rgb("#a5d6a7");
            case 300
                color = hex2rgb("#81c784");
            case 400
                color = hex2rgb("#66bb6a");
            case 500
                color = hex2rgb("#4caf50");
            case 600
                color = hex2rgb("#43a047");
            case 700
                color = hex2rgb("#388e3c");
            case 800
                color = hex2rgb("#2e7d32");
            case 900
                color = hex2rgb("#1b5e20");
            otherwise
                color = {hex2rgb("#e8f5e9"), hex2rgb("#c8e6c9"), hex2rgb("#a5d6a7"), hex2rgb("#81c784"), hex2rgb("#66bb6a"),...
                         hex2rgb("#4caf50"), hex2rgb("#43a047"), hex2rgb("#388e3c"), hex2rgb("#2e7d32"), hex2rgb("#1b5e20")};
        end
    end

    if strcmpi(name, "lightGreen")
        switch shade
            case 50
                color = hex2rgb("#f1f8e9");
            case 100
                color = hex2rgb("#dcedc8");
            case 200
                color = hex2rgb("#c5e1a5");
            case 300
                color = hex2rgb("#aed581");
            case 400
                color = hex2rgb("#9ccc65");
            case 500
                color = hex2rgb("#8bc34a");
            case 600
                color = hex2rgb("#7cb342");
            case 700
                color = hex2rgb("#689f38");
            case 800
                color = hex2rgb("#558b2f");
            case 900
                color = hex2rgb("#33691e");
            otherwise
                color = {hex2rgb("#f1f8e9"), hex2rgb("#dcedc8"), hex2rgb("#c5e1a5"), hex2rgb("#aed581"), hex2rgb("#9ccc65"),...
                         hex2rgb("#8bc34a"), hex2rgb("#7cb342"), hex2rgb("#689f38"), hex2rgb("#558b2f"), hex2rgb("#33691e")};
        end
    end

    if strcmpi(name, "lime")
        switch shade
            case 50
                color = hex2rgb("#f9fbe7");
            case 100
                color = hex2rgb("#f0f4c3");
            case 200
                color = hex2rgb("#e6ee9c");
            case 300
                color = hex2rgb("#dce775");
            case 400
                color = hex2rgb("#d4e157");
            case 500
                color = hex2rgb("#cddc39");
            case 600
                color = hex2rgb("#c0ca33");
            case 700
                color = hex2rgb("#afb42b");
            case 800
                color = hex2rgb("#9e9d24");
            case 900
                color = hex2rgb("#827717");
            otherwise
                color = {hex2rgb("#f9fbe7"), hex2rgb("#f0f4c3"), hex2rgb("#e6ee9c"), hex2rgb("#dce775"), hex2rgb("#d4e157"),...
                         hex2rgb("#cddc39"), hex2rgb("#c0ca33"), hex2rgb("#afb42b"), hex2rgb("#9e9d24"), hex2rgb("#827717")};
        end
    end

    if strcmpi(name, "yellow")
        switch shade
            case 50
                color = hex2rgb("#fffde7");
            case 100
                color = hex2rgb("#fff9c4");
            case 200
                color = hex2rgb("#fff59d");
            case 300
                color = hex2rgb("#fff176");
            case 400
                color = hex2rgb("#ffee58");
            case 500
                color = hex2rgb("#ffeb3b");
            case 600
                color = hex2rgb("#fdd835");
            case 700
                color = hex2rgb("#fbc02d");
            case 800
                color = hex2rgb("#f9a825");
            case 900
                color = hex2rgb("#f57f17");
            otherwise
                color = {hex2rgb("#fffde7"), hex2rgb("#fff9c4"), hex2rgb("#fff59d"), hex2rgb("#fff176"), hex2rgb("#ffee58"),...
                         hex2rgb("#ffeb3b"), hex2rgb("#fdd835"), hex2rgb("#fbc02d"), hex2rgb("#f9a825"), hex2rgb("#f57f17")};
        end
    end

    if strcmpi(name, "amber")
        switch shade
            case 50
                color = hex2rgb("#fff8e1");
            case 100
                color = hex2rgb("#ffecb3");
            case 200
                color = hex2rgb("#ffe082");
            case 300
                color = hex2rgb("#ffd54f");
            case 400
                color = hex2rgb("#ffca28");
            case 500
                color = hex2rgb("#ffc107");
            case 600
                color = hex2rgb("#ffb300");
            case 700
                color = hex2rgb("#ffa000");
            case 800
                color = hex2rgb("#ff8f00");
            case 900
                color = hex2rgb("#ff6f00");
            otherwise
                color = {hex2rgb("#fff8e1"), hex2rgb("#ffecb3"), hex2rgb("#ffe082"), hex2rgb("#ffd54f"), hex2rgb("#ffca28"),...
                         hex2rgb("#ffc107"), hex2rgb("#ffb300"), hex2rgb("#ffa000"), hex2rgb("#ff8f00"), hex2rgb("#ff6f00")};
        end
    end

    if strcmpi(name, "orange")
        switch shade
            case 50
                color = hex2rgb("#fff3e0");
            case 100
                color = hex2rgb("#ffe0b2");
            case 200
                color = hex2rgb("#ffcc80");
            case 300
                color = hex2rgb("#ffb74d");
            case 400
                color = hex2rgb("#ffa726");
            case 500
                color = hex2rgb("#ff9800");
            case 600
                color = hex2rgb("#fb8c00");
            case 700
                color = hex2rgb("#f57c00");
            case 800
                color = hex2rgb("#ef6c00");
            case 900
                color = hex2rgb("#e65100");
            otherwise
                color = {hex2rgb("#fff3e0"), hex2rgb("#ffe0b2"), hex2rgb("#ffcc80"), hex2rgb("#ffb74d"), hex2rgb("#ffa726"),...
                         hex2rgb("#ff9800"), hex2rgb("#fb8c00"), hex2rgb("#f57c00"), hex2rgb("#ef6c00"), hex2rgb("#e65100")};
        end
    end

    if strcmpi(name, "deepOrange")
        switch shade
            case 50
                color = hex2rgb("#fbe9e7");
            case 100
                color = hex2rgb("#ffccbc");
            case 200
                color = hex2rgb("#ffab91");
            case 300
                color = hex2rgb("#ff8a65");
            case 400
                color = hex2rgb("#ff7043");
            case 500
                color = hex2rgb("#ff5722");
            case 600
                color = hex2rgb("#f4511e");
            case 700
                color = hex2rgb("#e64a19");
            case 800
                color = hex2rgb("#d84315");
            case 900
                color = hex2rgb("#bf360c");
            otherwise
                color = {hex2rgb("#fbe9e7"), hex2rgb("#ffccbc"), hex2rgb("#ffab91"), hex2rgb("#ff8a65"), hex2rgb("#ff7043"),...
                         hex2rgb("#ff5722"), hex2rgb("#f4511e"), hex2rgb("#e64a19"), hex2rgb("#d84315"), hex2rgb("#bf360c")};
        end
    end

    if strcmpi(name, "brown")
        switch shade
            case 50
                color = hex2rgb("#efebe9");
            case 100
                color = hex2rgb("#d7ccc8");
            case 200
                color = hex2rgb("#bcaaa4");
            case 300
                color = hex2rgb("#a1887f");
            case 400
                color = hex2rgb("#8d6e63");
            case 500
                color = hex2rgb("#795548");
            case 600
                color = hex2rgb("#6d4c41");
            case 700
                color = hex2rgb("#5d4037");
            case 800
                color = hex2rgb("#4e342e");
            case 900
                color = hex2rgb("#3e2723");
            otherwise
                color = {hex2rgb("#efebe9"), hex2rgb("#d7ccc8"), hex2rgb("#bcaaa4"), hex2rgb("#a1887f"), hex2rgb("#8d6e63"),...
                         hex2rgb("#795548"), hex2rgb("#6d4c41"), hex2rgb("#5d4037"), hex2rgb("#4e342e"), hex2rgb("#3e2723")};
        end
    end

    if strcmpi(name, "grey")
        switch shade
            case 50
                color = hex2rgb("#fafafa");
            case 100
                color = hex2rgb("#f5f5f5");
            case 200
                color = hex2rgb("#eeeeee");
            case 300
                color = hex2rgb("#e0e0e0");
            case 400
                color = hex2rgb("#bdbdbd");
            case 500
                color = hex2rgb("#9e9e9e");
            case 600
                color = hex2rgb("#757575");
            case 700
                color = hex2rgb("#616161");
            case 800
                color = hex2rgb("#424242");
            case 900
                color = hex2rgb("#212121");
            otherwise
                color = {hex2rgb("#fafafa"), hex2rgb("#f5f5f5"), hex2rgb("#eeeeee"), hex2rgb("#e0e0e0"), hex2rgb("#bdbdbd"),...
                         hex2rgb("#9e9e9e"), hex2rgb("#757575"), hex2rgb("#616161"), hex2rgb("#424242"), hex2rgb("#212121")};
        end
    end

    if strcmpi(name, "blueGrey")
        switch shade
            case 50
                color = hex2rgb("#eceff1");
            case 100
                color = hex2rgb("#cfd8dc");
            case 200
                color = hex2rgb("#b0bec5");
            case 300
                color = hex2rgb("#90a4ae");
            case 400
                color = hex2rgb("#78909c");
            case 500
                color = hex2rgb("#607d8b");
            case 600
                color = hex2rgb("#546e7a");
            case 700
                color = hex2rgb("#455a64");
            case 800
                color = hex2rgb("#37474f");
            case 900
                color = hex2rgb("#263238");
            otherwise
                color = {hex2rgb("#eceff1"), hex2rgb("#cfd8dc"), hex2rgb("#b0bec5"), hex2rgb("#90a4ae"), hex2rgb("#78909c"),...
                         hex2rgb("#607d8b"), hex2rgb("#546e7a"), hex2rgb("#455a64"), hex2rgb("#37474f"), hex2rgb("#263238")};
        end
    end
end

%% Get palette of colors
function color = get_palette(shade, id)
    % Color names
    full_color_names = {"red", "pink", "purple", "deepPurple", "indigo", "blue",...
                   "lightBlue", "cyan", "teal", "green", "lightGreen",...
                   "lime", "yellow", "amber", "orange", "deepOrange",...
                   "brown", "grey", "blueGrey" };
    
    tiny_color_names = {"red", "blue", "green", "orange" };
    
    small_color_names = {"red", "purple", "blue", "green", "yellow",...
                         "orange", "brown", "blueGrey" };
    
    medium_color_names = {"red", "pink", "purple", "indigo", "lightBlue", "teal", "lightGreen", "yellow",...
                         "orange", "brown", "blueGrey" };

    % Container for output
    color = cell(id, 1);

    % Get right color names based on id size
    if (id < 5)
        color_names = tiny_color_names;         % up to 4 colors: tiny_color_names

    elseif (id < 9)
        color_names = small_color_names;        % up to 8 colors: small_color_names

    elseif (id < 12)
        color_names = medium_color_names;       % up to 11 colors: medium_color_names

    else
        color_names = full_color_names;         % More: full_color_names
    end

    % Loop to put the colors in the return container
    for cid = 1 : length(color)
        color{cid} = get_color_by_name_and_shade(color_names{mod(cid, length(color_names))}, shade);
    end
end