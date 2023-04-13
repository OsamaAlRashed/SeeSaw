breed [basiss basis]
breed [sub-sticks sub-stick]
breed [birds bird]
breed [pillars pillar]
breed [worms worm]
breed [face-worms face-worm]

sub-sticks-own [ state ]

globals[
  left-current-position-piece right-current-position-piece
  move-stick heading-shift end-sub-stick
  const-y
  mouse-was-down?
  list-of-weight
  side-angle
  speed real-speed
  show-face-worm?

  total-left-wieghts total-right-wieghts
  total-left-torques total-right-torques
  diffrent-of-torques
]

; setup Button

to setup
  clear-all

  init-constants

  color-background

  createBasis

  createPillars

  createBirds

  createWorm

  createStick

end

to init-constants
  set const-y -4
  set move-stick 0
  set heading-shift 0.05
  set show-face-worm? false
  set list-of-weight [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
end

to color-background
  ifelse NIGHT-MODE ;global var
  [
    ask patches [ set pcolor 101 ]
    create-stars-and-moon
  ]
  [
    ask patches [ set pcolor sky ]
    create-clouds
  ]
  ask patches with [ pycor < (-10) ]
  [ set pcolor 53 ]
end

to create-stars-and-moon
  crt 1 [
    setxy -17 22
    set shape "moon"
    set color white
    set size 7
  ]
  repeat 20 [
    let x random 70 - 35
    let y random 10 + 18
    crt 1
    [
      setxy x y
      set shape "star"
      set size 0.5
      set color white
    ]
  ]
end

to create-clouds
  repeat 3 [
    let x random 70 - 35
    let y random 4 + 22
    crt 1
    [
      setxy x y
      set shape "cloud"
      set size 7
      set color white
    ]
  ]

end

to createBasis
  create-basiss 1 [
    set shape "basis"
    set size 10
    setxy 0 -8
  ]
end

to createPillars
  create-pillars 1 [
    setxy -14 -8.2
    set shape "pillar"
    set size 10
    set color gray
    set heading 0
  ]

  create-pillars 1 [
    setxy 14 -8.2
    set shape "pillar"
    set size 10
    set color gray
    set heading 0
  ]
end

to createBirds
  create-birds 5 [
    setxy random 5 + 35 random 5 + 20
    set shape "left-bird"
    set size 2
    set color white
    set heading -90
  ]
end

to createWorm
  create-worms 1 [
    setxy random 30 -17
    set shape "worm1"
    set size 7
    set heading -90
  ]
end

to createStick
  create-sub-sticks 1
  [
    set shape "center-sub-stick"
    set size 4
    setxy 0 const-y
    set heading 0
    set color 36
    set state 1

    generate-left-side

    generate-right-side
  ]

end

to generate-left-side
  repeat LEFT-STICK-COUNT
    [
      set left-current-position-piece left-current-position-piece - 4
      hatch 1
      [
        set breed sub-sticks
        set shape "left-sub-stick"
        fd 4
        set color 36
        set size 4
        set heading 0
        setxy left-current-position-piece const-y
        set state 0
        if left-current-position-piece = (-4 * LEFT-STICK-COUNT)
        [
          set state 2
        ]
        ask myself [ create-link-to myself [ tie hide-link ]]
        ]
      ]
end

to generate-right-side
  set right-current-position-piece 4
    repeat RIGHT-STICK-COUNT
    [
      hatch 1
      [
        set breed sub-sticks
        set shape "right-sub-stick"
        fd 4
        set color 36
        set size 4
        set heading 0
        set state 0
        setxy right-current-position-piece const-y
        ask myself [ create-link-to myself [ tie hide-link ]]
        if right-current-position-piece = (4 * RIGHT-STICK-COUNT)
        [
          set state 2
        ]
      ]
      set right-current-position-piece right-current-position-piece + 4
    ]
end

;end setup Button

; simulation Button

to simulation

  fly-birds

  walk-worm

  move-face-worm

  mouse-manager

  every speed
  [
    if move-stick = 1
    [
      set end-sub-stick [ycor] of one-of sub-sticks with[state = 2]
      if end-sub-stick <= -11
      [
        set move-stick 0
        ask worms
        [
          hide-turtle
        ]
        set show-face-worm? true
        createFaceWorm
      ]

      ask sub-sticks with [state = 1][
        set heading heading - (side-angle * heading-shift)
      ]
    ]
  ]

  display

end

to fly-birds
  every 0.1 [
    ask birds [
      jump 1
      every 0.15 [
        ifelse shape = "left-bird"
        [
          set shape "right-bird"
        ]
        [
          set shape "left-bird"
        ]
      ]
    ]
  ]

end

to walk-worm
  every 0.3 [
    ask worms [
      jump 1
      every 0.15 [
        ifelse shape = "worm1"
        [
          set shape "worm2"
        ]
        [
          set shape "worm1"
        ]
      ]
    ]
  ]
end

to move-face-worm
  if show-face-worm?
  [
    every 0.016 [
      ask face-worms [
        jump 0.1
        if ycor >= -16
        [
          set show-face-worm? false
        ]
      ]
    ]
  ]
end

to createFaceWorm
  create-face-worms 1 [
          setxy 30 -18
          set size 10
          set heading 0
          set shape "face-worm"
          set color white
        ]
end

to mouse-manager
  every 0.005
  [
    let mouse-is-down? mouse-down?
    if mouse-clicked? [
        create-weight
    ]
    set mouse-was-down? mouse-is-down?
  ]
end

to-report mouse-clicked?
  report (mouse-was-down? = true and not mouse-down?)
end

to create-weight
  if validate-click
  [
    let x mouse-xcor
    let y mouse-ycor

    set x 4 * ((x / abs(x)) * (floor((abs(x) - 2) / 4) + 1))

    let index x / 4 + 8;
    if index >= 9
    [
      set index index - 1
    ]

    set y -1.2 + (1.5 * item index list-of-weight)

    let current-sub-stick one-of sub-sticks with [xcor = x]

    if current-sub-stick != nobody
    [
       ask current-sub-stick [
        if item index list-of-weight +  (weight / 5) < 15
        [
          repeat weight / 5 [
            hatch 1 [
              setxy x y
              set size 5
              set heading 0
              set shape "5kg"
              ask myself [ create-link-to myself [ tie hide-link ]]
              fd 0
            ]
            set y y + 1.5
          ]
          set list-of-weight replace-item index list-of-weight (weight / 5 + item index list-of-weight)
        ]
      ]
    ]
  ]

  end

to-report validate-click
  let x mouse-xcor
  let y mouse-ycor
  report (y > -1.2 and ((x > 2 and x < RIGHT-STICK-COUNT * 4 + 2) or (x < -2 and x > LEFT-STICK-COUNT * -4 - 2)) and move-stick = 0)
end

;end simulation Button

; go Button

to go
  set speed cal-speed
  ifelse which-win != 0
  [
    set side-angle abs(which-win) / which-win
  ]
  [
    set side-angle 0
  ]
  if move-stick = 0
  [
    hide-pillars
    set move-stick 1
  ]
end

to-report cal-speed
  let dif abs(which-win)
  set speed dif / 700 ;508
  set speed precision speed 3
  set speed 0.01 - (speed / 100)

  set real-speed speed * 1000
  set real-speed 8 - (real-speed - 3)
  report speed
end

to hide-pillars
  ask pillars [
    hide-turtle
  ]
end

to-report which-win
  let left-side 0
  let right-side 0
  let index 0
  foreach list-of-weight [
    currentWieght ->
    ifelse index >= 0 and index <= 7
    [
      let d-left 8 - index
      set left-side left-side + (d-left * currentWieght)
      set total-left-wieghts total-left-wieghts + currentWieght
    ]
    [
      let d-right index - 7
      set right-side right-side + (d-right * currentWieght)
      set total-right-wieghts total-right-wieghts + currentWieght
    ]
    set index index + 1
  ]

  set total-left-torques left-side * 10
  set total-right-torques right-side * 10

  set diffrent-of-torques abs(total-left-torques - total-right-torques)

  if CAL-WEIGHT-STICK
  [
    set left-side left-side + LEFT-STICK-COUNT
    set right-side right-side + RIGHT-STICK-COUNT
  ]

  report left-side - right-side
end

; end go Button

; puase Button

to puase

  let temp-list list-of-weight

  setup

  set list-of-weight temp-list

  if LEFT-STICK-COUNT < 8
  [
    set list-of-weight replace-item 0 list-of-weight 0
  ]

  if LEFT-STICK-COUNT < 7
  [
    set list-of-weight replace-item 1 list-of-weight 0
  ]

  if LEFT-STICK-COUNT < 6
  [
    set list-of-weight replace-item 2 list-of-weight 0
  ]

  if LEFT-STICK-COUNT < 5
  [
    set list-of-weight replace-item 3 list-of-weight 0
  ]

  if RIGHT-STICK-COUNT < 8
  [
    set list-of-weight replace-item 15 list-of-weight 0
  ]

  if RIGHT-STICK-COUNT < 7
  [
    set list-of-weight replace-item 14 list-of-weight 0
  ]

  if RIGHT-STICK-COUNT < 6
  [
    set list-of-weight replace-item 13 list-of-weight 0
  ]

  if RIGHT-STICK-COUNT < 5
  [
    set list-of-weight replace-item 12 list-of-weight 0
  ]

  restore-wieghts

end

to restore-wieghts

  let index 0

  let x -32

  foreach list-of-weight [
    currentWieght ->
    let y -1.2
    let current-sub-stick one-of sub-sticks with [xcor = x]

    if current-sub-stick != nobody [
      ask current-sub-stick [
          repeat currentWieght [
            hatch 1 [
              setxy x y
              set size 5
              set heading 0
              set shape "5kg"
              ask myself [ create-link-to myself [ tie hide-link ]]
              fd 0
            ]
            set y y + 1.5
          ]
      ]
    ]

    set x x + 4
    if x = 0
    [
      set x 4
    ]
    set index index + 1
  ]


end

; end puase Button
@#$#@#$#@
GRAPHICS-WINDOW
382
14
1316
583
-1
-1
11.4321
1
10
1
1
1
0
1
0
1
-40
40
-20
28
0
0
1
ticks
30.0

BUTTON
59
162
348
200
APPLY & SETUP
setup
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

SLIDER
61
64
349
97
RIGHT-STICK-COUNT
RIGHT-STICK-COUNT
4
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
60
22
348
55
LEFT-STICK-COUNT
LEFT-STICK-COUNT
4
8
6.0
1
1
NIL
HORIZONTAL

BUTTON
207
322
345
360
RUN
go
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

BUTTON
61
213
347
252
START SIMULATION
simulation
T
1
T
OBSERVER
NIL
S
NIL
NIL
1

CHOOSER
60
265
346
310
weight
weight
5 10 15 20
0

SWITCH
207
114
348
147
NIGHT-MODE
NIGHT-MODE
0
1
-1000

SWITCH
62
114
197
147
CAL-WEIGHT-STICK
CAL-WEIGHT-STICK
1
1
-1000

BUTTON
59
322
197
360
PAUSE
puase
NIL
1
T
OBSERVER
NIL
P
NIL
NIL
1

MONITOR
60
372
347
417
REAL-SPEED
real-speed
0
1
11

MONITOR
60
427
199
472
TOTAL-WEIGHTS-LEFT
total-left-wieghts
0
1
11

MONITOR
209
427
348
472
TOTAL-WEIGHTS-RIGHT
total-right-wieghts
0
1
11

MONITOR
60
479
197
524
TOTAL-TROQUE-LEFT
total-left-torques
0
1
11

MONITOR
209
480
348
525
TOTAL-TROQUE-RIGHT
total-right-torques
0
1
11

MONITOR
60
537
346
582
RESAULTENT-TROQUE
diffrent-of-torques
0
1
11

@#$#@#$#@
## WHAT IS IT?

his experiment represents one of the simple types of machines that save effort and time on humans, which is the crane.

This lever consists of a fulcrum and sticks of different lengths, the length of each end of which can be determined by specifying the number of pieces on each side, each piece increasing the length of the stick 4.

You can put some weights on the stick on both sides, there are three types of weights (5, 10, 15, 20), and then the torques applied to them are calculated by means of physical laws and then you see the result by tilting the stick in the direction of the strongest torque.

You can try again and add some weights on top of the canes or remove them completely and put new weights in.


## ELEMENTS ACTIONS


### Monitors

- REAL-SPEED The speed of rotation of the stick in the direction of the greater torque during the implementation of the simulation.

- TOTAL-WEIGHTS-LEFT The sum of the masses of the masses on the left end of the stick.

- TOTAL-WEIGHTS-RIGHT The sum of the masses of the masses on the right end of the stick

- TOTAL-TROQUE-LEFT The total torque of the left end of the stick.

- TOTAL-TROQUE-RIGHT The total torque of the right end of the stick

- RESAULTENT-TROQUE The product of the resultant torque

### Buttons

- START SIMULATION Runs the simulation so you can adjust setting values and add blocks on the stick.

- APPLY & SETUP Re-initializes the elements with the values ​​of the entered settings.

- RUN Executing the simulation performs the set values ​​and blocks and displays their results.

- PAUSED stops the simulation from running.


### Slider

- LEFT-STICK-COUNT We make use of it by determining the length of the stick for the left side of the stick.

- RIGHT-STICK-COUNT We make use of it by determining the length of the stick for the right side of the stick.

### Choser

- WHIGHT-BLOCK You can specify the weight of the block you are going to add, since we have four block weights available.

### Switcher

- NIGHT-MODE This switch turns the night mode on or off.

- CAL-WEIGHT-STICK By activating it, the weight of the stick will be calculated within the physical relations, that is, the stick will have an effect on the torque.


## HOW TO USE IT


### Adjust Settings

- Determine the length of the stick by specifying the number of pieces on both sides of the stick.

- If you want to calculate the weight of the stick within the physical relations, activate the "CAL-WEIGHT-STICK" Switch.

- Select the mode you would like to be in during the simulation process (Day/Night) with "NIGHT-MODE" Switch.

- Press "APPLY & SETUP" to apply the settings you have set.

### Start Simulation

- Just press the "START SIMULATION" button to start the simulation.


### Add Block

- Choose the weight of the block to be added.

- Click with the mouse on the piece of stick to be added, add a number of blocks.


### Final Steps


- Press the "Run" button to see the simulation result and the effect of weights on the sticks and their inclination to the direction of greatest torque.


- If you want to add new weights, press “PAUSE” button and add whatever weights you want, and press the “RUN” button again.

- If you want to reformat all entries and remove all added blocks, press "APPLY & SETUP" button.



## SOME OF NOTES

- The closer the mass is to the center, the less it affects the torque.


- You cannot add any mass on the fulcrum.


- You cannot put more than 14 blocks on one stick.


- You cannot put any block out or away from the stick.


- You cannot remove a piece you added previously.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

5kg
true
0
Rectangle -2674135 true false 60 105 240 195
Rectangle -16777216 false false 60 105 240 195

basis
false
0
Circle -1184463 true false 150 135 0
Polygon -7500403 true true 165 15 135 15 0 300 15 300 150 30 285 300 300 300 165 15 165 15
Rectangle -7500403 false true 135 0 165 15
Rectangle -7500403 false true 135 0 165 15
Polygon -1184463 true false 135 0 135 15 0 300 30 300 150 45 270 300 300 300 165 15 165 0 135 0 135 15
Polygon -16777216 false false 135 0 135 0 135 15 0 300 30 300 150 45 270 300 300 300 165 15 165 0 135 0 165 0

center-sub-stick
true
0
Rectangle -16777216 true false 0 0 30 90
Rectangle -16777216 true false 270 0 300 90
Rectangle -16777216 false false 30 0 270 90
Rectangle -7500403 true true 30 0 270 90
Rectangle -16777216 false false 30 0 270 90

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

face-worm
true
0
Circle -955883 true false 105 75 120
Rectangle -955883 true false 105 135 225 300
Circle -16777216 true false 120 135 28
Circle -16777216 true false 180 135 28
Polygon -16777216 true false 135 180 135 210 195 210 195 180 180 180 180 195 150 195 150 180 135 180
Rectangle -7500403 true true 30 0 75 15
Rectangle -7500403 true true 90 30 105 60
Rectangle -7500403 true true 30 0 45 60
Rectangle -7500403 true true 30 30 75 45
Rectangle -7500403 true true 120 30 135 60
Rectangle -7500403 true true 150 30 165 60
Rectangle -7500403 true true 120 30 165 45
Rectangle -7500403 true true 180 30 195 60
Rectangle -7500403 true true 210 15 240 30
Rectangle -7500403 true true 225 15 240 45
Rectangle -7500403 true true 210 0 225 30
Rectangle -7500403 true true 255 30 300 45
Rectangle -7500403 true true 285 30 300 60
Rectangle -7500403 true true 255 0 270 60
Rectangle -7500403 true true 225 45 240 60
Rectangle -7500403 true true 210 45 240 60

left-bird
true
0
Polygon -7500403 true true 165 0 135 15 135 75 15 135 15 210 135 165 135 300 180 300

left-sub-stick
true
0
Rectangle -7500403 true true 150 150 150 150
Rectangle -7500403 false true 30 0 300 90
Rectangle -7500403 true true 30 0 300 90
Rectangle -7500403 true true 15 135 15 135
Rectangle -16777216 true false 0 0 30 90
Rectangle -16777216 false false 0 0 300 90

moon
false
0
Polygon -7500403 true true 175 7 83 36 25 108 27 186 79 250 134 271 205 274 281 239 207 233 152 216 113 185 104 132 110 77 132 51

pillar
true
0
Rectangle -7500403 true true 75 15 225 285
Circle -7500403 true true 45 0 60
Circle -7500403 true true 195 0 60
Circle -7500403 true true 45 240 60
Circle -7500403 true true 195 240 60
Line -16777216 false 75 60 75 60
Line -16777216 false 75 60 75 60
Line -16777216 false 75 60 225 60
Line -16777216 false 75 240 225 240
Circle -16777216 false false 45 240 60
Circle -16777216 false false 195 240 60
Circle -16777216 false false 45 0 60
Circle -16777216 false false 195 0 60
Line -16777216 false 75 300 225 300
Line -16777216 false 75 0 225 0
Rectangle -7500403 true true 75 240 225 300
Rectangle -7500403 true true 75 0 225 60
Line -16777216 false 75 240 225 240
Line -16777216 false 75 300 225 300
Line -16777216 false 75 0 225 0
Line -16777216 false 75 60 75 240
Line -16777216 false 225 60 225 240
Line -16777216 false 75 60 225 60

right-bird
true
0
Polygon -7500403 true true 135 15 165 0 180 300 135 300 135 15
Polygon -7500403 true true 165 75 285 120 285 195 165 165 165 75 165 75

right-sub-stick
true
0
Rectangle -7500403 false true 0 0 270 90
Rectangle -16777216 true false 270 0 300 90
Rectangle -7500403 true true 0 0 270 90
Rectangle -16777216 false false 0 0 300 90

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

worm1
true
0
Circle -6459832 true false 117 191 67
Circle -955883 false false 117 192 66
Circle -6459832 true false 117 146 67
Circle -955883 false false 117 147 66
Circle -6459832 true false 117 101 67
Circle -955883 false false 117 102 66
Circle -6459832 true false 117 56 67
Circle -955883 false false 117 57 66
Circle -6459832 true false 147 56 67
Circle -955883 false false 147 57 66
Circle -6459832 true false 177 56 67
Circle -955883 false false 177 57 66

worm2
true
0
Circle -6459832 true false 117 191 67
Circle -955883 false false 117 192 66
Circle -6459832 true false 147 146 67
Circle -955883 false false 147 147 66
Circle -6459832 true false 117 101 67
Circle -955883 false false 117 102 66
Circle -6459832 true false 117 56 67
Circle -955883 false false 117 57 66
Circle -6459832 true false 147 56 67
Circle -955883 false false 147 57 66
Circle -6459832 true false 177 56 67
Circle -955883 false false 177 57 66
@#$#@#$#@
NetLogo 6.1.0
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
