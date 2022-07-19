;global variables used for the simulation of gameplay
globals[
  radius
  points
  user-who
  lives
]

;the player will control the user
breed[users user]

;lasers for user to shoot
breed[lasers laser]

;easy galaga (enemy)
breed[galagas-e galaga-e]

;hard galaga (enemy)
breed[galagas-h galaga-h]



galagas-e-own[
  attack-mode?       ;when the galaga attacks the user
  my-home            ;placement for initialization and when not in attack-mode?
  angle              ;movement for initialization to form circle
  moved?             ;movement for initilization to create staggered start times
]

galagas-h-own[
  attack-mode?       ;when the galaga attacks the user
  my-home            ;placement for initialization and when not in attack-mode?
  angle              ;movement for initialization to form circle
  moved?             ;movement for initilization to create staggered start times
]

patches-own[
  occupied?          ;for the home patches
  easy-home?         ;patch coordinates for easy galagas
  hard-home?         ;patch coordinates for hard galagas
  danger?            ;danger zone patches
]

turtles-own[
  galaga?            ;to create an umbrella breed for all galagas
  hard-galaga?       ;to label a turtle as an hard galaga
  easy-galaga?       ;to label a turtle as an easy galaga
  hit-left-wall?     ;to determine whether the left-most galaga has reached the left-most barrier for back and forth movements
  hit-right-wall?    ;to determine whether the right-most galaga has reached the right-most barrier for back and forth movements
  moving-left?       ;to determine if the galagas should move left for back and forth movements
  moving-right?      ;to determine if the galagas should move right for back and forth movements
]

;==================FINAL GAMEPLAY=================

;observer context
;simulates gameplay until the user kills all galagas or loses all lives.
to go
  ;if condition assures that the game continues to function as long as there exists a user AND an enemy
  ifelse count users > 0 and count turtles with [galaga?] > 0[
    laser-progress      ;user shooting
    level-choose        ;calls appropriate game difficulty
    galaga-points        ;galaga dies if a laser succesfully hits it
  ]
  [stop]                ;halts game play once any of above conditions are not met
end

;observer context
;user selects desired difficulty of gameplay
to level-choose
  if level = "1"[
    galaga-gameplay-1    ;easy gameplay
  ]
  if level = "2"[
    galaga-gameplay-2    ;medium gameplay
  ]
  if level = "3"[
    galaga-gameplay-3    ;hard gameplay
  ]
end

;===============INITIAL SETUP================
to setup
  ca
  reset-ticks
  create-background           ;creates space background
  create-formations           ;creates invisible home patches for galagas
  danger-zone                 ;creates a danger zone for the hard galaga
  create-player               ;creates user controlled avatar
  create-easy                 ;creates easy galagas and spawns them into their homes via their respective spawn movement
  create-hard                 ;creates hard galagas and spawns them into their homes via their respective spawn movement
  initialize-attacks          ;initially sets turtles labeled as galagas to attack...is necessary to maintain a continous attack gameplay
  set points 0                ;resets point tally to 0
  set radius max-pycor / 3    ;sets the radius used for galaga's circular movement
end


;observe context
;initializes two random galagas to attack user
;it is necessary to maintain attack gameplay
to initialize-attacks
  ask one-of galagas-e[
    set attack-mode? true
  ]
  ask one-of galagas-h[
    set attack-mode? true
  ]
end

;observer context
;creates user user-who for the player to control
to create-player
  create-users 1[
    set lives 3
    set shape "player"          ;own developed shape
    set ycor int(min-pycor + 1) ;always remains at the same y-coordinate
    set heading 0
    set size 2.5
    not-galaga                  ;sets false booleans for non-galaga breeds
    set user-who [who] of self  ;save who number of user for later use
  ]
end

;observer context
;creates a space background
to create-background
  create-turtles 100[
    set color white
    set size random-float 0.3
    set shape "circle"
    setxy random-xcor random-ycor
    not-galaga                 ;sets false booleans for non-galaga breeds
  ]
  create-turtles 75 [
    set color yellow
    set size random-float 0.7
    set shape "star"
    setxy random-xcor random-ycor
    not-galaga                 ;sets false booleans for non-galaga breeds
  ]
end


;=================LEVELS===============
;;GAMEPLAY FOR GALAGA MOVEMENTS
;galagas are randomly assigned attack-mode? boolean
;those that are not assigned attack-mode should move back and forth across the screen in their formation
;galagas that are assigned attack-mode should randomly attack the user according to their specified behavior

;observe context
;easy gameplay
to galaga-gameplay-1
  ;set booleans of attack-mode
  if count users > 0 [
    ;assigns the attack-mode booleans to a random set of galagas per round
    if ticks mod 75 = 0 [   ;every 75 ticks, there will be a new round of galagas attacking the user
      if any? galagas-e[
        ask one-of galagas-e[  ;one easy galaga per round
          set attack-mode? true
        ]
      ]
      if any? galagas-h [
        ask one-of galagas-h[   ;one hard galaga per round
          set attack-mode? true
        ]
      ]
    ]
    ask turtles with [galaga?][
      ifelse attack-mode?[
        if easy-galaga? [     ;small discretized movement to form a figure-8 attack at the user
          update-angle-easy
          easy-upper-attack
          easy-lower-attack
        ]
        if hard-galaga? [   ;small discretized movement to form a s-shape then direct attack at the user
          update-angle-hard
          hard-upper-attack
          hard-lower-attack
        ]
      ]
      [back-and-forth] ;if they are not in attack mode, they should move back and forth across the screen
    ]
    tick ;represents one small discretized movement according to the galaga's behavior at the time
  ]
end

;observer context
;game play increases difficulty of easy galagas but not hard galagas
;difficutly is increased by decreasing the wait time between easy galaga attacks
to galaga-gameplay-2
  ;set booleans of attack-mode
  if count users > 0 and count turtles with [galaga?] > 0 [
    ;assigns the attack-mode booleans to a random set of galagas per round
    if ticks mod 60 = 0 [ ;every 60 ticks, there will be a new round of galagas attacking the user
      if any? galagas-e[
        ifelse count galagas-e > 1[
          ask n-of 2 galagas-e[  ;two easy galagas per round
            set attack-mode? true
          ]
        ]
        [
          ask one-of galagas-e[
            set attack-mode? true
          ]
        ]
      ]
      if any? galagas-h [
        ask one-of galagas-h[  ;one hard galaga per round
          set attack-mode? true
        ]
      ]
    ]
    ;overarching ask statement to create simultaneous movement based on their boolean value
    ask turtles with [galaga?][
      ifelse attack-mode?[
        if easy-galaga? [   ;small discretized movement to form a figure-8 attack at the user
          update-angle-easy
          easy-upper-attack
          easy-lower-attack
        ]
        if hard-galaga? [  ;small discretized movement to form a s-shape then direct attack at the user
          update-angle-hard
          hard-upper-attack
          hard-lower-attack
        ]
      ]
      [back-and-forth] ;if they are not in attack mode, they should move back and forth across the screen
    ]
    tick ;represents one small discretized movement according to the galaga's behavior at the time
  ]
end

;observer context
;gameplay increases the difficutly of both easy and hard galagas
;difficulty is increased by decreasing the wait time to attack between both easy and hard galagas
to galaga-gameplay-3
  ;set booleans of attack-mode
  if count users > 0 and count turtles with [galaga?] > 0 [
    ;assigns the attack-mode booleans to a random set of galagas per round
    if ticks mod 40 = 0 [ ;every 40 ticks, there will be a new round of galagas attacking the user
      if any? galagas-e[
        ifelse count galagas-e > 1[
          ask n-of 2 galagas-e[  ;two easy galagas per round
            set attack-mode? true
          ]
        ]
        [
          ask one-of galagas-e[
            set attack-mode? true
          ]
        ]
      ]
      if any? galagas-h [
        ifelse count galagas-h > 1[
          ask n-of 2 galagas-h[  ;one hard galaga per round
            set attack-mode? true
          ]
        ]
        [
          ask one-of galagas-h[  ;one hard galaga per round
            set attack-mode? true
          ]
        ]
      ]
    ]
    ;overarching ask statement to create simultaneous movement based on their boolean value
    ask turtles with [galaga?][
      ifelse attack-mode?[
        if easy-galaga? [   ;small discretized movement to form a figure-8 attack at the user
          update-angle-easy
          easy-upper-attack
          easy-lower-attack
        ]
        if hard-galaga? [  ;small discretized movement to form a s-shape then direct attack at the user
          update-angle-hard
          hard-upper-attack
          hard-lower-attack
        ]
      ]
      [back-and-forth] ;if they are not in attack mode, they should move back and forth across the screen
    ]
    tick ;represents one small discretized movement according to the galaga's behavior at the time
  ]
end


;===============SETUP MOVEMENT FOR GALAGAS============

;SETUP FOR HARD GALAGAS

;observer context
;creates and puts the hard galagas (galaga-h) into their formation
to create-hard
   repeat 9[
    create-galagas-h 1[
      set shape "galaga-hard"
      set heading 270
      set xcor max-pxcor
      set size 2
      ;set boolean assignments
      set galaga? true
      set moved? false
      set attack-mode? false
      set hard-galaga? true
      set easy-galaga? false
      set moving-right? true ;they start off with moving right in the back and forth movement
      set moving-left? false
    ]
    ;galagas stagger their start time so they can form a line
    ask galagas-h with [moved? = false] [
      fd 2.5
      wait 0.015
      set moved? false
    ]
  ]
  ;galagas simultaneously go to their my-home patch in a semi-circle movement
  ask galagas-h[
    set angle 12 ;sets the intial angle before their semi-circle
  ]
  move-hard ;simulataneous semi-circle movement
end

;observer context
;simultaenous semi-circle movement for galagas-h in initial setup
to move-hard
  set radius max-pycor / 3
  repeat pi * radius - 5 [ ;repeat until they reach their home-patch coordinates
    ask galagas-h [semi-right]] ;move in a semi-circle at the same time
  ask galagas-h [home-hard]    ;go to their home patch
end

;galagas-h(turtle) context
;once the galagas-h are done with their semi-circle, they will go to their home patch
to home-hard
  ;assigns my-home patch
  set my-home min-one-of hard-patches with [occupied? = false][distance myself]
  ask my-home[
    set occupied? true   ;sets it to occupied so other galagas will go to the next available patch
  ]
  while [patch-here != my-home] [
    set heading towards my-home
    fd  0.4              ;smoother movement
    wait 0.05
  ]
  set heading 0
  setxy [pxcor] of my-home [pycor] of my-home
  set attack-mode? false  ;initialized to false so they can move back and fort
end

;galagas-h (turtle) context
;individual movement for semi-circle for right hand side
to semi-right
  rt angle / 2
  fd 2 * radius * sin (angle / 2)
  rt angle / 2
  set moved? true
  wait 0.05      ;for smoother movement
end

;SETUP FOR EASY GALAGAS
;observer context
;creates and puts the easy galagas (galaga-e) into their formation
to create-easy
  repeat 9[
    create-galagas-e 1[
      set shape "galaga-easy" ;self drawn shape...name does not match as a differrent shape was ultimately chosen
      set heading 90
      set xcor min-pxcor
      set size 2
      ;set boolean assignments
      set galaga? true
      set moved? false
      set attack-mode? false
      set easy-galaga? true
      set hard-galaga? false
      set moving-right? true ;they start off with moving right in the back and forth movement
      set moving-left? false
    ]
    ;galagas stagger their start time so they can form a line
    ask galagas-e with [moved? = false] [
      fd 2.5
      wait 0.015
      set moved? false
    ]
  ]
  ;galagas simultaneously go to their my-home patch in a semi-circle movement
  ask galagas-e[
    set angle 12 ;sets the intial angle before their semi-circle
  ]
  move-easy ;simulataneous semi-circle movement
end


;observer context
;simultaenous semi-circle movement for galagas-e in initial setup
to move-easy
  set radius max-pycor / 3
  repeat pi * radius - 3[ ;repeat until they reach their home patch coordinates
    ask galagas-e [semi-left] ;move in a semi-circle at the same time
  ]
  ask galagas-e[ home-easy]   ;go to their home patch
end

;galagas-e (turtle) context
;once the galagas-e are done with their semi-circle, they will go to their home patch
to home-easy
  ;assigns my-home patch
  set my-home min-one-of easy-patches with [occupied? = false][distance myself]
  ask my-home[
    set occupied? true   ;sets it to occupied so other galagas will go to the next available patch
  ]
  while [patch-here != my-home] [
    set heading towards my-home
    fd  0.4              ;smoother movement
    wait 0.05
  ]
  set heading 0
  setxy [pxcor] of my-home [pycor] of my-home
  set attack-mode? false  ;initialized to false so they can move back and forth
end

;galagas-e (turtle) context
;individual movement for semi-circle for left hand side
to semi-left
  lt angle / 2
  fd 2 * radius * sin (angle / 2)
  lt angle / 2
  set moved? true
  wait 0.05      ;for smoother movement
end

;================BUTTON MOVEMENT IN USER INTERFACE==================

;observer context
;user moves left
;in interface tab as Left (A)
to move-left
  ask users[
    ifelse xcor = min-pxcor + 1 []
    [set xcor xcor - 0.75]
  ]
end

;observer context
;user moves right
;in interface tab as Right (D)
to move-right
  ask users [
    ifelse xcor = max-pxcor - 1 []
    [set xcor xcor + 0.75]
  ]
end

;observer context
;allows the user to shoot lasers
;in interface tab as Shoot (W)
to shoot-user
  if count users > 0 [
    create-lasers 1[
      setxy [xcor] of user user-who [ycor] of user user-who
      set heading 0
      set color green
      set shape "circle"
      set size 0.5
      not-galaga
    ]
  ]
end


;=============LASER MOVEMENTS=================
;observer context
;creates time for laser so they can die after a certain distance
to laser-progress
  ask lasers[
    fd 0.8
    ;condition prevents lasers from hitting enemies while they are in their formation
    if ycor > 7[
      die
    ]
  ]
end

;observer context
;kills the galaga if they collide with a laser
to galaga-points
  ifelse count turtles with [galaga?] > 0[
    ask turtles with [galaga?][
      let attack-laser [lasers in-radius 1] of self
      if any? attack-laser [    ;if there are any lasers colliding with the galaga
        set points points + 1   ;increments the points for the user
        ask attack-laser[
          die                   ;the laser dies
        ]
        die                     ;the galaga dies
      ]
    ]
  ]
  [
    win-game
  ]
end


;============GALAGA ATTACK MOVEMENTS====================

;HARD GALAGA ATTACK

;galagas-h (turtle) context
;discretized movement that forms the top half of a s-shape movement, a circular movement
to hard-upper-attack
  if ycor > -1 [                 ;top half of s-shape
  ;let turn
  lt angle / 2                   ;angle adjusted per movement, to best depict a circular turn
  fd 2 * radius * sin (angle / 2) ;forward movement is discretized by the indifacted radius
  lt angle / 2
    wait 0.05 ;to prevent enemies from looking as if they are teleporting
  ]
end

;galagas-h (turtle) context
;;discretized movement that forms the bottom half of a s-shape movement
;when the galaga-h reaches the danger zone, they directly attack the user
to hard-lower-attack
  if ycor <= 0 [                 ;bottom half of s-shape
    ifelse danger?[              ;danger zone
      if count users > 0 [
        face user user-who       ;directly attack the user
        fd 0.4                   ;smoother movement
        wait 0.05
        if collide-with user user-who[ ;if they successfully attack the user
          check-lives            ;check lives of user
          surrounding-galaga-death     ;kills galagas who are near the death of the user
        ]
      ]
    ]
    ;if they are not in the danger zone, do regular bottom half of s-shape movement
    [
      rt angle / 2 ;right turn and angle adjusted per movement, to best depict a circular turn
      fd 3 * radius * sin (angle / 2) ;forward movement is discretized by the indicated radius
      rt angle / 2 ;right turn and angle adjusted per movement, to best depict a circular turn
      wait 0.05
    ]
  ]
end

;galagas-h (turtle) context
;updates the heading and angle according to its y-cor during its attack movement
to update-angle-hard
  if ycor = 10[                 ;start of the home patch
    set angle 12                ;initialize angle for start of circle
    set heading 270             ;initialize heading for start of circle
  ]
  if ycor = -1 [                ;start of the bottom circle
    ;angle adjust back to 12 as a reset
    set angle 12 ]
end


;EASY GALAGA ATTACK

;galagas-e (turtle) context
;discretized movement that forms the top half of a figure-8 movement
to easy-upper-attack
  if ycor > 2 [ ;upper coordinates
  lt angle / 2 ;left turn, and angle adjusted to simulate a circular movement
  fd 2 * radius * sin (angle / 2) ;forward movement is discretized by the indicated radius
  lt angle / 2 ;left turn, and angle is adjusted to continue circular movement
    wait 0.05
  ]
end

;galagas-e (turtle) context
;discretized movement that forms the bottom half of a figure-8 movement
to easy-lower-attack
  if ycor <= 3 [ ;lower coordinates
    if count users > 0[
      if collide-with user user-who[
        check-lives ;check lives of user
        ;if easy enemy causes a death, nearby hard enemies die
        surrounding-galaga-death
      ]
    ]
    rt angle / 2 ;right turn, and angle adjusted to simulate a circular movement
    fd 4 * radius * sin (angle / 2) ;forward movement is discretized by the indicated radius
    rt angle / 2 ;right turn, and angle is adjusted to continue circular movement
    wait 0.05
  ]
end

;galagas-e (turtle) context
;updates the heading and angle according to its y-cor during its attack movement
to update-angle-easy
  if ycor = 12[ ;upper coordinates
    set angle 12
    set heading 270
  ]
  if ycor = 3 [set angle 12 ]

end

;===========GAME PROGRESSION===========
;observer context
;to update live count
;function is called when a user death occurs
to check-lives
  ask user user-who [
    set lives lives - 1 ;decrement live count
    ifelse lives = 0[ ;if after decrement live count reaches 0
      show "death"
      lose-game ;prompt game to halt and end
      die ;asks user to die
    ]
    [
      if count turtles with [galaga?] = 0 [ ;if there are no more enemies in the plane
        win-game ;prompt game to halt and end
      ]
      ;if live count is decremented, but not at zero
      set xcor 0 ;asks user to relocate to the center of the screen
    ]
  ]
end

;observer context
;patch update to display victory label
to win-game
    ask patch 3 0 [
    set plabel "YOU WON :P"
    set plabel-color white
  ]
end

;observer context
;patch update to display lose label
to lose-game
  show "end game"
  ask other turtles with [galaga?] [stop]
  ask patch 3 0 [
    set plabel "YOU LOST :O"
    set plabel-color white
  ]
end

;observer context
;due to the behavior of the galagas-h, they will always attack the user even if they get a new life
;we decided that if a user loses a life, all of the hard galagas will die in the danger zone so they don't attack the new user
;creates a more fair gameplay
to surrounding-galaga-death
  if any? galagas-h[ ;asks enemies to do only if they are within the specified range
    ask galagas-h with[ ycor < 0 - (max-pycor / 2)][
      die
    ]
  ]
end


;=================PATCH ASSIGNMENTS=================
;assigns patches to specific booleans such as my-home and danger patches

;observer context
;creates home patches for galagas
;when galagas are created, they will land on a home patch
to create-formations
  ask easy-patches[
    set occupied? false             ;set them false so they are free to be occupied
    if count galagas-e-here > 0[
      set occupied? true            ;once a galaga-e lands on the patch, no other galaga-e can land on it
    ]
  ]
  ask hard-patches[
    set occupied? false             ;set them false so they are free to be occupied
    if count galagas-h-here > 0[
      set occupied? true            ;once a galaga-h lands on the patch, no other galaga-h can land on it
    ]
  ]
end

;observer context
;danger zone is specifcally for hard galagas
;once a hard galaga is in the danger zone, they will face the user and directly attack it
;not visible in the interface
to danger-zone
  ask patches with [pycor < 0 - (max-pycor / 2)][ ;specified patches are designated as special danger regions
    set danger? true
    ]
  ask patches with [danger? != true][
    set danger? false ;all other patches are labeled as false, to facilitate movements dependent on patches
    ]
end

;=============BACK AND FORTH MOVEMENT===============
;back and forth movement when galagas are in their home and not in attack mode

;observer context
;movement occuring when an enemy is prompted to attack
to back-and-forth
  start-back-and-forth ;they first move to the right
  check-left-border ;check if any galagas hit the left border
  check-right-border ;check if any galagas hit the right border
  if any? turtles with [galaga? and attack-mode? = false and hit-left-wall? = true][ ;if they hit the left border, move right
    ask turtles with [galaga?][
      set moving-left? false ;boolean update to update movement
      set moving-right? true ;boolean update to update movement
      set xcor xcor + 0.025 ;coordinate changes deemed to be natural-like
      wait 0.001
    ]
  ]
  if any? turtles with [galaga? and attack-mode? = false and hit-right-wall? = true][ ;if they hit the right border, move left
    ask turtles with [galaga?][
      set moving-left? true ;boolean update to update movement
      set moving-right? false ;boolean update to update movement
      set xcor xcor - 0.025 ;coordinate changes deemed to be natural-like
      wait 0.001
    ]
  ]
end


;observer context
;initial back and forth movement to start off the movement
to start-back-and-forth
  ;commences general back-and-forth movement
  ask turtles with [galaga? and attack-mode? = false][
    if moving-right? [set xcor xcor + 0.025 wait 0.001]
    if moving-left? [set xcor xcor - 0.025 wait 0.001]
  ]
end

;observer context
;checks if any galagas not in attack mode hit the left border
to check-left-border
  ask turtles with [galaga? and attack-mode? = false][
    ifelse xcor < (min-pxcor + 3 ) ;leftmost barrier
    [set hit-left-wall? true] ;updates boolean to change movement
    [set hit-left-wall? false] ;updates boolean to change movement
  ]
end

;observer context
;checks if any galagas not in attack mode hit the right border
to check-right-border
    ask turtles with [galaga? and attack-mode? = false][
    ifelse xcor > (max-pxcor - 3 ) ;rightmost barrier
    [set hit-right-wall? true] ;updates boolean to change movement
    [set hit-right-wall? false] ;updates boolean to change movement
  ]
end

;==========REPORTERS AND MISCELLANEOUS METHODS==========

;reports if something collides with the object
to-report collide-with [object]
  report distance object <= [size] of object / 2
end

;reports the live count of the user
to-report lives-count
  report lives
end

;creates home patches for easy galagas
to-report easy-patches
  ;for patches with specified data
  report patches with [pycor = 12 and pxcor mod(3) = 0 and pxcor >= -12 and pxcor <= 12]
end

;creates home patches for hard galagas
to-report hard-patches
   ;for patches with specified data
  report patches with [pycor = 10 and pxcor mod(3) = 0 and pxcor >= -12 and pxcor <= 12]
end


;sets false booleans for non-galaga breeds
to not-galaga
  set galaga? false
  set easy-galaga? false
  set hard-galaga? false
  set moving-right? false
  set moving-left? false
end
@#$#@#$#@
GRAPHICS-WINDOW
273
16
815
559
-1
-1
16.2
1
15
1
1
1
0
1
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
39
168
137
201
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
43
329
135
362
Left
move-left
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
146
329
248
362
Right
move-right
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
90
292
192
325
Shoot
shoot-user
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
141
168
235
201
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
43
211
135
256
Score:
points
17
1
11

MONITOR
142
210
227
255
Lives
lives-count
17
1
11

CHOOSER
66
98
204
143
level
level
"1" "2" "3"
2

@#$#@#$#@
## WHAT IS IT?

CSCI0390 Term Project
Galaga NetLogo Implementation
Nusrat Atiya & Noe Zambrano Romero

The objective of the Galaga game is for the user to shoot down all of the galagas (enemies) before it loses all of its lives. 

## HOW IT WORKS

The galaga Netlogo implementation is a simplified version of the 1981 fixed shooter game, Galaga. The model uses turtle agents as breeds for the playable user, lasers, and enemies, as well as patch assignments that facilitate the behavior of the turtle agents.

The patch assignments are made to generate 'homes' for the turtles labeled as either 'easy' or 'hard', in order to have the galagas create a formation during the setup phase when they spawn. Patch assignments are also made to create a 'danger' zone that manipulates the behavior of the 'hard' enemies, as they approach the user.

The user avatar's movement is based on interface buttons that prompt right and left movement. Laser movement is prompted by a shoot button on the interface, which creates a laser breed relative to the position of the avatar, and progresses forwards until either it reaches the max length it can travel, or makes contact with an enemy. This progression movement only works during the simulation of the gameplay. 

The enemy turtle agents and their movements are split up into how they are labeled, either as 'easy' or 'hard'. The general movements can be broken into a spawn movement and an attack movement. The spawn movement is a outward line from the y-axis from either the minimum x-coordinate value or maximum x-coordinate value, for the easy and hard respectively, followed by a semi circular movement from their position toward patches labeled as 'home' patches. Attack movements are also dependent on whether the agent is 'hard' or 'easy'. In the easy attack movement, the total movement is a discretized figure eight movement that continues game play and ends as a result of the user losing, or it dies. The 'hard' attacking  movement follows a similar discretized half figure eight movement (S shape movement) until it finds itself on a patch labeled as a 'danger' patch, where it then adjusts its movement to face the user and progress until it dies or the game halts, via a loss. 

## HOW TO USE IT

To begin gameplay, a level must be selected, of which are ordered based on difficulty. Once a level is selected, the user should select the 'setup' button to generate the playing plane, along with all relevant turtle agents and patch formations. This sequence must be followed to create the desired gameplay. 

The 'simulate' button is then clicked on and the game begins. 

## THINGS TO NOTICE

The game difficulty is based on the frequency of attacks. The enemies are prompted to attack based on tick count. As the difficulty increases, the tick count decreases, in order to make attacks more frequent. 

The side wall limits is removed, allowing a horizontal wrapped world. This was implemented in order to have 'easy' galagas perform their entire movement without getting stuck on the side wall. 

If the user is killed, but live count remains over 0, the user does not actually die. Instead, their coordinates are moved to the center and all surrounding 'hard' enemies are asked to die to make gameplay less difficult, and to prevent the user from dying immediately after 'respawn'.

The setup button must be clicked and completed before a simulate can start as spawn movements are broken up. Additionally, implementing a setup in the simulate resulted in an infinite setup, and would consistently halt or mess up gameplay.

## THINGS TO TRY

From code adjustments, the live count can be modified to make success in the game easier. The difficulty can also be modified from the code in the galaga-gameplay procedures, by adjusting the tick frequency of attacks. 

The absolute max highscore that can be reached is 18, assuming each of the 18 available enemies are killed as a result of the laser. Whenever the user dies, it asks all 'hard' enemies within the lower region of the 'danger' zone to die. When this occurs, those enemies' deaths do not count toward the point tally.

## EXTENDING THE MODEL

Implementing a function that would allow enemies to return to their home patch after a failed attack (complete the movement and not have killed the user) was a task we had been working on, and had implemented a retreat patch formation that would have facilitated this movement. This feature was ultimately removed because of complexity issues.

Implementation of smoother movement could be implemented, but would require a more meticulous breakdown of the overall movement. Discretizing the spawn movement can also be implemented and would facilitate level progression. 

Additionally, there could be a random number of galagas attacking at each round, but with the structure of the code, it would require an if statement for every single edge case such as if it asked for 3 galagas to attack but only two remain. If there is a more efficient way to implement this, it would add more randomness to the game. 

## NETLOGO FEATURES

The shape editor function within Netlogo was used to draw our own shapes so that they would resemble Galaga's own gameplay.

Patch booleans were frequently referred to, in order to faciliate any complex movement. 

## RELATED MODELS

Rebecca Warholic's 'Alien Invader' model was a similar, and the discretization of movement was helpful in understanding the overarching concept of breaking down movements, rather than a complete movement that required each turtle to complete before the next could begin their own movement. 

## CREDITS AND REFERENCES

On this project, we received assistance from Professor Dickerson and Rebecca Warholic (ASI). 
The shapes and overall gameplay is based on the 1981 fixed shooter game, Galaga.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

galaga-easy
true
0
Rectangle -1184463 true false 105 45 195 120
Rectangle -1184463 true false 135 15 165 45
Rectangle -2674135 true false 105 60 135 75
Rectangle -2674135 true false 120 45 135 60
Rectangle -2674135 true false 165 45 180 75
Rectangle -2674135 true false 165 60 195 75
Rectangle -13345367 true false 105 120 120 165
Rectangle -13345367 true false 180 120 195 165
Rectangle -2674135 true false 120 120 180 180
Rectangle -1184463 true false 120 180 180 195
Rectangle -2674135 true false 120 195 180 210
Rectangle -2674135 true false 135 210 165 225
Rectangle -13345367 true false 90 60 105 75
Rectangle -13345367 true false 75 45 90 60
Rectangle -13345367 true false 60 30 75 45
Rectangle -13345367 true false 195 60 210 75
Rectangle -13345367 true false 210 45 225 60
Rectangle -13345367 true false 225 30 240 45
Rectangle -13345367 true false 75 105 120 150
Rectangle -13345367 true false 180 105 225 150
Rectangle -13345367 true false 60 120 105 180
Rectangle -13345367 true false 195 120 240 180
Rectangle -13345367 true false 45 135 90 225
Rectangle -13345367 true false 210 135 255 225
Rectangle -13345367 true false 30 150 60 225
Rectangle -13345367 true false 240 150 270 225

galaga-hard
true
0
Rectangle -11221820 true false 120 45 195 105
Rectangle -955883 true false 120 45 150 75
Rectangle -955883 true false 165 45 195 75
Rectangle -11221820 true false 135 30 150 45
Rectangle -11221820 true false 165 30 180 45
Rectangle -11221820 true false 195 45 225 60
Rectangle -11221820 true false 195 60 210 75
Rectangle -11221820 true false 90 45 120 60
Rectangle -11221820 true false 105 75 120 75
Rectangle -11221820 true false 105 60 120 75
Rectangle -1184463 true false 120 105 150 105
Rectangle -1184463 true false 120 90 195 120
Rectangle -11221820 true false 150 90 165 105
Rectangle -1184463 true false 120 120 195 150
Line -955883 false 120 150 195 150
Line -955883 false 120 150 195 150
Line -955883 false 120 150 195 150
Rectangle -955883 true false 135 150 150 180
Rectangle -955883 true false 165 150 180 180
Rectangle -11221820 true false 195 90 225 135
Rectangle -11221820 true false 90 90 120 135
Rectangle -11221820 true false 225 105 240 195
Rectangle -11221820 true false 75 105 90 195
Rectangle -11221820 true false 240 120 270 135
Rectangle -11221820 true false 240 135 255 150
Rectangle -11221820 true false 45 120 75 135
Rectangle -11221820 true false 60 135 75 150
Rectangle -11221820 true false 90 135 105 180
Rectangle -11221820 true false 210 135 240 180
Rectangle -11221820 true false 90 180 120 210
Rectangle -11221820 true false 210 180 210 210
Rectangle -11221820 true false 195 180 225 210
Rectangle -11221820 true false 105 210 135 225
Rectangle -11221820 true false 180 210 210 225
Rectangle -11221820 true false 135 225 150 240
Rectangle -11221820 true false 120 225 135 240
Rectangle -11221820 true false 165 225 195 240
Rectangle -11221820 true false 135 240 150 255
Rectangle -11221820 true false 165 240 180 255

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

player
true
0
Rectangle -1 true false 150 30 165 75
Rectangle -1 true false 135 75 180 240
Rectangle -1 true false 150 240 165 270
Rectangle -1 true false 120 135 195 195
Rectangle -13345367 true false 120 150 120 165
Rectangle -13345367 true false 105 150 120 165
Rectangle -13345367 true false 195 150 210 165
Rectangle -13345367 true false 90 165 105 180
Rectangle -2674135 true false 210 165 225 180
Rectangle -13345367 true false 210 165 225 180
Rectangle -1 true false 90 150 105 165
Rectangle -2674135 true false 210 150 225 165
Rectangle -1 true false 210 150 225 165
Rectangle -2674135 true false 210 120 225 150
Rectangle -2674135 true false 90 120 105 150
Rectangle -2674135 true false 150 150 165 165
Rectangle -2674135 true false 135 165 150 180
Rectangle -2674135 true false 150 165 165 180
Rectangle -2674135 true false 165 165 180 180
Rectangle -2674135 true false 135 180 150 195
Rectangle -2674135 true false 165 180 180 195
Rectangle -1 true false 105 165 120 210
Rectangle -1 true false 195 180 195 180
Rectangle -1 true false 195 165 210 210
Rectangle -1 true false 210 180 225 210
Rectangle -1 true false 90 180 105 210
Rectangle -1 true false 225 195 240 225
Rectangle -2674135 true false 75 195 90 225
Rectangle -2674135 true false 120 210 135 240
Rectangle -2674135 true false 120 195 135 210
Rectangle -2674135 true false 180 195 195 240
Rectangle -2674135 true false 195 210 210 240
Rectangle -1 true false 105 210 120 240
Rectangle -1 true false 75 195 90 225
Rectangle -2674135 true false 105 210 120 240
Rectangle -1 true false 60 210 75 240
Rectangle -1 true false 240 210 255 240
Rectangle -1 true false 45 165 60 240
Rectangle -1 true false 255 165 270 240
Rectangle -2674135 true false 45 135 60 165
Rectangle -2674135 true false 255 135 270 165

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
