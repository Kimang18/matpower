function mpv = mpver

%% the following only works if MATPOWER is explicitly in the path,
%% but not if it is only in the current working directory
% fs = filesep;
% p = fileparts(which('runpf'));
% if ~strcmp(p(1),fs)
%   [t, p] = strtok(p, filesep);
% end
% p = p(2:end);
% v{1} = ver(p);

v{1} = struct(  'Name',     'MATPOWER', ... 
                'Version',  '3.0b3+', ...
                'Release',  '', ...
                'Date',     '20-Sep-2004' );
v{2} = ver('matlab');
v{3} = ver('optim');
if nargout > 0
    mpv = v{1}.Version;
else
    for n = 1:3
        fprintf('\n%-22s Version %-9s  %11s', v{n}.Name, v{n}.Version, v{n}.Date);
        if ~isempty(v{n}.Release)
            fprintf('   Release: %-10s', v{n}.Release);
        end
    end
    fprintf('\n');
    
    if have_fcn('bpmpd')
        if exist('bpver')
            bpver
        else
            fprintf('BPMPD_MEX              Version 2.21 or earlier\n');
        end
    else
        fprintf('BPMPD_MEX              not installed\n');
    end
    
    if have_fcn('minopf')
        if exist('minopfver')
            minopfver;
        else
            fprintf('MINOPF                 Version 3.0b2 or earlier\n');
        end
    else
        fprintf('MINOPF                 not installed\n');
    end
    fprintf('Architecture:          %s\n\n', computer);
end

return;
