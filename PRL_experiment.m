function PRL_experiment()
sca;
close all;
clearvars;

try
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% 1. setting variables
%--------------------------------------------------------------------------

% number of blocks in the experiment
N_BLOCKS = 2;
% maximum number of trials per block
N_TRIALS_MAX = 240; %actually 240
% maximum number of reversals per block
N_REVERSAL_MAX = 12; %actually 12
% number of visual stimuli (blue and yellow squares)
N_STIMULI = 2;
% within-group faktor feedback type (1 = social, 2 = non-social)
FB_TYPE = [1, 2];
% counter for number of trials per block (starts at 1)
counter.trial_block = 1;
% counter for number of blocks (starts at 1)
counter.blocks = 1;
% counter for number of reversals (starts at 0)
counter.reversals = 0;
% counter for number of trails to meet learning criterion
counter.lc_trials = 0;
% counter for correct choices to meet learning criterion
counter.lc_correct = 0;
% vector to represent which stimulus is currently associated with positive
% feedback (initialized to zero)
%   - first position corresponds to blue stimulus
%   - second position corresponds to yellow stimulus
%   - 1 = rewarded, 0 = not rewarded
rewarded = [0, 0];
% which stimulus has been chosen in a given trial
%   1 = blue stimulus, 2 = yellow stimulus (initialized to zero)
chosen = 0; 
% variable to store the feedback that was given in a trial
% (0 = negative, 1 = positive)
fb_given = 0;
% variable to indicate whether a reversal happened after a trial or not
reversal = 0;
% time between stimulus presentation and feedback presentation (measured by
% tic toc)
stim_to_fb = 0;
% time between feedback presentation and end of trial
fb_to_newtrial = 0;
% determine background color
bg_color = [105, 105, 105]; %gray
% determine highlight color for highlighting chosen stimulus 
hl_color = [255, 165, 0]; % orange
% determine pen width for highlighting chosen stimulus
hl_width = 4;

%--------------------------------------------------------------------------
% response key settings
%--------------------------------------------------------------------------

% unify key names for better portability
KbName('UnifyKeyNames');
% response keys for right-handed participants
resp_keys_right = ["LeftArrow", "RightArrow", "UpArrow", "DownArrow"];
% response keys for left-handed participants
resp_keys_left = ['a', 'd', 'w', 's'];
% set default to right
response_keys = resp_keys_right;

%--------------------------------------------------------------------------
% load images for stimuli and feedback
%--------------------------------------------------------------------------

% load images of stimuli and include alpha channels
[stim_yellow, ~, alpha_yellow] = imread('gfx/stim_yellow.png');
stim_yellow(:, :, 4) = alpha_yellow;
[stim_blue, ~, alpha_blue] = imread('gfx/stim_blue.png');
stim_blue(:, :, 4) = alpha_blue;

% load images of non-social feedback and include alpha channels
[fb_non_pos, ~, alpha_fb_non_pos] = imread('gfx/fb_non_pos.png');
fb_non_pos(:, :, 4) = alpha_fb_non_pos;
[fb_non_neg, ~, alpha_fb_non_neg] = imread('gfx/fb_non_neg.png');
fb_non_neg(:, :, 4) = alpha_fb_non_neg;

%load images of social feedback and include alpha channels
[fb_s_pos_m, ~, alpha_fb_s_pos_m] = imread('gfx/fb_s_pos_m.png');
fb_s_pos_m(:, :, 4) = alpha_fb_s_pos_m;
[fb_s_neg_m, ~, alpha_fb_s_neg_m] = imread('gfx/fb_s_neg_m.png');
fb_s_neg_m(:, :, 4) = alpha_fb_s_neg_m;
[fb_s_pos_f, ~, alpha_fb_s_pos_f] = imread('gfx/fb_s_pos_f.png');
fb_s_pos_f(:, :, 4) = alpha_fb_s_pos_f;
[fb_s_neg_f, ~, alpha_fb_s_neg_f] = imread('gfx/fb_s_neg_f.png');
fb_s_neg_f(:, :, 4) = alpha_fb_s_neg_f;
%--------------------------------------------------------------------------
% settings for input dialog at beginning of experiment
%--------------------------------------------------------------------------

% general settings
dlg.prompt = {'Participant-Nr. (overall)',...
              'Group (1 = contol, 2 = ASD)',...
              'Participant-Nr. (per group)',...
              'Handedness (1 = left, 2 = right)'};
dlg.title = 'Participant Information';
dlg.numlines = 1;
dlg.defaults = {'', '', '', ''};
opts.Resize = 'on';

% call input dialog and store answers
answer = inputdlg(dlg.prompt, dlg.title, dlg.numlines, dlg.defaults, opts);

% convert answer cell array to vector for better handling
try
    answer_vect = cellfun(@str2num, answer);
catch
    % show error message in case that values entered into input dialog
    % are not valid
    msg = sprintf(['Error getting Participant Info: ',...
                   'Please take care of the following:\n\n',...
                   ' - ''Participant-Nr. (overall)'' must be a positive integer\n',...
                   ' - ''Group'' must be either 1 (for control) or 2 (for ASD)\n',...
                   ' - ''Participant-Nr (per group)'' must be a positive integer\n',...
                   ' - ''Handedness'' must be either 1 (left-handed) or 2 (right-handed)\n']);
    error(msg);
end

% make sure that answer for 'Participant-Nr. (overall)' is a postive number
assert((isnumeric(answer_vect(1)) && answer_vect(1) >= 0),...
       sprintf(['Error while getting Participant Info:\n',...
        '''Participant-Nr. (overall)'' must be a positive integer']));
   
% make sure that answer for 'Group' is either 1 or 2
assert((isnumeric(answer_vect(2)) &&...
       (answer_vect(2) == 1 || answer_vect(2) == 2)),...
       sprintf(['Error while getting Participant Info:\n',...
        '''Group'' must be either 1 (for control) or 2 (for ASD)']));
   
% make sure that answer for 'Participant-Nr. (per group)' is a postive
% number
assert((isnumeric(answer_vect(3)) && answer_vect(3) >= 0),...
       sprintf(['Error while getting Participant Info:\n',...
        '''Participant-Nr. (per-group)'' must be a positive integer']));
   
% make sure that answer for 'Handednes' is either 1 or 2
assert((isnumeric(answer_vect(2)) &&...
       (answer_vect(4) == 1 || answer_vect(4) == 2)),...
       sprintf(['Error while getting Participant Info:\n',...
        '''Handedness'' must be either 1 (for left) or 2 (for right)']));
   
%--------------------------------------------------------------------------
% settings based on answers to input dialog
%--------------------------------------------------------------------------

% set response keys based on specified handedness of paritcipant
if answer_vect(4) == 1
    % use response keys for left hand
    response_keys = resp_keys_left;
else
    % use response keys for right hand
    response_keys = resp_keys_right;
end

%--------------------------------------------------------------------------
% settings for data output file 
%--------------------------------------------------------------------------

% Define name of data file
file_name = 'PRL_data';
data_file = [file_name '.csv'];

% add first line with variable names only if overall participant number is
% 1
if answer_vect(1) == 1
    % open data file and write first line
    data_file_id = fopen(data_file, 'a');
    fprintf(data_file_id, '%s\n', ['participant_id,', 'group,',...
                                   'per_group_id,', 'handedness,',...
                                   'block,', 'trial,','rewarded,',...
                                   'chosen,', 'correct,', 'fb_given,',...
                                   'contingent,', 'rt,', 'fb_type,'...
                                   'stim_loc_blue,', 'stim_loc_yellow,',...
                                   'lc_trials,', 'lc_correct,',...
                                   'reversal,', 'stim_to_fb,',...
                                   'fb_to_newtrial'] );
    % close data file
    fclose(data_file_id);
end

% define format string for saving data during trials
format_str = ['%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%7.5f,%d,%d,%d,%d,%d,%d,%7.5f,%7.5f\n'];

%--------------------------------------------------------------------------
% balancing the design
%--------------------------------------------------------------------------

% set order of feedback based on the per-group participant number
% participants with odd per-group participant number receive first social
% (1) and then non-social (2) feedback
% participants with even per-group participant number receive first
% non-social (2) and then social (1) feedback

if mod(answer_vect(3), 2) == 0
    FB_TYPE = [2, 1];
else
    FB_TYPE = [1, 2];
end
    
%--------------------------------------------------------------------------
% setting up the Screen window
%--------------------------------------------------------------------------

% open Screen window
% perform tests
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 3);

% choose external screen for presentig experiment
screen_num = max(Screen('Screens'));
[main_window,window_rect] = Screen('OpenWindow', screen_num);

% enable alpha-blending
Screen('BlendFunction', main_window, 'GL_SRC_ALPHA',...
       'GL_ONE_MINUS_SRC_ALPHA');

%--------------------------------------------------------------------------
% settings related to Screen window
%--------------------------------------------------------------------------

% convert images of stimuli to textures
stim_yellow_tex = Screen('MakeTexture',main_window, stim_yellow);
stim_blue_tex = Screen('MakeTexture',main_window, stim_blue);

% convert images of non-social feedback to textures
fb_non_pos_tex = Screen('MakeTexture', main_window, fb_non_pos);
fb_non_neg_tex = Screen('MakeTexture', main_window, fb_non_neg);

% convert images of social feedback to textures
fb_s_pos_m_tex = Screen('MakeTexture', main_window, fb_s_pos_m);
fb_s_neg_m_tex = Screen('MakeTexture', main_window, fb_s_neg_m);
fb_s_pos_f_tex = Screen('MakeTexture', main_window, fb_s_pos_f);
fb_s_neg_f_tex = Screen('MakeTexture', main_window, fb_s_neg_f);

fb_s_pos = [fb_s_pos_m_tex, fb_s_pos_f_tex];
fb_s_neg = [fb_s_neg_m_tex, fb_s_neg_f_tex];

% get Screen center
[x_center,y_center] = RectCenter(window_rect);

% determine white and black color
white = WhiteIndex(screen_num);

% settings for presenting text
Screen('TextFont',main_window, 'Arial');
Screen('TextSize',main_window, 60);
text_color = white;

% define messages to be presented during experiment
message.start = ['Welcome to the experiment!\n',...
                 'Press any key to start.'];
message.end_block_one = ['End of the first block.\n\n',...
                         'You now have the chance to take a break.\n',...
                         'Press any key to start the second block.'];
message.too_slow = 'Too slow!\nPlease respond faster.';

% determine and store possible locations of stimuli on screen

% get size of stimuli
stim_size = size(stim_blue, 1);
% set distance to screen center in y-direction
dist_center_y = 150;
% set distance to screen center in x-direction
dist_center_x = 250;
dist_frame = 30;

% left stimulus location
left_pos_stim = [x_center - (dist_center_x + stim_size),...
            y_center - (stim_size / 2),...
            x_center - dist_center_x,...
            y_center + (stim_size / 2)];
              
% right stimulus location        
right_pos_stim = [x_center + dist_center_x,...
             y_center - (stim_size / 2),...
             x_center + (dist_center_x + stim_size),...
             y_center + (stim_size / 2)];

% top stimulus locaton         
up_pos_stim = [x_center - (stim_size / 2),...
          y_center - (dist_center_y + stim_size),...
          x_center + (stim_size / 2),...
          y_center - dist_center_y];

% bottom stimulus location      
down_pos_stim = [x_center - (stim_size / 2),...
            y_center + dist_center_y,...
            x_center + (stim_size / 2),...
            y_center + (dist_center_y + stim_size)];
        
% matrix for storing all possible stimulus locations
pos_mat_stim = [left_pos_stim; right_pos_stim; up_pos_stim; down_pos_stim];

% determine the position of the frame to highlight the chosen stimulus in a
% given trial based on the possible positions of stimuli

% initialize matrix to store frame positions
pos_mat_frame = zeros(4,4);

% loop over stimulus postions and substract or add frame distance,
% respectively
for i = 1 : length(pos_mat_frame)
    for j = 1 : length(pos_mat_frame)
        if j == 1 || j == 2
            pos_mat_frame(i, j) = pos_mat_stim(i, j) - dist_frame;
        else
            pos_mat_frame(i, j) = pos_mat_stim(i, j) + dist_frame;
        end
    end
end

% dimension of fixation cross (in pixels)
cross_len = 20;
cross_thick = 2;
x_cross = [-cross_len, cross_len, 0, 0];
y_cross = [0, 0, -cross_len, cross_len];

%--------------------------------------------------------------------------
% settings related to timing (of stimulus and feedback)
%--------------------------------------------------------------------------

% determine slack time
slack = Screen('GetFlipInterval',main_window)/2; 

% time for stimulus presentation per trial
stim_dur = 1.5 - slack;

% time for feedback presentation per trial
fb_dur = 2 - slack;

%--------------------------------------------------------------------------
% pre-computation to save compute time during trials
%--------------------------------------------------------------------------

% pre-compute a 240x2 matrix storing the positions of stimuli in each 
% trial (1 = left, 2 = right, 3 = up, 4 = down) by randomly
% drawing values between 1-4 without replacement

stim_pos = zeros(N_BLOCKS, N_TRIALS_MAX, N_STIMULI);

for i = 1:N_BLOCKS
    for j = 1:N_TRIALS_MAX
        stim_pos(i, j, :) = randperm(4, 2);
    end
end

% pre-compute a 240-dim. vector storing the probabilistically determined
% feedback in each trial. Wether the feedback is contingent with the ground
% truth (1) or not (0) is determined based on a bernoulli-distributed
% random variable with p = 0.75.

prob_feedback = zeros(1, N_TRIALS_MAX);

for i = 1:N_TRIALS_MAX
    % very first feedback is contingent
    if i == 1
        prob_feedback(i) = 1;
    else
        prob_feedback(i) = binornd(1, 0.75);
    end
end

%--------------------------------------------------------------------------
% 2. block/trial loop
%--------------------------------------------------------------------------

% set maximal priority for accurate timing
Priority(MaxPriority(main_window));
ListenChar(2); % This suppresses output of keypresses
HideCursor; % This hides the cursor.

% show initial welcome message
Screen('FillRect', main_window, bg_color); %simply draw background
DrawFormattedText(main_window, message.start,...
                  'center', 'center', text_color);
Screen('Flip', main_window);
% wait for keypress to begin experiment
KbStrokeWait;

%--------------------------------------------------------------------------
% enter the block loop
%--------------------------------------------------------------------------

while counter.blocks <= N_BLOCKS
    
    if counter.blocks == 2
        % show initial welcome message
        Screen('FillRect', main_window, bg_color); %simply draw background
        DrawFormattedText(main_window, message.end_block_one,...
                  'center', 'center', text_color);
        Screen('Flip', main_window);
        % wait for keypress to begin experiment
        KbStrokeWait;
    end  
    
    %--------------------------------------------------------------------------
    % enter the trial loop
    %--------------------------------------------------------------------------

    % randomly draw number between 6 and 10 to control first leaning criterion
    lc_trials = randi([6,10]);

    % loop teminates if either 
    % (1) the max. number of reversals has been reached
    % (2) the max. number of trials per block has been reached
    while counter.reversals < N_REVERSAL_MAX && counter.trial_block <=  N_TRIALS_MAX

        % (re-) set indicator of a reversal to 0 (false)
        reversal = 0;
        % initialize reaction time to zero
        rt = 0;

        %----------------------------------------------------------------------
        % present stimuli
        %----------------------------------------------------------------------

        % draw fixation cross
        Screen('DrawLines', main_window, [x_cross; y_cross],...
               cross_thick, white, [x_center, y_center], 2);
        % draw blue stimulus
        Screen('DrawTexture', main_window, stim_blue_tex, [],...
               pos_mat_stim(stim_pos(counter.blocks, counter.trial_block, 1), :));
        %draw yellow stimulus
        Screen('DrawTexture', main_window, stim_yellow_tex, [],...
               pos_mat_stim(stim_pos(counter.blocks, counter.trial_block, 2), :));
        % flip screen and get time stamp
        vbl = Screen('Flip', main_window, [], 1);
        % get time stamp marking the presentation of the feedback (for
        % verification purposes)
        t_stim = tic;

        %----------------------------------------------------------------------
        % get response
        %----------------------------------------------------------------------

        % set loop control variable
        response_made = false;
        % get time stamp for start of response loop (for verification purposes)
        t_resp = tic;

        % loop for (1) duration of stimulus presentation and (2) as long as 
        % no valid response has been given
        while GetSecs < (vbl + stim_dur) && ~response_made

            % check for keypress
            [key_down, secs, key_code] = KbCheck;

            % get index of position of blue stimulus in current trial
            pos_blue = stim_pos(counter.blocks, counter.trial_block, 1);
            % get name of response key that corresponds to blue stimulus in
            % current trial
            key_str_blue = response_keys(pos_blue);
            % get index of position of yellow stimulus in current trial
            pos_yellow = stim_pos(counter.blocks, counter.trial_block, 2);
            % get name of response key that corresponds to yellow stimulu in
            % current trial
            key_str_yellow = response_keys(pos_yellow);

            % make sure that only key presses that actually correspond to one
            % of the stimulus locations in a given trial are considered valid
            if find(key_code) == KbName(convertStringsToChars(key_str_blue))
                % register reaction time
                rt = GetSecs - vbl;
                response_made = true;
                chosen = 1; % blue stimulus is chosen
                % highlight the blue stimulus
                Screen('FrameRect', main_window, hl_color,...
                       pos_mat_frame(pos_blue, :), hl_width);
                Screen('Flip', main_window, [], 0);
                % get time it took to get a response and highlight the chosesn
                % stimulus
                t_highlight = toc(t_resp);
                % wait for the remaining duration of stimulus presentation
                WaitSecs(stim_dur - t_highlight);
            elseif find(key_code) == KbName(convertStringsToChars(key_str_yellow))
                %register reaction time
                rt = GetSecs - vbl;
                response_made = true;
                chosen = 2; % yellow stimulus is chosen
                % highlight te yellow stmulus
                Screen('FrameRect', main_window, hl_color,...
                       pos_mat_frame(pos_yellow, :), hl_width);
                Screen('Flip', main_window, [], 0);
                % get time it took to get a response and highlight the chosesn
                % stimulus
                t_highlight = toc(t_resp);
                % wait for the remaining duration of stimulus presentation
                WaitSecs(stim_dur - t_highlight);
            end
        end

        % proceed further based on whether a valid response has been given or
        % not
        if response_made == true % valid response has been given

            % increment counter for leaning criterion
            counter.lc_trials = counter.lc_trials + 1;
            %check whether it is the first trial of a block
            if counter.trial_block == 1
                % set counter to -1 to compensate for the fact that the first
                % chosen stimulus of a block is always correct (by default)
                counter.lc_correct = -1;
                rewarded(chosen) = 1; % set rewarded stimulus
            end

            if rewarded(chosen) == true % the rewarded stimulus is chosen
                % increment counter for correct trials of the learning
                % criterion
                counter.lc_correct = counter.lc_correct + 1;

                % check wheterh contingent or non-contingent feedback should be
                % presented based on pre-computet Bernoulli-random variable
                if prob_feedback(counter.trial_block) == true
                    % record that positive feedback was given
                    fb_given = 1;
                    % show positive feedback (contingent)
                    if FB_TYPE(counter.blocks) == 1
                        % show social feedback
                        Screen('DrawTexture', main_window, fb_s_pos(randi(2)));
                    elseif FB_TYPE(counter.blocks) == 2
                        % show non-social feedback
                        Screen('DrawTexture', main_window, fb_non_pos_tex);
                    end
                else
                    % record that negative feedback was given
                    fb_given = 0;
                    % show negative feedback (not contingent)
                    if FB_TYPE(counter.blocks) == 1
                        % show social feedback
                        Screen('DrawTexture', main_window, fb_s_neg(randi(2)));
                    elseif FB_TYPE(counter.blocks) == 2
                        % show non-social feedback
                        Screen('DrawTexture', main_window, fb_non_neg_tex);
                    end
                end
            else % non-rewarded stimulus is chosen
                % re-set counter for correct trials of the learning criterion
                counter.lc_correct = 0;

                % check wheterh contingent or non-contingent feedback should be
                % presented based on pre-computet Bernoulli-random variable
                if prob_feedback(counter.trial_block) == true
                    % record that negative feedback was given
                    fb_given = 0;
                    % show negative feedback (contingent)
                    if FB_TYPE(counter.blocks) == 1
                        % show social feedback
                        Screen('DrawTexture', main_window, fb_s_neg(randi(2)));
                    elseif FB_TYPE(counter.blocks) == 2
                        % show non-social feedback
                        Screen('DrawTexture', main_window, fb_non_neg_tex);
                    end
                else
                    % record that positive feedback was given
                    fb_given = 1;
                    % show positive feedback (not contingent)
                    if FB_TYPE(counter.blocks) == 1
                        % show social feedback
                        Screen('DrawTexture', main_window, fb_s_pos(randi(2)));
                    elseif FB_TYPE(counter.blocks) == 2
                        % show non-social feedback
                        Screen('DrawTexture', main_window, fb_non_pos_tex);
                    end
                end
            end
        else % no valid response has been made

            %check whether it is the first trial of a block
            if counter.trial_block == 1
                % set counter to -1 to compensate for the fact that the first
                % chosen stimulus of a block is always the correct one
                counter.lc_correct = -1;
                rewarded(randi([1,2])) = 1; % randomly choose rewarded stimulus
            end
            % set reaction time to NaN, as no valid response has been given
            rt = NaN;
            fb_given = NaN;
            % show 'too slow' message instead of feedback
            Screen('FillRect', main_window, bg_color);
            DrawFormattedText(main_window, message.too_slow, 'center',...
                              'center', text_color);
            % re-set counter for correct trials of learning criterion to zero
            counter.lc_correct = 0;
        end

        % determin whether a reversal should take place after the current trial
        % based on the two counters for the learning criterion
        if counter.lc_trials >= lc_trials && counter.lc_correct >= 3
            % reversal takes place
            reversal = 1;
        end

        %----------------------------------------------------------------------
        % show feedback o 'too slow' message
        %----------------------------------------------------------------------

        % flip screen to show either feedback or 'too slow' message + get time
        % stamp
        vbl = Screen('Flip', main_window);

        % store time that passed between the presentation of stimuli and the 
        % presentation of the feedback (this is just for verifictaion purposes)
        stim_to_fb = toc(t_stim);

        % get time stamp in order to track the time it takes to save the trial
        % data
        t_fb = tic;

        %----------------------------------------------------------------------
        % save trial data to file
        %----------------------------------------------------------------------

        %open file
        data_file_id = fopen(data_file, 'a');
        % enter trial data
        fprintf(data_file_id, format_str, answer_vect, counter.blocks,...
                counter.trial_block, find(rewarded), chosen,...
                (find(rewarded) == chosen), fb_given,...
                prob_feedback(counter.trial_block), rt,...
                FB_TYPE(counter.blocks), stim_pos(counter.blocks, counter.trial_block, 1),...
                stim_pos(counter.blocks, counter.trial_block, 2), lc_trials,...
                counter.lc_correct, reversal, stim_to_fb, fb_to_newtrial);

        % close data file
        fclose(data_file_id);

        %----------------------------------------------------------------------
        % increment counter varibles
        %----------------------------------------------------------------------

        if reversal == 1
            counter.reversals = counter.reversals + 1;
            rewarded = ~rewarded; % invert stimulus-reward relations
            % draw number of trials for next learning criterion
            lc_trials = randi([6,10]);
            % reset counter for learning criterion
            counter.lc_trials = 0;
            counter.lc_correct = 0;
        end

        %increase block trial counter
        counter.trial_block = counter.trial_block + 1;
        % get time it took to save data
        t_save_data = toc(t_fb);

        % present feedback for the remining time of the duration of feedback
        % presentation - the time it took to save the trial data
        WaitSecs(fb_dur - t_save_data);

        % store time that passed between the presentation of feedback and the 
        % end of the trial (this is just for verifictaion purposes)
        fb_to_newtrial = toc(t_fb);

    end
    
    % re-set trial counter to their initial values
    counter.trial_block = 1;
    counter.reversals = 0;
    counter.lc_trials = 0;
    counter.lc_correct =0;
    % increment block counter
    counter.blocks = counter.blocks + 1;
end
% close Screen
Screen('CloseAll')

% Clean up
ListenChar(0);
Priority(0);
ShowCursor;
fclose all;
clear;

%--------------------------------------------------------------------------
catch err
    rethrow(err);
    sca;
end
end

