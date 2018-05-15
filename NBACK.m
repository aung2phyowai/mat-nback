%% Dec Master Function
% function NBACK()

%% Suppress warnings
%#ok<*ST2NM>
%#ok<*SAGROW>

%% Setup parameters

% Screen('Preference', 'SkipSyncTests', 1);
clear;

SSID=inputdlg('Subject ID')
params={  SSID, ... % subject id
			'2', ... % N-back number
			'2', ... % number of blocks
			'4', ... % number of matches per block
			'20'};   % number of trials per block

% yn = questdlg('Run with defaults?');
% if strcmp(yn,'Yes')
	% disp('Running with defaults...');
% elseif strcmp(yn,'No')
	% prompt={'Subject ID','N=?','Number of blocks','Number of matches','Trials per block'};
		
	% repeat = true;
	% while repeat == true
		% params=inputdlg(prompt,'Inputs',1,params);
		% if strcmp(questdlg(strcat('Running sub-',num2str(SSID),'. Is that correct?')),'Yes')
			% repeat = false;

		% end
    % end
% end

SSID=params{1}{1};
nBack=str2num(params{2}); N=nBack;
nBlock=str2num(params{3});
nMatch=str2num(params{4});
nTrial=str2num(params{5});


% output file name
output_dir = strcat('../../sourcedata/sub-',SSID);
mkdir(output_dir);
fName = strcat(output_dir,'/sub-',SSID,'_task-nback_beh.xlsx'); % output file name
fNameALT = strcat(output_dir,'/sub-',SSID,'_task-nback_beh__',num2str(randi([10000 99999])),'.xlsx'); % alternate file name

ListenChar(0); % Suppress keystrokes to the console or editor

%% Initialize

KbCheck;
WaitSecs(0.1);
GetSecs;
for randomizer=1:999
    randi(47);
    rand(47);
end

warning('off','all');

%% Open the screen

AssertOpenGL;
KbName('UnifyKeyNames');

screens=Screen('Screens');
screenNumber=max(screens);
% gray = GrayIndex(screenNumber);
% lightgray = [220 220 220];
% lightergray = [230 230 230];
% white = [255 255 255];
[w,wRect]=Screen('OpenWindow',screenNumber, 155);
HideCursor();
[x,y] = RectCenter(wRect);

feedRectTop = [x-50 y-100 x+50 y-75];
feedRectBot = [x-50 y+75 x+50 y+100];
feedColorRed = [200 0 0];
feedColorGrn = [0 200 0];

Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 25);
Screen('TextStyle',w, 0);

%% Generate blocks and outputs

for b=1:nBlock
    
    check = false;
    while check == false
        taskOrder(:,b)=randi(9,[nTrial 1]);
        taskCResp(:,b)=zeros([nTrial 1]);
        for m=N+1:nTrial
            if taskOrder(m,b) == taskOrder(m-N,b)
                taskCResp(m,b)=1;
            end
        end
        if sum(taskCResp(:,b)) ~= nMatch
            check=false;
        else
            check=true;
        end
    end
end

taskResp = zeros(nTrial,nBlock);
taskRT = zeros(nTrial,nBlock);

pracHdr = {'prac.Rsp','prac.CRsp','prac.RT'};
for i=1:nBlock
    taskHdr{((i-1)*3)+1}=['b',num2str(i),'.Rsp'];
    taskHdr{((i-1)*3)+2}=['b',num2str(i),'.CRsp'];
    taskHdr{((i-1)*3)+3}=['b',num2str(i),'.RT'];
end

%% Instructions

Screen('TextSize',w, 25);
DrawFormattedText(w,['This is an N-back task.\n\n', ...
    'You will be shown a series of digits and asked \n', ...
    'to identify whether the digit is a TARGET.\n\n', ...
    'TARGET digits will be the ones that match \n', ...
    'digits shown previously at certain intervals.\n\n', ...
    'Try to respond as quickly as possible,\n', ...
    'but remember that accuracy is most important.\n\n', ...
    'Press SPACE to continue'],...
    'center','center', [],[],[],[], 2);

Screen('Flip',w);
resp=[];
while ~strcmp(resp,'space')
        [~,keyCode,~]=KbWait([],2);
        resp=KbName(keyCode);
end; resp=[];

if nBack == 2
    % set up 2-back instruction slides
    instrucFiles = dir('instrucs_2back\*.tif');
    
    for i=1:length(instrucFiles)
        % I=['instrucs_2BACK\Slide',num2str(i),'.tif'];
        I = strcat('instrucs_2back\',instrucFiles(i).name);
        instrucs{i}=imread(I);
    end
    
    for i=1:length(instrucs)
        Screen('PutImage',w,instrucs{i});
        Screen('Flip',w);
        while ~strcmp(resp,'space')
            [~,keyCode,~]=KbWait([],2);
            resp=KbName(keyCode);
        end; resp=[];
    end
end

if nBack == 3
    % set up 3-back instruction slides
end

% et cetera, 1-back, 0-back


%% Practice 
pracOrder = [3;6;5;7;1;7;5;8;5;4;9;6;8;6;2];
pracCResp = [0;0;0;0;0;1;0;0;1;0;0;0;0;1;0];
pracResp = zeros(15,1); pracRT = zeros(15,1);

repeat = true;
while repeat == true
    Screen('TextSize',w, 25);
    DrawFormattedText(w,['Next you will practice the task.\n\n', ...
        'Press SPACE to begin'],'center','center');
    Screen('Flip',w);
    while ~strcmp(resp,'space')
        [~,keyCode,~]=KbWait([],3);
        resp=KbName(keyCode);
    end; resp=[];
    
    Screen('TextSize',w, 25);
    DrawFormattedText(w,'Ready!','center','center');
    Screen('Flip',w);
    
    WaitSecs(4);
    
    for i=1:length(pracOrder)
        
        Screen('TextSize',w, 60);
        DrawFormattedText(w,num2str(pracOrder(i)),'center','center');
        Screen('Flip',w); resp = false;
        
        t0=GetSecs; timer=0;
        while timer <= 2000
            t1=GetSecs;
            timer=(round((t1-t0)*1000));
            [~,~,keyCode,~]=KbCheck;
            %         resp=KbName(keyCode);
            
            if resp == false
                if keyCode(32) %|| keyCode(49)
                    pracResp(i,1) = 1;
                    pracRT(i,1)=timer; resp = true;
                    %                 Screen('FillRect',w, feedColorGrn, feedRectTop);
                    %                 Screen('FillRect',w, feedColorGrn, feedRectBot);
                    %                 Screen('Flip',w);
                end
            end
            
        end
        
        %     if pracRT(i,1) == 0, pracRT(i,1) = 3000; end
        Screen('TextSize',w, 40);
        DrawFormattedText(w,'+','center','center');
        %     if resp == false
        %         Screen('FillRect',w, feedColorRed, feedRectTop);
        %         Screen('FillRect',w, feedColorRed, feedRectBot);
        %     end
        Screen('Flip',w); resp=[]; WaitSecs(1);
    end
    
    Screen('TextSize',w, 25);
    DrawFormattedText(w,['You have completed the practice trials.\n', ...
        'Let your experimenter know if you would like to practice again.\n\n', ...
        'Press SPACE to continue'], ...
        'center','center', [],[],[],[], 2);
    Screen('Flip',w);
    
    while ~strcmp(resp,'space') && ~strcmp(resp,'BackSpace')
        [~,keyCode,~]=KbWait([],3);
        resp=KbName(keyCode);
    end
     
    if ~strcmp(resp,'BackSpace')
        repeat = false;
    end
end
    
%% Start Task
for b=1:nBlock
    
    Screen('TextSize',w, 25);
    DrawFormattedText(w,'Ready!','center','center');
    Screen('Flip',w);
    
    WaitSecs(4);
    
    for t=1:nTrial
        Screen('TextSize',w, 60);
        DrawFormattedText(w,num2str(taskOrder(t,b)),'center','center');
        Screen('Flip',w); resp = false;
        
        t0=GetSecs; timer=0;
        while timer <= 2000
            t1=GetSecs;
            timer=(round((t1-t0)*1000));
            [~,~,keyCode,~]=KbCheck;
            %         resp=KbName(keyCode);
            
            if resp == false
                if keyCode(32) %|| keyCode(49)
                    taskResp(t,b) = 1;
                    taskRT(t,b) = timer; resp = true;
%                     Screen('FillRect',w, feedColorGrn, feedRectTop);
%                     Screen('FillRect',w, feedColorGrn, feedRectBot);
%                     Screen('Flip',w);
                end
            end
            
        end
        
        %     if pracRT(i,1) == 0, pracRT(i,1) = 3000; end
        Screen('TextSize',w, 40);
        DrawFormattedText(w,'+','center','center');
        %     if resp == false
        %         Screen('FillRect',w, feedColorRed, feedRectTop);
        %         Screen('FillRect',w, feedColorRed, feedRectBot);
        %     end
        Screen('Flip',w); resp=[]; WaitSecs(1);
    end
    
    Screen('TextSize',w,40);
    DrawFormattedText(w,'Short Break','center',y-300);
    Screen('TextSize',w,25);
    DrawFormattedText(w,['You have completed block ', ...
        num2str(b),' of the task.\n\n', ...
        'Press SPACE to continue'], ... 
        'center','center', [],[],[],[], 2);
    Screen('Flip',w);
    
    while ~strcmp(resp,'space')
        [~,keyCode,~]=KbWait([],2);
        resp=KbName(keyCode);
    end; resp=[];
end

Screen('TextSize',w, 25);
DrawFormattedText(w,strcat('You have finished the N-back task.\n\n', ...
    'Please wait...'),'center','center');
Screen('Flip',w);

%% Export datafile

pracOut = [num2cell(pracResp), ...
    num2cell(pracCResp), ...
    num2cell(pracRT)];
pracOut=[pracHdr; pracOut];

taskOut=cell(nTrial,nBlock*3);
for b=1:nBlock
    for t=1:nTrial
        taskOut{t,1+((b-1)*nBlock)} = taskResp(t,b);
        taskOut{t,2+((b-1)*nBlock)} = taskCResp(t,b);
        taskOut{t,3+((b-1)*nBlock)} = taskRT(t,b);
    end
end
taskOut=[taskHdr;taskOut];

% output file name now defined at initialization
% fName=strcat('sub-',num2str(SSID),'_task-nback_','beh.xlsx'); % output file name

try
    xlswrite(fName,pracOut,2);
    xlswrite(fName,taskOut,1);
catch me
    fName=fNameALT;
    xlswrite(fName,pracOut,2);
    xlswrite(fName,taskOut,1);
end

% xlswrite(fName,pracOut,2);
% xlswrite(fName,taskOut,1);

Screen('TextSize',w, 25);
DrawFormattedText(w,strcat('You have finished the N-back task.\n\n', ...
    'Press Q to exit'),'center','center');
Screen('Flip',w);

%% Close and Exit



while ~strcmp(resp,'q')
    [~,keyCode,~]=KbWait([],2);
    resp=KbName(keyCode);
end; resp=[];

Screen('CloseAll');

KbWait([],1); % Wait for all keys to be released,
ListenChar(); % then stop suppressing keystrokes.
% clear all