# walker-speed-estimation
Obersevers encounter a group of point-light walkers. Walkers' limb motion combined with walking speed varies. Participant's task is so reproduce the walking speed of the crowd.


## Technical requirements and set-up
These scripts are optimized for MatLab 2021b with Psychtoolbox (http://psychtoolbox.org/download.html) and OpenGL add-on libraries from the Psychtoolbox. So what needs to be installed on you computer are Matlab and Psychtoolbox. 

## Set-up
Download all the files and add them to your Matlab folder. Within your Matlab folder, create a subfolder names "functions". Move the script "geFrustum" to this subfolder. 

## Explanation of the scripts
- github_background_illusion.m: This is the main script creating the scene. 
- getFrustum.m: this script generates frustum data. The main script uses this script to do some calculations. No need to adapt this script.
- extrapolatewalkerdata.m: we extrapolated walker motion data (sample_walker3) to generate slightly slower and faster articulating walkers. The matching translation speed is generated in the main script. You do not need to do anything with that script. If you want to, you can extrapolate your own walker motion speeds with that script. The main script does not use this script.
- sample_walker3: motion data for point_light walker with normal speed
- sample_walker_0.8: motion data for point_light walker with slower speed
- sample_walker_1.2: motion data for point_light walker with faster speed
- gravel.rgb.tiff: ground type gravel

## Technical information about the scene
## Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originate from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). The walkers face either collectively to the left (-90°) or right (90°). 

<img width="1920" alt="background point-light walker" src="https://user-images.githubusercontent.com/69513270/183389265-f4348d64-6e4a-4a72-94c2-f70c2190b449.png">

## Walker conditions
To decisively explore the influence of the components of biological motion on heading perception from optic flow analysis, we designed four conditions: static, natural locomotion, only translation, and only articulation.
In the static condition, the walkers resemble static figures. Here, the walkers kept their posture at a fixed position. The natural locomotion condition presents the walkers naturally moving through the world and swinging their limbs. This condition combines both elements of biological motion. The only translation condition displayed walkers sliding through the world without any limb motion. So the walkers resembles figure skaters moving in the direction they were facing. Conversely to the only translation condition, walkers in the only articulation condition moved their limbs without physical translation. This condition is imaginable as pedestrians on a treadmill. 
Note these conditions are autamtically displayed in randomized order.

## Experimental scene
The experimental world spans over 20 m scene depths. We placed a visible ground at eye height (1.60 m). Its appearance is structured (gravel). The gravel ground provides independent optic flow from the simulated observer motion. The ground is programmed as blocking variable. In other words, you determine the ground appearance (black vs gravel) for the whole stimulus presentation. The next time you run the script, you can change the ground. 

![gravel rgb](https://user-images.githubusercontent.com/69513270/183389233-74622d28-d2d0-4046-8fbd-2df1c1163270.png)
