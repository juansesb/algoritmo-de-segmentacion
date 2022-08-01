function [cwall, mask] = readcwall(xmlfile, imsize)
%Read XML file with pectoralis info from INbreast dataset
fid = fopen(xmlfile, 'r');

%Read xml file line by line:
N = 0;
cwall.x = [];
cwall.y = [];
while ~feof(fid)
    line = fgetl(fid);
    line = line(~isspace(line));
    if strcmp(line, '<string>PectoralMuscle</string>')||strcmp(line, '<string>Mass</string>')
        N = N + 1;
        while ~feof(fid)
            line = fgetl(fid);
            line = line(~isspace(line));
            if strcmp(line, '<key>NumberOfPoints</key>')
                line = fgetl(fid);
                line = line(~isspace(line));
                npts = strtok(line,'<integer>');
                npts = str2double(npts);
                cwall.x = zeros(npts, 1);
                cwall.y = zeros(npts, 1);
            end
            if strcmp(line, '<key>Point_px</key>')
                fgetl(fid); %array
                for n = 1:npts
                    line = fgetl(fid);
                    line = line(~isspace(line));
                    k1 = strfind(line, '(');
                    k2 = strfind(line, ',');
                    k3 = strfind(line, ')');
                    cwall.x(n) = str2double(line(k1+1:k2-1));
                    cwall.y(n) = str2double(line(k2+1:k3-1));
                end
                break
            end
        end
    end                
end

fclose(fid);

if isempty(cwall.x)
    fid = fopen(xmlfile, 'r');
    
    %Read xml file line by line:
    
    while ~feof(fid)
        line = fgetl(fid);
        line = line(~isspace(line));
        if strcmp(line, '<key>ROIPoints</key>')
            line = fgetl(fid); % <array>            
            line = fgetl(fid);
            line = line(~isspace(line));
            while (~feof(fid))&&(~strcmp(line,'</array>'))                
                k1 = strfind(line, '{');
                k2 = strfind(line, ',');
                k3 = strfind(line, '}');
                cwall.x = [cwall.x; str2double(line(k1+1:k2-1))];
                cwall.y = [cwall.y; str2double(line(k2+1:k3-1))];
                line = fgetl(fid);
                line = line(~isspace(line));
            end
            break
        end
    end
    fclose(fid);
end


%Build image mask
if (nargin<2)&&(nargout>1)
    mask = [];
    warning('I need image size to generate mask')
    return
elseif (nargout>1)    
    mask = poly2mask([1;cwall.x(1);cwall.x], [1;1;cwall.y], imsize(1), imsize(2));        
end

    
