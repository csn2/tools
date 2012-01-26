% Makes animation (default using contourf). Assumes last dimension is to be looped by default. 
% Else specify index. Allows browsing.
%       [] = animate(xax,yax,data,labels,commands,index,pausetime)
%           xax,yax - x,y axes (both optional) - can be empty []
%           data - data to be animated - script squeezes data
%           labels - Structure with following fields for labeling plot (optional - can be [])
%               > title
%               > xax
%               > yax
%               > revz - reverse yDir?
%               > time - where to pull time info for titles
%               > tunits - units for time vector labels.time
%               > tmax  - maximum value of time vector : needed when only
%                         part of data is being plotted at a time. set by
%                         default to max(labels.time) if not defined
%           commands - custom commands to execute after plot or one of below. (in string, optional)
%                    - separate commands using ;
%               > nocaxis - non-constant colorbar
%               > pcolor  - use pcolor instead of contourf
%               > imagesc - use imagesc(nan) instead of contourf. imagescnan is tried first
%           index - dimension to loop through (optional)
%           pausetime - pause(pausetime) (optional)
%
% USAGE:
%       animate(data)
%       animate(xax,yax,data)
%       animate([],[],data,...
%       animate(xax,yax,data,commands)
%               eg: animate(xax,yax,data,'pcolor;nocaxis')
%
% BROWSE:
%       - first space pauses, second space resumes, remaining spaces *play*
%       - arrowkeys *pause* and navigate always
%       - Esc to quit

function [] = animate(xax,yax,data,labels,commands,index,pausetime)

    % figure out input
    narg = nargin;
    
    switch narg
        case 1,
            data = squeeze(xax);
            s    = size(data);
            xax  = 1:s(1); 
            yax  = 1:s(2);
            
        case 2,
            data = xax;
            commands = yax;
            xax = [];
            yax = [];            
            
        case 4,
            if strcmp(class(labels),'char')
               commands = labels;
               labels = [];
            end
    end
    
    data = squeeze(data);
    s = size(data);
       
    if narg <= 5 || ~exist('index','var')
        stop = size(data,3);
        index = length(s); % set last dimension to loop by default
    else
        stop = s(index);
    end
    
    if narg ~= 7 || ~exist('pausetime','var')
        pausetime = 0.2;
    end
    
    if ~exist('labels','var') || isempty(labels)
        labels.title = '';
        labels.xax   = '';
        labels.yax   = '';
        labels.revz  = 0;
        labels.time  = [];
    end
    
    if ~isfield(labels,'tmax'), labels.tmax = labels.time(end); end
    
    if ~exist('commands','var')
        commands = '';
    end
    
    if isempty(xax), xax = 1:s(1); end;
    if isempty(yax), yax = 1:s(2); end;
    
    %% processing
    
    if stop == 1, warning('Only one time step.'); end
    
    plotdata = double(squeeze(shiftdim(data,index)));
    
    datamax = nanmax(plotdata(:));
    datamin = nanmin(plotdata(:));
    
    hfig = gcf;
    ckey = '';
    button = [];
    pflag = 0;
    spaceplay = 1; % if 1, space pauses. if 0, space plays
    %caxisflag = 1; % constant color bar
    
    flag = [0 0 0];% defaults
    
    cmds = {'nocaxis','pcolor','imagesc'};
    for i = 1:length(cmds)
        loc = strfind(commands,cmds{i});
        if ~isempty(loc)
            flag(i) = 1;
            commands = [commands(1:loc-1) commands(loc+length(cmds{i}):end)];
        end
    end
    
    plotflag = sum([2 3] .* flag(2:3));

    i=0;
    while i<=stop-1

        if strcmp(ckey,'space') & isempty(button)
            spaceplay = ~spaceplay;
        end

        pflag = ~spaceplay;
        
        if pflag,
            [x,y,button] = ginput(1);
            figure(gcf);
            if button == 32, spaceplay = 1; end % resumes when paused
            if button == 27, break; end % exit when Esc is pressed.
        else
            pause(pausetime);
        end  
        
        ckey = get(gcf,'currentkey'); 
        
        % navigate : other keys move forward
        if strcmp(ckey,'leftarrow') | strcmp(ckey,'downarrow') | button == 28 | button == 31 
            pflag = 1; spaceplay = 0;
            i = i-2;
        else if strcmp(ckey,'rightarrow') | strcmp(ckey,'uparrow') | button == 29 | button == 30 
                pflag = 1; spaceplay = 0;
            end
        end
        
        if strcmp(ckey,'escape')
            break
        end
        
        i=i+1;
        if i < 1, i = 1; end
        
        %% Plot
        
        switch plotflag
            case 2
                pcolor(xax,yax,plotdata(:,:,i)'); %shading interp
            case 3
                try
                    imagescnan(xax,yax,plotdata(:,:,i)');
                catch ME
                    imagesc(xax,yax,plotdata(:,:,i)'); %shading flat
                end
            otherwise
                contourf(xax,yax,plotdata(:,:,i)', 40); %shading flat
        end
        shading flat;
        
        if labels.revz, revz; end;
        if isempty(labels.time)
            title([labels.title ' t instant = ' num2str(i)]);
        else
            title([labels.title ' t = ' sprintf('%.2f/%.2f ', labels.time(i),labels.tmax) labels.tunits]);
        end
        xlabel(labels.xax);
        ylabel(labels.yax);
        if ~flag(1)
            if datamax ~=datamin, caxis([datamin datamax]); end
        end
        colorbar;        
        eval(commands); % execute custom commands
    end