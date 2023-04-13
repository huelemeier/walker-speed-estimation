% Participants should estimate the crowd's translation speed

clear all; 
addpath('functions')
rng('shuffle');


ID = input('Enter subject ID '); %Input subject ID, this will also be the file name of the outsput
session = input('Enter session number '); %Input session number, this will also be the file name of the output
practice = input('Practice run [1] Experimental run [0] '); %input whether this is a practice run or not
walker_type = 1;%input('Enter walker type [0 = scrambled, walker] [1 = normal walker] [2 = inverted walker] '); %input walker type
gravel = input('black ground [0] or gravel [1]? ');  %enter whether a ground is visible or not.
group_distance_z = input('Enter group distance [0 = no distance // no motion parallax] [1 = distance // motion parallax] '); % if 1: this line of code induces motion parallax. if 0: walkers are placed at the same depth.

if group_distance_z == 1
    a = input('Enter amount of walkers in the distance (usually 4 of 8) '); %if motion parallax should be induced, you can enter de amount of walkers placed at another depth. 
else
    a = 0;
end

show_true_heading = false; % if true, the heading direction is displayed

%% 
observer_translating = 1;%input('Observer translating [1] or static [0]? ');
eye_height = 1.6;

% GL data structure needed for all OpenGL demos:
global GL;

% Is the script running in OpenGL Psychtoolbox? Abort, if not.
AssertOpenGL;

% Restrict KbCheck to checking of ESCAPE key:independent_variable_2
KbName('UnifyKeynames');

%Screen('Resolution',0,800,600) % Umrechnung: (/1980*600) mousex Positionen
Screen('Preference','Verbosity',1); 


% Find the screen to use for display:
screenid=max(Screen('Screens'));
stereoMode = 0;
multiSample = 0;

Screen('Preference', 'SkipSyncTests', 1);


%-----------
% Parameters
%-----------

nframes = 120;  %duration of stimulus
numwalkers = 8; %number of walkers 8

d=20;   %scene depth

hdrange = 12; %heading range in degrees


%set up conditions and trial sequence
independent_variable_sets = {[0 1], [0 1], [-90 90], [group_distance_z] [0.013 0.0104 0.0156]}; % conditions: [translating]  [articulating] [mean walker facing] [artspeed]
[independent_variable_1 independent_variable_2 independent_variable_3 independent_variable_4 independent_variable_5] = ndgrid(independent_variable_sets{:}); 
conditions = [independent_variable_1(:) independent_variable_2(:) independent_variable_3(:) independent_variable_4(:) independent_variable_5(:)];
trials = conditions; %one trial block conveys all stimulus combinations (conditions)
trials = repmat(trials, 10, 1); %we extend trials to the desired number of consecutive experimental sessions. 
trials = trials(randperm(length(trials)),:); %random permutation of all stimulus combinations generated at "conditions"

if practice
    trials = repmat(conditions, 1,1);
    trials = trials(randperm(length(trials)),:);
end


% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL;

PsychImaging('PrepareConfiguration');
% Open a double-buffered full-screen window on the main displays screen.
[win, winRect] = PsychImaging('OpenWindow', screenid, 0, [0 0 800 600], [], [], stereoMode, multiSample); %
[win_xcenter, win_ycenter] = RectCenter(winRect);
xwidth=RectWidth(winRect);
yheight=RectHeight(winRect);

screen_height=198; %physical height of display in cm
screen_width=248; %physical width of display in cm
screen_distance=100; %physical viewing distance in cm
screen_distance_in_pixels=xwidth/screen_width*screen_distance; %physical viewing distance in pixel


HideCursor;
Priority(MaxPriority(win));

% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':
Screen('BeginOpenGL', win);

% Get the aspect ratio of the screen:

% Set viewport properly:
glViewport(0, 0, xwidth, yheight);

% Setup default drawing color to yellow (R,G,B)=(1,1,0). This color only
% gets used when lighting is disabled - if you comment out the call to
% glEnable(GL.LIGHTING).
glColor3f(1,1,0);

% Setup OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources,
% GL.LIGHT0, ..., GL.LIGHT7
glEnable(GL.LIGHT0);

% Enable alpha-blending for smooth dot drawing:
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glEnable(GL.DEPTH_TEST);

% Set projection matrix: This defines a perspective projection,
% corresponding to the model of a pin-hole camera - which is a good
% approximation of the human eye and of standard real world cameras --
% well, the best aproximation one can do with 3 lines of code ;-)
glMatrixMode(GL.PROJECTION);
glLoadIdentity;
% Field of view = 2*atan(H/2N) where H is monitor height and N is viewing distance. Objects closer than
% 0.1 distance units or farther away than 50 distance units get clipped
% away, aspect ratio is adapted to the monitors aspect ratio:
gluPerspective(89, xwidth/yheight, 0.5, d);


% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)...
glLightfv(GL.LIGHT0,GL.POSITION,[ 1 2 3 0 ]);

% Set background clear color to 'black' (R,G,B,A)=(0,0,0,0):
glClearColor(0,0,0,0);

% Clear out the backbuffer: This also cleans the depth-buffer for
% proper occlusion handling: You need to glClear the depth buffer whenever
% you redraw your scene, e.g., in an animation loop. Otherwise occlusion
% handling will screw up in funny ways...
glClear(GL.DEPTH_BUFFER_BIT);

% Finish OpenGL rendering into PTB window. This will switch back to the
% standard 2D drawing functions of Screen and will check for OpenGL errors.

vprt1 = glGetIntegerv(GL.VIEWPORT);
Screen('EndOpenGL', win);

% Show rendered image at next vertical retrace:
Screen('Flip', win);

fps=Screen('FrameRate', win);   %use PTB framerate if its ok. otherwise....
if fps == 0
    flip_count = 0;                 %rough estimate of the frame rate per second
    timerID=tic;                    %I did this because for some reson the PTB estimate wasn't working
    while (toc(timerID) < 1)        %pretty sure this is due to the mac LCD monitors
        Screen('Flip',win);
        flip_count=flip_count+1;
    end
    frame_rate_estimate=flip_count;
    fps = frame_rate_estimate;
end

tspeed=1.1/fps;  %speed which the observer translates through the environment 

if observer_translating==0
    tspeed=0;
end


%first stuff the observer sees when they start the experiment

[~, ~, buttons1]=GetMouse(screenid);
Screen('TextSize',win, 36);
white = WhiteIndex(win);

while ~any(buttons1)
    Screen('DrawText',win, 'Click the mouse to begin the experiment.',win_xcenter-320,win_ycenter,white);
    Screen('DrawingFinished', win);
    Screen('Flip', win);
    [~, ~, buttons1]=GetMouse(screenid);
end




for trial = 1:length(trials) 
    
    % set up conditions for this trial
    translating        = trials(trial,1);
    articulating       = trials(trial,2);
    mean_walker_facing = trials(trial,3);
    group_distance_z   = trials(trial,4);
    artspeed           = trials(trial,5);
   
    walker_facing = mean_walker_facing * ones(1,numwalkers);
    

    %% set up walker

    if artspeed == 0.013
        origin_directory = pwd;
        FID = fopen('sample_walker3.txt');    %open walker data file
        sample_walker_1 = fscanf(FID,'%f');      %read into matlab
        fclose(FID);
        sample_walker_1=reshape(sample_walker_1,3,[]).*0.00001;  %order and scale walker array
        walker_array = sample_walker_1; % normal limb articulation

    elseif artspeed == 0.0104
        % load in extrapolated data:
        FID = fopen('sample_walker_exp_0.8.txt');    %open walker data file
        sample_walker_0_8 = fscanf(FID,'%f');      %read into matlab
        fclose(FID);
        sample_walker_0_8=reshape(sample_walker_0_8,3,[]);  %order and scale walker array
        walker_array = sample_walker_0_8; % slower limb articulation

    elseif artspeed == 0.0156
        FID = fopen('sample_walker_exp_1.2.txt');    %open walker data file
        sample_walker_1_2 = fscanf(FID,'%f');      %read into matlab
        fclose(FID);
        sample_walker_1_2=reshape(sample_walker_1_2,3,[]);  %order and scale walker array
        walker_array = sample_walker_1_2; % faster limb articulation

    end


    
    
    %% Draw a single dynamic walker so that observers estimate facing - this walker is always drawn the same way
    % set up conditions for this trial
    translating_lastframe        = 0; %um Fehler in der Ausgabe zu vermeiden, heißen die Variablen "_lastframe".
    articulating_lastframe       = articulating;

        
    %% set walker stuff

    if walker_type == 0
        walker_array = genscramwalker(walker_array,16);
    end

    clear xi
    %randomly select starting phase
    numorder=(1:16:length(walker_array));
    xi(1:numwalkers)=numorder(randi([1 length(numorder)],1,numwalkers));
%          xi(1:numwalkers)=1; % Do this so that all walkers start with the same
    %phase

    %% set walker facing and translation   

    % initialize walker translation state
    translate_walker= zeros(1,numwalkers);

    % set translation speed
    if translating
        translation_speed = artspeed;
    else
        translation_speed = 0;
    end
    
    %% adjustments for group distance
    if group_distance_z == 0;
        distance = 1;
    elseif group_distance_z == 1;
        distance = 2;
    end
    
    %generate walker random starting positions
    [walkerX,walkerY,walkerZ] = CreateUniformDotsIn3DFrustum(numwalkers,56,xwidth/yheight,0.5,d,1.4); %generate walker positions
    
    walkerX = linspace(-3,3,numwalkers)+2*(rand(1,numwalkers)-0.5);
    walkerZ = -8+2*(rand(1,numwalkers)-0.5);
    
    %a = randi(numwalkers/2-1); %wenn random Anzahl verschoben wird, muss
    %das hier entkommentiert werden
    if a == 0
        walker_distance = walkerZ;
        walkerindex = (1:numwalkers);
    else
        walker_distance = walkerZ;
        walker_distance(1:a)= walker_distance(1:a)*distance;
        walkerindex = randperm(numel(walkerZ),numwalkers);
        walkerZ = walker_distance(walkerindex);
    end
    
    %% set up ground plane    
    myimg = imread('gravel.rgb.tiff');
    mytex = Screen('MakeTexture', win, myimg, [], 1);
    
    % Retrieve OpenGL handles to the PTB texture. These are needed to use the texture
    % from "normal" OpenGL code:
    [gltex, gltextarget] = Screen('GetOpenGLTexture', win, mytex);   


    
    %% set heading stuff
    Screen('BeginOpenGL',win)
    glLoadIdentity
    viewport=glGetIntegerv(GL.VIEWPORT); %viewport
    modelview=glGetDoublev(GL.MODELVIEW_MATRIX); %modelview matrix
    projection=glGetDoublev(GL.PROJECTION_MATRIX); %(vectorized) projection matrix

    heading_deg = hdrange*(2*rand()-1);
    heading_world = -tand(heading_deg)*d;

    translate_observer=0; %start at zero

    % shift crowd to center on screen
    walkerX = walkerX - tand(heading_deg)*8;

    %% view frustum for culling used later

    glPushMatrix
    glLoadIdentity

    glRotatef(-heading_deg,0,1,0)

    proj=glGetFloatv(GL.PROJECTION_MATRIX); %projection matrix
    modl=glGetFloatv(GL.MODELVIEW_MATRIX);

    glPopMatrix

    modl=reshape(modl,4,4);
    proj=reshape(proj,4,4); %perspektivische Projektionsmatrix

    frustum=getFrustum(proj,modl);
    fov = atand((5.84/6.5))*2;%60.9034;% %41.9397*2;
    
    Screen('EndOpenGL', win)

    %% Animation loop


    for i = 1:nframes;

        %abort program early
%         exitkey=KbCheck;
%         if exitkey
%             clear all
%             return
%         end
        

        Screen('BeginOpenGL',win);
        glClear(GL.DEPTH_BUFFER_BIT)
        glLoadIdentity

        gluLookAt(0,0,0,heading_world,0,-d,0,1,0); %set camera to look without rotating. normally just use thi
        glTranslatef(0,0,translate_observer) %translate scene
        
           if gravel == 1
            %draw texture on the ground
            glColor3f(0.6,0.6,0.6)
            
            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);
            
            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);
            
            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);
            
            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);
            
            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height-0.1, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height-0.1, -200);
            glEnd();
            
            
            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
            
           end
        
        %% PLW code

        for walker = 1:numwalkers %cycle through each walker. at this stage i draw each walker singularly. 

            if xi(walker)+16+12 > length(walker_array) % <--this is the size of the scrambled walker data file
                xi(walker)=1;
            end

            %get walker array for frame
            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12);

            if articulating
                xi(:,walker) = xi(:,walker) + 16;
            end

            %% point drawing

            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix
            glTranslatef(walkerX(walker),walkerY(walker),walkerZ(walker)); %move the points to the right location


            %do facing rotation and walking translation
            glRotatef(walker_facing(walker)-90,0,1,0);
            glTranslatef(translate_walker(walker),0,0); 
            if translating
                translate_walker(walker)=translate_walker(walker) + translation_speed;
            end

            %inverted walkers
            if walker_type == 2
                glRotatef(180,0,0,1)
                glTranslatef(0,-1.4,0)
            end

            glColor3f(1.0,1.0,1.0)
           
            % this if statements adapts the point size of each walker
            % depending on its distance (walkerindex)
            smallpoint=(1:a);
            index = ismember(walkerindex(walker), smallpoint);
            if index == 1
                glPointSize(4)
            else
                glPointSize(7)
            end
            
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points

            glPopMatrix

        end

        % show true heading for testing
        if show_true_heading
            heading_point = [0,0,-d/2]';

            %these variables set up some point drawing
            nrdots=size(heading_point,2);
            nvc=size(heading_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, heading_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.9,0.0,0.0)
            glPointSize(4)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end    

        Screen('EndOpenGL',win);

        translate_observer=translate_observer+tspeed; % update translated position

        Screen('Flip', win);

    end    %end animation loop

  
    %this loop redraws the static final frame and waits for a user response
    buttons = 0;   
%     SetMouse(-1 + (1-(-1))*rand()*win_xcenter,win_ycenter);   %set the mouse at a random position relative to the middle of the screen

%% set walker translation

    % initialize walker translation state
    translate_walker = zeros(1,numwalkers); %start at zero velocity

    while ~buttons

        [mx, my, buttons] = GetMouse(screenid); %Returns the current (x,y) position of the cursor and the up/down state of the mouse buttons.
        
        %observer sets motion speed of the ground via mouse
        tspeed_walker = mx/50000;        


        %% set scene and ground

        Screen('BeginOpenGL',win);

        glMatrixMode(GL.MODELVIEW)
        glLoadIdentity
        glClear(GL.DEPTH_BUFFER_BIT)
        
        %set camera looking position and location
        gluLookAt(0,0,0,heading_world,0,-d,0,1,0);
        glTranslatef(0,0,translate_observer-tspeed);
            
        
         if gravel == 1
            %draw texture on the ground
            glColor3f(0.6,0.6,0.6)
            
            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);
            
            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);
            
            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);
            
            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);
            
            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height-0.1, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height-0.1, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height-0.1, -200);
            glEnd();

            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
         end



         %% redraw walkers

         walker_point = [0, -1.4, -6.5];

         walkerX(1) = walker_point(1);
         walkerY(1) = walker_point(2);
         walkerZ(1) = walker_point(3);

        for walker = 1

            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12);
           
            if xi(walker)+16+12 > length(walker_array) % <--this is the size of the scrambled walker data file
                xi(walker)=1;
            end

            if articulating
                xi(:,walker) = xi(:,walker) + 16;
            end

            r_mat = [cosd(walker_facing(walker)), 0, -sind(walker_facing(walker));...
                 0,                                   1, 0;...
                 sind(walker_facing(walker)),  0, cosd(walker_facing(walker))];


        %% frustum culling to reposition lost walkers

         %get point
         p = [walkerX(walker),walkerY(walker),walkerZ(walker)+translate_observer]+[0,0,translate_walker(walker)]*r_mat;
         walkerDist = -p(3);

         alpha = fov/2 + heading_deg;
         beta = fov/2 - heading_deg;
         s1=tand(alpha)*(-6.5);
         s2=tand(beta)*(-6.5);

         %normalize
         p=p/norm(p);

         %test and cull
         if  frustum(1,1)*p(1) + frustum(1,2)*p(2) + frustum(1,3)*p(3) + frustum(1,4) < 0 || frustum(2,1)*p(1) + frustum(2,2)*p(2) + frustum(2,3)*p(3) + frustum(2,4) < 0 % frustum(5,1)*p(1) + frustum(5,2)*p(2) + frustum(5,3)*p(3) + frustum(5,4) < 0 ||

             walkerDist = -6.5; % no need to compensate for observer motion depth since there is no observer motion here.

             if tspeed_walker > 0 & walker_facing(walker) == -90 %|| tspeed_walker > 0 & walker_facing(walker) == 90
                 translate_walker(walker) = s1;%-5.84 %abs(s2)*(-1)%-6.1707;%-5.84;%-position; %-5.84 bis 9.683 --> s2?
            
             elseif tspeed_walker > 0 & walker_facing(walker) == 90
                 translate_walker(walker) = s2;%
             
             end

         end


            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL functscaion to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix
            glTranslatef(walkerX(walker), -1.4, -6.5); %move the points to the right location
            glRotatef(translate_walker(walker)-heading_deg,0,-1,0)

            % do facing rotation and walking translation
            glRotatef(walker_facing(walker)-90,0,1,0);
            glTranslatef(translate_walker(walker),0,0);


            %inverted walkers
            if walker_type == 2
                glRotatef(180,0,0,1)
                glTranslatef(0,-1.4,0)
            end

            glColor3f(1.0,1.0,1.0)
            glPointSize(7)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points

            glPopMatrix

        end


        if show_true_heading
            heading_point = [0,0,-d/2]';

            %these variables set up some point drawing
            nrdots=size(heading_point,2);
            nvc=size(heading_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, heading_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.9,0.0,0.0)
            glPointSize(4)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end    

        
        Screen('EndOpenGL',win);
        translate_walker=translate_walker+tspeed_walker; % update translated position



        %% get mouse and heading position and calculate heading error
        if any(buttons)
            [mx, ~, ~] = GetMouse(screenid);
        end           

        Screen('Flip', win);

    end


    Screen('Flip',win);
    WaitSecs(0.5);



    %output 

    output(trial,1) = ID;
    output(trial,2) = session;
    output(trial,3) = trial;
    output(trial,4) = walker_type;
    output(trial,5) = translating;
    output(trial,6) = articulating;
    output(trial,7) = mean_walker_facing;
    output(trial,8) = heading_deg; %true observer heading
    output(trial,9) = mx; %cursor  x-axis nach dem die Kruve gezeichent wird. 
    output(trial,10) = gravel; %1 = gravel, 0 = black ground
    output(trial,11) = group_distance_z;
    output(trial,12) = a;
    output(trial,13) = gravel;
    output(trial,14) = artspeed;
    output(trial,15) = tspeed_walker; %estimated walker velocity
    output(trial,16) = translation_speed; % actual translation speed of the walkers

    
    



    if ~practice
        cd('data');
        dlmwrite([num2str(ID), '_',num2str(walker_type), '_',num2str(session), '_walker_velocity.txt'],output,'\t');
        cd(origin_directory)

    end

end
 


%% Done. Close screen and exit:c
Screen('CloseAll');

