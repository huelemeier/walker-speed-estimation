# walker-speed-estimation
Obersevers encounter a group of point-light walkers. Walkers' limb motion combined with walking speed varies. Participant's task is so reproduce the walking speed of the crowd.



https://user-images.githubusercontent.com/69513270/220873695-ce75bd3f-b2b9-43d7-b538-5b64a985bd64.mov


## Technical requirements and set-up
These scripts are optimized for MatLab 2021b with Psychtoolbox (http://psychtoolbox.org/download.html) and OpenGL add-on libraries from the Psychtoolbox. So what needs to be installed on you computer are Matlab and Psychtoolbox. 

## Set-up
Download all the files and add them to your Matlab folder. Within your Matlab folder, create a subfolder names "functions". Move the scripts "geFrustum" and "genscramwalker" to this subfolder. 

## Explanation of the scripts
- github_walker_velocity.m: This is the main script creating the scene and running the experiment.
- getFrustum.m: this script generates frustum data. The main script uses this script to do some calculations. No need to adapt this script.
- genscramwalker.m: This script generates scrambled walker by randomly replacing the position of points. Motion trajectories are kept unchanged.
- extrapolatewalkerdata.m: we extrapolated walker motion data (sample_walker3) to generate slightly slower and faster articulating walkers. The matching translation speed is generated in the main script. You do not need to do anything with that script. If you want to, you can extrapolate your own walker motion speeds with that script. The main script does not use this script.
- sample_walker3: motion data for point_light walker with normal speed
- sample_walker_0.8: motion data for point_light walker with slower speed
- sample_walker_1.2: motion data for point_light walker with faster speed
- gravel.rgb.tiff: ground type gravel

## Run the script
Open the script in Matlab and click on 'run'. Matlab automatically requires your input in the command line, and subsequently asks questions. Enter the participant id, session number, and further information about the scene (grond, motion parallax, walkers at different depth) subsequently. When done, Psychtoolbox automatically opens a window and runs the script in that window. 

You will see the stimulus presentation. After each presentation, you are required to estimate the walkers' average walking speed. For this purpose, a single walker appears. You can modify its walking speed by moving the mouse horizontally. Vertical movements switch the motion direction. Confirm your answer by pressing the left mouse buttom. Subsequently, the next trial starts. The script finishes when all trials are done.

## Technical information about the scene
![Overview experimental parameters](https://github.com/huelemeier/walker-speed-estimation/assets/69513270/e1bbf9a8-e5a8-4f91-a100-9beb89c23290)

## Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originate from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). The walkers face either collectively to the left (-90°) or right (90°). 

<img width="1920" alt="background point-light walker" src="https://user-images.githubusercontent.com/69513270/183389265-f4348d64-6e4a-4a72-94c2-f70c2190b449.png">

#### Walker type
You can choose between a normal walker, an inverted, and a scrambled walker. Scrambling relocates the point positions but keeps the motion trajectories the same. Thus, the biological form is destroyed but the biological motion trajectories are still present. Comparing data for normal and scrambled walker types enables us to study specific effects for biological motion. Inverted walkers are created by rotating normal walkers by 180° around the z-axis and harmonising their facing direction so the walkers appeared upside down and translate in the direction they are facing. Inversion inhibits the processing of a point-light walker’s form. Comparing data for normal, inverted and scrambled walker types enables us to study specific effects for biological motion. 
Walker type is programmed as blocking variable. In other words, you determine the walker type for the whole stimulus presentation. The next time you run the script, you can change the walker type.


https://user-images.githubusercontent.com/69513270/182679840-846a7f2e-ded9-424b-aa22-48a96b42a7ed.mov



## Walker conditions
To decisively explore the influence of the components of biological motion on heading perception from optic flow analysis, we designed four conditions: static, natural locomotion, only translation, and only articulation.
In the static condition, the walkers resemble static figures. Here, the walkers kept their posture at a fixed position. The natural locomotion condition presents the walkers naturally moving through the world and swinging their limbs. This condition combines both elements of biological motion. The only translation condition displayed walkers sliding through the world without any limb motion. So the walkers resembles figure skaters moving in the direction they were facing. Conversely to the only translation condition, walkers in the only articulation condition moved their limbs without physical translation. This condition is imaginable as pedestrians on a treadmill. 
Note these conditions are autamtically displayed in randomized order.

## Articulation speed
In real-life scenarios, humans differ in their translation, and thus, articulation speed (Masselink & Lappe, 2015). To keep the scene close to reality, we manipulate the articulation and translation speed of the walkers. The original motion-tracking data have a matching translation speed of 0.013 (0.6m/s.). By linear interpolation (see Matlab Skript extrapolatewalkerdata.m), we create two more motion files with either 0.8 (slower) or 1.2 times (faster) the original articulation speed. Translation speed is adjusted accordingly. Randomized position in depth combined with a randomized starting position in the gait cycle let the crowd appear naturally.


## Motion parallax and independent optic flow
You can change the degree of depth information available in the scene If motion parallax is selected, the walkers stay at different depths in the room. While some of the group's position ranged between 7 and 9 m, the other ones are twice as far away, i.e., 14 to 18 m in depth. We adjust the walkers' size and points according to their positioning in the environment. Due to the positioning of the walkers in space, the scene is designed to induce motion parallax cues (Gibson, 1950).

You can also add a grey gravel ground to the scene. The ground provides independent optic flow, and thus, independent self-motion information. If no ground is visible, the points of the walkers combine biological motion and simulated self-motion. Here are some example stimuli with increasingly more depth and self-motion information:

## Experimental scene
The experimental world spans over 20 m scene depths. We placed a visible ground plane at eye height (1.60 m). Its appearance is structured (gravel). The gravel ground provides independent optic flow from the simulated observer motion. The ground is programmed as blocking variable. In other words, you determine the ground appearance (black vs gravel) for the whole stimulus presentation. The next time you run the script, you can change the ground. 

![gravel rgb](https://user-images.githubusercontent.com/69513270/183389233-74622d28-d2d0-4046-8fbd-2df1c1163270.png)

## Velocity estimation // Procedure
Participants' task is to reproduce the walker velocity (not self-motion velocity) by adjusting the translation speed of a single walker. Moving the computer mouse along the horizontal line changes the translation speed. Translation speed can also be set to 0. If the walker disappears from the viewing frustum, the script automatically relocates it to the viewing frustum. 


https://user-images.githubusercontent.com/69513270/220876935-5cf5cb2d-c025-42c1-950d-87bc50e7eca6.mov

