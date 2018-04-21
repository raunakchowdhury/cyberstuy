globals [
  g ; accelration due to gravity
  lives
  score
  time-stamps
  bomb# ; how frequently bombs are spawned
  katana-color
  delay ;variables that make a delay ebtween things, can be adjusted
  delay2
  delay4
  delay5
  god-delay ;; timer for god mode
  mode? ; easy , medium, etc
  score-multiplier ;; For multiplier bananas
  frenzy-switch ;; For turning on and off the Frenzy effect
  notification ;; For notifying the player what type of banana they sliced
  freezing? ; was a freezing banana sliced
  godmode? ; are you in god mode?
]

breed [blades blade]
breed [fruits fruit]
breed [fruit-babies fruit-baby]
breed [bombs bomb]
breed [banas bana]
breed [popups popup]
breed [waters water] ; the little things that come out of the grass and sea katana

blades-own [
  og-heading ; heading the blade had
]

fruits-own [
  v_x ; velocity in x direction
  v_y ; velocity in y direction
  frenzy? ;; Diffrentiates between frenzy fruit and regular fruit
  frozen? ; are they frozen
  godly? ;; Are the godly fruit
]

fruit-babies-own [
  v_x ; velocity in x direction
  v_y ; velocity in y direction
]

bombs-own [
  v_x ; velocity in x direction
  v_y ; velocity in y direction
  frozen? ; are they frozen
]

banas-own [
  v_x ; velocity in x direction
  v_y ; velocity in y direction
  banana-type
]

patches-own [
  next-stage
  frozen-diffuse
  delay3
]

waters-own [
  v_x
  v_y
]

                                                                      ;;;;;;;;;;
                                                                        ;CODE;
                                                                      ;;;;;;;;;;


to setup
  ca
  reset-timer
  reset-ticks
  ask patches [set pcolor 9.9]
  initialize-globals
  blade-thing
end

to initialize-globals
  set lives 3
  set g 0.05
  set mode? 0
  set score-multiplier 1
  set freezing? "n"
  set godmode? false
end

to blade-thing
  create-blades 1 [
    set size 2.5
    set hidden? false
    set color white
    set heading 0
    set time-stamps []
  ]
  ;Raunak Chowdhury (over the break)
end

                                                   ;;;;;;
                                                   ;; GO FUNTION
                                                   ;;;;;;

to go
  katana-design ; renders design for katana
  ifelse mode? = 0 [ ; makes the mode screen
    mode-screen
  ]
  [
    ifelse mode? = 1 [ ; waits for user to select a mode
      wait-for-pick
      blade-cut
      waters-die
      set score 0
    ]
    [
      blade-cut  ;katana
      make-stuff ;makes fruits and bombs
      fruit-frenzy ;initlaites fenzy
      parabola   ;makes them move
      kill-useless-turtles ; makes them go off screen
      erase-combos ; erases combo messages
      erase-fails ; reases xs
      expire-effect ;effects from banans expire
      expire-god-effect ;; Expires the god effect
      if lives <= 0 [ ;ends game
        end-game
      ]
    ]
  ]
  color-fade ;makes fruit juice + katana faden
  tick
end

to mode-screen
  mode-fruits
  blade-cut  ;katana
end

to mode-fruits
  create-fruits 4 [
    set size 6
    fruit-shape
    set label-color black
    ask fruits with [who = 1] [
      setxy (max-pxcor / 2) (max-pycor / 2)
      set label "Easy"
      ]
    ask fruits with [who = 2] [
      setxy (- max-pxcor / 2) (max-pycor / 2)
      set label "Medium"
      ]
    ask fruits with [who = 3] [
      setxy (max-pxcor / 2) (- max-pycor / 2)
      set label "Hard"
      ]
    ask fruits with [who = 4] [
      setxy (- max-pxcor / 2) (- max-pycor / 2)
      set label "Evil"
      ]
  ]
  ask patch 14 (max-pycor - 3) [
    sprout-popups 1 [
      set color white
      set label-color 0
      set label "CHOOSE YOUR MODE!"
    ]
  ]
  set mode? 1
  ;Hanna Yang 1/09/17
  ;Raunak 1/10/17 added more graphics
end

to wait-for-pick
  if count fruits = 3 [
    let n sum [who] of fruits ; fidhugre sou thwihc turtle died
    if n = 9 [
      set mode? "Easy"
      set bomb# 1000
      ask fruits [die]
      ask popups [die]
      ]
    if n = 8 [
      set mode? "Medium"
      set bomb# 500
      ask fruits [die]
      ask popups [die]
      ]
    if n = 7 [
      set mode? "Hard"
      set bomb# 250
      ask fruits [die]
      ask popups [die]
      ]
    if n = 6 [
      set mode? "Evil"
      set bomb# 10
      ask fruits [die]
      ask popups [die]
      ]
  ]
  ask fruits [
    rt 3
  ]
  ;Hanna Yang 1/09/17
  ;Raunak 1/10/17 added more graphics
end

to blade-cut
  ask patches with [next-stage < 0] [
    set pcolor white
    set next-stage 0
  ]
  animate-katana
  ;Raunak Chowdhury (over the break)
end

to animate-katana ;; Does the katana animation
  ifelse mouse-inside? and mouse-down?
  [
    katana
    ask blades [
      detect-combos ;
      kill-stuff ;kills fruits + fruits make fruit juice
      if ticks mod 8 = 7 [
        set og-heading heading ; stores heading for combos
      ]
    ]
  ]
  [
    ask blades [
      set time-stamps []
    ]
  ]
  ;Raunak Chowdhury (over the break)
end

to katana
   ask blades [
   face-right-direction  ; directiony stuff
    if ticks mod 2 = 0 [
      let x mouse-xcor
      let y mouse-ycor
      setxy x y
    ]
   if freezing? = "y" [set color sky - 2] ; turns blue when frozen banana is hit
    set pcolor katana-color
    ask patches in-radius 1.5 [
      set pcolor katana-color
      set next-stage 1
    ]
    american-katana
    n-katana "Sea"
    n-katana "Grass"
    freezing-katana
    godmode-katana
   ]
   ;Raunak Chowdhury (over the break)
   ;Hanna Yang 1/10/17 --> added "American"
   ;Hanna Yang 1/16 cleaned up code
end

to american-katana
  if katana-type = "American" [
    ask n-of one-of [ 1 2 ] patches in-radius 1.5 [set pcolor 15]
    ask n-of one-of [ 1 2 ] patches in-radius 1.5 [set pcolor 5]
  ]
  ;Hanna 1/14 (organization)
end

to n-katana [ktype]
  if katana-type = ktype [
    if ticks mod 4 = 0 [
      hatch-waters 2 [
        set size 3
        set shape "water"
        ifelse ktype = "Sea"
        [ set color 105 ]
        [ set color lime - 2]
        initialize-velocity-waters
      ]
    ]
  ]
  ;Hanna 1/16/17
end

to freezing-katana
  if freezing? = "y" and godmode? = false [
    ask patches in-radius 1.5 [
      set frozen-diffuse 1
    ]
  ]
  ;Hanna 1/14 (organization)
  ;Hanna 1/16/17 aesthetics
end

to godmode-katana
  if godmode? = true [
    ask patches in-radius 1.5 [
      set pcolor yellow
    ]
  ]
  ;Raunak 1/13
end

to katana-design
  if katana-type = "Sea" [set katana-color 93]
  if katana-type = "Grass" [set katana-color 61]
  if katana-type = "American" [set katana-color 105]
  ;Hanna Yang 1/10/17
end

to kill-stuff
  kill-arcade-bananas
  kill-fruits
  ask bombs in-radius 5 [
    ifelse godmode? = false[
      set lives -1 ; killing a bomb ends the game
                   ;Hanna Yang 1/05/17
    ]
    ;; Added godmode condition Raunak 1/13/17
    [
      set score score + (1 * score-multiplier) ;; If under godmode, will kill bombs and give points
      make-babies
      die
    ] ; killing a bomb ends the game
  ]
  ;Hanna Yang 1/05/17
end

to kill-arcade-bananas
  ask banas in-radius 5 [
    if banana-type = "doublept" [ ; gives 2X points
      set delay4 timer ;; Sets the effect at the time of slicing
      set notification "DOUBLE POINTS"
      banana-notifier ;; Notifies the player what type of banana they cut
      set score-multiplier 2
      make-babies
    ]
    if banana-type = "freeze" [ ; makes animation slower
      set delay4 timer
      set notification "FREEZE"
      set freezing? "y"
      banana-notifier
      make-babies
    ]
    if banana-type = "frenzy"[ ; makes fruits come out of both sides of the screen
      set delay4 timer
      set notification "FRENZY"
      banana-notifier
      set frenzy-switch true
      make-babies
    ]
  ]
  ;Raunak 1/10/17: double points, frenzy
  ;Hanna 1/10/17: freeze
end

to banana-notifier
  ask patch-at 0 0
  [
    sprout-popups 1 [
      set hidden? false
      set color white
      set label-color violet
      set label notification
      set delay2 ticks
      ]
  ]
  ;Raunak 1/10/17
  ;Hanna 1/14 editited for aesthetics
end

to kill-fruits
  let time-stamp [] ;; Will allow fruit to show when they were killed, in terms of ticks. This will help in determning combos that took place
  ask fruits in-radius 5 [
    set time-stamp lput ticks time-stamp
    set score score + (1 * score-multiplier)
    if godly? = "yes" [
      set godmode? true
      set god-delay timer
      god-mode-notification
    ] ;; Will cause the godmode effect to be activted for 10 sec if the player slices god fruit
  ]
  set time-stamps sentence time-stamps time-stamp
  ask fruits in-radius 5 [
    fruit-juice
    make-babies]
  ;Hanna Yang 1/05/17
  ;Raunak 1/06/17 added combo stuff
  ;RC 1/14 addded god mode
end

to god-mode-notification ;;Notifies the plauyer that they are in godmode
  ; Added by Raunak Chowdhury 1/13/17
  ifelse patch-at 0 4 = nobody
  [
    ask patch-at 0 -4[
      display-god-mode
    ]
  ]
  [
    ask patch-at 0 4 [
      display-god-mode
    ]
  ]
end

to display-god-mode
    sprout-popups 1 [
      set color white
      set label-color orange
      set label "GOD MODE ACTIVATED"
      set delay2 ticks
    ]
  ;HY 1/16 organization
end

to expire-effect ;; Turns off the banana effects
  if timer >= delay4 + 10 [
    set score-multiplier 1
    ask fruits with [frenzy? = "yes"] [die]
    ask fruits with [frozen? > 0 ] [
      set frozen? 0
      set v_x v_x * 16
      set v_y v_y * 8
      ]
    set g 0.05
    set freezing? "n"
    set frenzy-switch false
    ask blades [set color white]
  ]
  ;Raunak 1/10/17
  ;Hanna 1/11/17 made freeze stuff revert
end

to fruit-juice ;;Will cause the fruit to splash juice when it is sliced, which will go away after a while
 ask patches in-radius 3 [
   set pcolor [color] of myself
    set next-stage 2
    ]
 ;Raunak Chowdhury 1/07/16
 ;Hanna Yang --> added fade
end

to make-babies
  let baby-breed word shape "half"
  let n 2
  if shape = "grape" [ ; make hella grape babies
    set n 10
  ]
  hatch-fruit-babies n [
    set shape baby-breed
    initialize-velocity-fruit-babies] ;makes fruit babies
  die
;  Hanna Yang 1/03/17
;  Hanna Yang 1/14 edited for aesthetics
end

to detect-combos ;; Will determine whether or not combos took place
  if ticks mod 8 = 0 and (heading > (og-heading - 10) and heading < (og-heading + 10));; Will check every 8 ticks to see if a combo was being made (must be a "slice")
  [
    ifelse length time-stamps <= 2 ;; If less than or equal than two fruit were sliced, then the list will be cleared. Otherwise, it will move on to calculate the combo
    [ set time-stamps [] ]
    [ calculate-combos ]
  ]
  ;Raunak Chowdhury 1/03/16
  ;Hanna Yang --> added hading thing (1/07/17)
end

to calculate-combos ;; Will determine the combo amount and award that amount to the player. It will also create a popup in the world announcing the combo
  let combo-size length time-stamps
  set score score + combo-size * score-multiplier ;; Awards points for the combo
  ifelse patch-at 0 4 = nobody
  [
    ask patch-at 0 -4[
      display-fruit-combo
    ]
  ]
  [
    ask patch-at 0 4 [
      display-fruit-combo
    ]
    set time-stamps []
  ]
  ;Raunak Chowdhury 1/04/16
  ;RC 1/13/17 ; fixed bugs
  ;HY 1/15 edited code for speed
end

to display-fruit-combo
  let combo-size length time-stamps
  sprout-popups 1 [
    let starting-label word combo-size " FRUIT COMBO! " ;; Forms the beginning of the prompt
    let label-2 word starting-label "+"
    set hidden? false
    set color white
    set label-color red
    set label word label-2 combo-size
    set delay2 ticks
  ]
end

to face-right-direction
  let y mouse-ycor
  let x mouse-xcor
  facexy x y ; faces fowrads
  ;Hanna Yang 1/11/17
end



;END OF KATANA:

to make-stuff
  make-fruit
  make-bombs
  make-arcade-bananas
  make-godly-fruit
  if freezing? = "y" [
    frozen-mode
  ]
  ;Hanna Yang 1/11/17 - 1/12/17
end

to make-fruit
  ;makes fruits based on time
  let f round ticks / 100
  if delay > 30 [ set delay 1 ] ; creates a delay between the time fruits are released
  if count fruits = 0 [
    ; code that makes you wait n amount of time
    set delay delay + 1
    if delay > 30 [
      ifelse f < 5
      [
        ;when f < 4 make f fruits
        create-fruits f [
          set size 6
          fruit-shape
          setxy (random-range -10 10) min-pycor
          initialize-velocity
        ]
      ]
      [
        ;when f > 4, make 4 fruits
        create-fruits 4 [
          set size 6
          fruit-shape
          setxy (random-range -10 10) min-pycor
          initialize-velocity
        ]
      ]
    ]
    ; additional fruit for funsies :)
    if random 50 = 1 [
      create-fruits 1 [
        set size 6
        fruit-shape
        setxy random-xcor min-pycor
        initialize-velocity
      ]
    ]
  ]
  ;Hanna Yang (over the break)
end

to make-bombs
  if random bomb# = 0 [
    create-bombs 1 [
      set shape "bomb"
      setxy (random-range -10 10) min-pycor
      set size 6
      initialize-velocity
    ]
  ]
  ;Hanna Yang (over the break)
end


;;
;Banannas
;;


to make-arcade-bananas
  let n random 3
  if random 800 = 1 [
    if n = 0 [make-bananas "frenzy"]
    if n = 1 [make-bananas "freeze"]
    if n = 2 [make-bananas "doublept"]
  ]
  ;hanna 1/10/16
end

to make-bananas [identifier]
    create-banas 1 [
      set shape (word (word identifier "-") "banana")
      set heading 180
      setxy (random-range -10 10) min-pycor
      set size 8
      set banana-type identifier
      initialize-velocity
    ]
  ;Raunak Chowdhury 1/10/16
end



to fruit-frenzy ;; Will be the frenzy banana effect
  if frenzy-switch = true[
    if random 10 = 0 [
        create-fruits 1 [
          set size 6
          fruit-shape
          setxy (max-pxcor - 1.5) (random-range (min-pycor / 2) (max-pycor / 2))
          initialize-velocity-frenzy-fruit
          set frenzy? "yes"
        ]
    ]
    if random 10 = 0[
      create-fruits 1 [
        set size 6
        fruit-shape
        setxy (min-pxcor + 1.5) (random-range (min-pycor / 2) (max-pycor / 2))
        initialize-velocity-frenzy-fruit2
        set frenzy? "yes"
      ]
    ]
    if freezing? = "y" [
      frozen-mode
    ]
  ]
  ;Raunak Chowdhury 1/10/16
  ;hanna 1/10/16 --> freezing
end

to frozen-mode
    ask patches with [abs pycor = max-pycor or abs pxcor = max-pxcor] [
      set next-stage 1
      set pcolor sky + 3
      set frozen-diffuse 1.5
    ]
    diffuse next-stage 1
    diffuse frozen-diffuse 0.5
    ask patches with [ next-stage > 0 ] [ ;changes corners and katana
      set pcolor 109.9 - frozen-diffuse
    ]
    if ticks mod 50 = 0 [
      create-fruits 4 [ ; makes fruits....
        setxy (random 30 - 15) min-pycor + 2
        set size 6
        initialize-velocity
        fruit-shape
      ]
    ]
    ;Hanna Yang 1/11/17
end

to make-godly-fruit  ;; Raunak Chowdhury, 1/13/17
  if random 10000 = 0
  [
    create-fruits 1
    [
      set size 6
      setxy random-xcor min-pycor
      set shape "dragonfruit" ; "godly-fruit"
      set godly? "yes"
      set color yellow
      initialize-velocity
    ]
  ]
end

to fruit-shape
  set shape one-of [ "pomegranate" "grape" "orange" "strawberry" "pear" "watermelon"]
  initialize-fruits
  ;Hanna Yang (over the break) (added shapes later)
end

to initialize-fruits
  ask fruits [
    if shape = "pomegranate" [set color red + 1]
    if shape = "grape" [set color violet + 1]
    if shape = "orange" [set color orange + 1]
    if shape = "strawberry" [
      set color red + 2
      set size 4
      ]
    if shape = "pear" [set color lime + 1]
    if shape = "watermelon" [
      set color red + 1
      set size 10
    ]
  ]
  ;Hanna Yang (over the break)
end

to initialize-velocity
  set v_x random-range -0.6 0.6
  set v_y random-range 1.2 2
  ;Hanna Yang (over the break)
end

to initialize-velocity-fruit-babies
  set v_x random-range -0.6 0.6
  set v_y random-range -1 0.5
  ;Hanna Yang (over the break)
end

to initialize-velocity-frenzy-fruit ;left fruit
  set v_x random-range -1.2 -1.5
  set v_y random-range -1 1.7
  ;raunak 1/10/17
end

to initialize-velocity-frenzy-fruit2 ; right fruit
  set v_x random-range 1.2 1.5
  set v_y random-range -1 1.7
  ;raunak 1/10
end

to initialize-velocity-waters
  set v_x random-range -0.6 0.6
  set v_y random-range 0 -1
end

to-report random-range [r_1 r_2] ; gives a random number between r_1 and r_2 (r_2 > r_1)
  report random-float (r_2 - r_1) + r_1
  ;Hanna Yang (over the break)
end

to parabola ;makes fruits travel in parabola motion
  let slowdown 1
  let g? 1
  if freezing? = "y" [
    set slowdown (1 / 4)
    ifelse ticks mod 4 = 0
      [set g 0.05]
      [set g 0]
  ]
  ask turtles [
    if breed = fruits or breed = bombs or breed = fruit-babies or breed = banas or breed = waters [
      set v_y (v_y - (g * g?)) ; gravity makes you go faster down but doesnt change velocity in x direction
      move 0 (v_y * slowdown)
      move 90 (v_x * slowdown)
      set heading atan v_x  v_y ;so it looks like its turning
    ]
  ]
  ;Hanna Yang (over the break)
  ; added in freezing mode 1/13/17
end

to move [direction speed]
  set heading direction
  fd speed
  ;Hanna Yang (over the break)
end

to kill-useless-turtles
  fruits-die
  bombs&babies-die
  waters-die
  ;Hanna Yang 1/03/17
end

to fruits-die ;; Added godmode: Raunak Chowdhury 1/13/17
  ifelse godmode? = false [ ;;Determines if in godmode first, then acts
    ask fruits with [ycor < min-pycor + 2 and v_y < 0 and frenzy? = 0] [ ;; This will create the "X" seen in Fruit Ninja
      if frenzy? = 0 [
        set color red
        set size 6
        set shape "x"
        set delay5 timer
        set lives lives - 1
        stamp
        die
    ]
  ]
  ]
  [ ask fruits with [ycor < min-pycor + 2 and v_y < 0]
    [ die ] ;; If you are in godmode, you do not lose lives
  ]

  ask fruits with [abs xcor > max-pxcor or ycor < min-pycor + 0.5] [ ;fruits that should go off the screen
    die
  ]
  ask banas with [abs xcor > max-pxcor or ycor < min-pycor + 0.5] [ ;bananas that should go off the screen
    die
  ]
  ;Hanna Yang 1/03/17
end

to bombs&babies-die
  ask bombs with [ycor < min-pycor + 0.5 and v_y < 0 or abs xcor > max-pxcor ] [
    die
  ]
  ask fruit-babies with [ycor < min-pycor + 0.5 and v_y < 0 or abs xcor > max-pxcor ] [
    die
  ]
  ;Hanna Yang 1/03/17
end

to erase-combos
  if ticks = delay2 + 60 [
    ask popups [die]
  ]
  ;Hanna Yang 1/03/17
end

to waters-die
  if ticks mod 16 = 0 [
    ask waters [
      die
    ]
  ]
end

to erase-fails
  if timer >= delay5 + 1.5 [cd]
  ;RC 1/14
end

to expire-god-effect ;; Added by Raunak 1/13/17
  if timer >= god-delay + 10 [
    set godmode? false
  ]
end

to color-fade
  ask patches [
    ifelse next-stage >= 0.1 [
      set next-stage next-stage - 0.1
      let n pcolor + ((2 - next-stage) / 8)
      if n < (pcolor - (pcolor mod 10) + 10) [
        set pcolor n
      ]
    ]
    [
      set next-stage 0
      set pcolor white
      set frozen-diffuse 0
    ]
  ]
  ;Hanna Yang 1/03/17
end


                                  ;;ENDING THE GAME;;
;;;;;;;;;;;;;
;;;  htr  ;;;
;;;;;;;;;;;;;



to end-game ;; Will detect the message to be sent at the end of the game
  if Mode? = "Easy" [ easy-prompt ]
  if Mode? = "Medium" [ medium-prompt ]
  if Mode? = "Hard" [ hard-prompt ]
  if Mode? = "Evil" [ evil-prompt ]
  setup
  ;Raunak Chowdhury 1/05/17
end

to easy-prompt
  if score < 25 [ user-message "Game over! Hanna says: 'F-: Go find another home'" ]
  if score >= 25 and score < 75 [ user-message "Game over! Hanna says: 'Asian Fail'" ]
  if score >= 75 [ user-message "Game over! Hanna gives you a Seal of Approval" ]
  ;Raunak Chowdhury 1/05/17
end

to medium-prompt
  if score < 150 [ user-message "Game over! Hanna says: 'F-: Go find another home'" ]
  if score >= 150 and score < 300 [ user-message "Game over! Hanna says: 'Asian Fail'" ]
  if score >= 300 [ user-message "Game over! Hanna gives you a Seal of Approval" ]
  ;Raunak Chowdhury 1/05/17
end

to hard-prompt
  if score < 400 [ user-message "Game over! Hanna says: 'F-: Go find another home'" ]
  if score >= 400 and score < 1000 [ user-message "Game over! Hanna says: 'Asian Fail'" ]
  if score >= 1000 [ user-message "Game over! Hanna gives you a Seal of Approval" ]
  ;Raunak Chowdhury 1/05/17
end

to evil-prompt
  if score < 15000 [ user-message "Game over! Hanna says: 'F-: Go find another home'" ]
  if score >= 15000 and score < 100000 [ user-message "Game over! Hanna says: 'Asian Fail'" ]
  if score = "Patrick" [ user-message "Game over! Hanna gives you a Seal of Approval" ]
  ;Raunak Chowdhury 1/05/17
end
@#$#@#$#@
GRAPHICS-WINDOW
230
10
728
529
30
30
8.0
1
24
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
30.0

BUTTON
104
37
170
70
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
103
74
158
107
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

MONITOR
745
37
802
82
NIL
lives
17
1
11

MONITOR
745
84
831
129
NIL
score
17
1
11

CHOOSER
68
124
206
169
katana-type
katana-type
"Sea" "Grass" "American"
0

@#$#@#$#@
## WHAT IS IT?
This is an emulation of the long-renowned game, Fruit Ninja, in Classic Mode. However, to spice things up a little, a series of modifications have been added, such as the inclusion of four different difficulties, the inclusion of Arcade Bananas, and a new type of fruit called God Fruit (represented by a dragonfruit).

## HOW IT WORKS

When you press "setup," followed by "go," you find a screen with four floating fruits and a prompt for you to choose the mode (the difficulty) at which you will be playing at.

Once you slice a fruit with your chosen difficulty, a game of Fruit Ninja will start. Fruit will be thrown up by the game master, Hanna, at random intervals, and you must slice it. Combos and bombs are self-explanatory.

Furthermore, we have added some special modifications to this version of Fruit Ninja, one of which being the inclusion of the traditional Arcade bananas (Freeze, Double Points, and Frenzy) in this emulation of Classic Mode. Be aware, though, that slicing these fruits is completely optional, and missing any fruit created by these bananas (and the bananas themselves) will have no effect on your score.

You also have the option of changing your katana design. Multiple designs exist, and they can be accessed from the Interface.

## HOW TO USE IT

You first press the setup button, followed by the go button. Note that you can change your katana design anytime.

You control the katana using the mouse. To slice fruit, left-click with your mouse, and drag it across the world. Your score and your lives are listed on the right of the world, in monitors.

## THINGS TO NOTICE

There are several elements of this game that should be noticed during your playthroughs, and are orgnaized roughly into several categories:
-Bombs & Modes
-Combos
-Arcade bananas
-God Fruit

### BOMBS & MODES

When you first start up the game, you encounter a selection screen with four different modes: Easy, Medium, Hard, and Evil. Successively higher difficulties will determine the probability of bombs appearing, with "Easy" having the least probability of bombs appearing and "Evil" having the most. You can test this yourself by going into Easy Mode, and then going on Evil Mode. The difference in the amount of bombs appearing in each of these respective modes is very apparent.

### COMBOS

One of the most important features of Fruit Ninja and this iteration of Fruit Ninja is combos— that is, the amount of fruit you slice in succession. This version of Fruit Ninja checks to see the number of fruit you sliced every 8 ticks, and (much like the original game) will award you with extra points, calculated by the number of fruit you sliced in a row (this is done by recording thre fruit sliced in a list). When you make a combo, a message will appear above your katana, stating the amount of fruit that you sliced in succession.

### ARCADE BANANAS

To make this verson of Fruit Ninja a memorable experience, this game deviates from Classic Mode to incorperate Arcade Bananas from the Arcade Mode. The three bananas from Arcade Mode are availible to be sliced, and will grant bonuses that can help you gain extra points. One thing to note about the Frenxzy Banana: any fruit that is missed and was created by the Frenzy effect will NOT affect the number of lives you have.

### GOD FRUIT

The God Fruit is a sliciable fruit that is exclusive to this iteration of Fruit Ninja. This fruit has a very rare chance of appearing, but if sliced, the God Fruit will grant you God Mode for 10 seconds. God Mode is a state of invincibility; your lives are not subtracted if you miss fruit while you are in this state. Likewise, you are not affected by slicing bombs; rather, you can actually SLICE THROUGH BOMBS and get points from slicing them. However, do note that you cannot combo with bombs; if you slice through three bombs in a row, you will not be awarded a combo. Moreover, if you slice through several fruit and a bomb, your combo will be based on the fruit; the bomb is disregarded.

## THINGS TO TRY

One variable that controls the arc of the fruit is g, gravity. Try increasing or decreasing it and observe how your modification changes the arc of the fruit. Has it become easier to slice? Harder to slice?

Commenting out "and mouse-down?" will allow your mouse to always be in the slice fruit mode.

## PROJECT BREAKDOWN

Katana Animation: Raunak Chowdhury
Physics Engine: Hanna Yang
Bombs: Hanna Yang
Combos: Raunak Chowdhury and Hanna Yang
Modes: Raunak Chowdhury
Double Point Bananas: Raunak Chowdhury
Frenzy Bananas: Raunak Chowdhury
Freeze Banana: Hanna Yang
Mode Selection Screen: Hanna Yang
God Fruit Mode: Raunak Chowdhury
Art: Hanna Yang

## CREDITS AND REFERENCES

Created by:
Raunak Chowdhury
Hanna Yang

Based on: Fruit Ninja (Halfbrick)

MKS21 Period 4
Mr. Konstantinovich
Intro CS 1
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

banana
true
0
Polygon -1184463 true false 195 8 212 19 195 36 186 66 160 98 143 131 139 155 145 188 159 212 178 227 198 230 214 234 227 242 230 257 217 269 196 277 124 274 82 248 62 217 53 151 73 97 111 42 144 29 182 25
Polygon -6459832 true false 181 22 196 37 215 19 196 7

bomb
true
7
Circle -16777216 true false 8 23 283
Polygon -2674135 true false 240 135 195 90 60 225 105 270
Polygon -2674135 true false 60 105 90 75 240 225 195 270
Polygon -16777216 true false 105 15 120 45 180 45 195 15
Polygon -7500403 true false 135 15 148 5 162 5 180 20 225 15 251 7 263 7 265 15 237 23 205 31 180 28 164 19 155 15
Polygon -955883 true false 253 20 273 22 279 16 276 5 244 5 250 20

bombhalf
true
7
Polygon -16777216 true false 148 284 81 259 36 200 31 157 34 108 110 41 149 38
Polygon -2674135 true false 147 127 112 87 90 118 145 162 93 188 113 230 150 187

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
true
0
Circle -7500403 false true 0 0 300
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

doublept-banana
true
0
Polygon -13840069 true false 194 10 211 21 194 38 185 68 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 110 44 143 31 181 27
Polygon -6459832 true false 179 24 194 39 213 21 194 9
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -14835848 true false 138 159 57 198 62 225 86 252 146 184
Polygon -14835848 true false 158 99 63 120 51 150 108 132 141 132
Polygon -11221820 true false 187 65 110 43 88 76 145 72 170 85
Polygon -14835848 true false 187 65 110 43 88 76 145 72 170 85
Polygon -14835848 true false 159 214 147 243 125 276 182 272 179 228

doublept-bananahalf
true
0
Polygon -13840069 true false 107 122 108 122 111 121 125 120 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 83 115 105 120 107 121
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -14835848 true false 138 159 57 198 62 225 86 252 146 184
Polygon -14835848 true false 159 214 147 243 125 276 182 272 179 228
Polygon -1184463 true false 73 100 83 117 111 122 128 120 156 101 146 91 134 88 124 87 101 88 84 93
Polygon -6459832 true false 97 106 94 107 101 106 99 108

dragonfruit
true
0
Polygon -5825686 true false 150 285 195 270 219 262 232 241 241 222 261 202 276 187 252 189 232 199 251 172 251 155 247 131 239 120 209 82 193 68 170 59 168 55 164 41 175 14 182 3 161 15 160 4 141 1
Polygon -5825686 true false 151 285 106 270 82 262 69 241 60 222 40 202 25 187 49 189 69 199 50 172 50 155 54 131 62 120 92 82 108 68 131 59 133 55 137 41 126 14 119 3 140 15 141 4 160 1
Polygon -10899396 true false 230 239 231 201 256 187 278 185 262 200 249 214 233 243
Polygon -10899396 true false 70 239 69 201 44 187 22 185 38 200 51 214 67 243
Polygon -10899396 true false 217 134 218 96 236 81 247 55 249 95 236 109 240 124
Polygon -10899396 true false 241 182 242 144 263 128 275 107 273 143 260 157 244 186
Polygon -10899396 true false 59 182 58 144 37 128 25 107 27 143 40 157 56 186
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 118 94 117 56 99 41 88 15 86 55 99 69 95 84
Polygon -10899396 true false 137 41 125 17 117 6 108 5 117 1 128 3 138 13 140 17 140 7 140 1 158 0 162 16 169 10 180 3 204 7 186 10 174 28 168 42 168 55 155 27 151 18 146 29 136 20
Polygon -10899396 true false 182 94 183 56 201 41 212 15 214 55 201 69 205 84
Polygon -10899396 true false 92 245 82 217 82 192 86 187 101 166 103 158 117 186 120 205 113 220 112 241 102 248 99 234
Polygon -10899396 true false 143 274 133 246 133 221 137 216 152 195 154 187 168 215 171 234 164 249 163 270 153 277 150 263
Polygon -10899396 true false 203 226 193 198 193 173 197 168 212 147 214 139 228 167 231 186 224 201 223 222 213 229 210 215
Polygon -10899396 true false 121 167 111 139 111 114 115 109 130 88 132 80 146 108 149 127 142 142 141 163 131 170 128 156
Polygon -10899396 true false 166 159 156 131 156 106 160 101 175 80 177 72 191 100 194 119 187 134 186 155 176 162 173 148

dragonfruithalf
true
0
Polygon -5825686 true false 151 285 106 270 82 262 69 241 60 222 40 202 25 187 49 189 69 199 50 172 50 155 54 131 62 120 92 82 108 68 131 59 133 55 137 41 126 14 119 3 140 15 141 4 160 1
Polygon -10899396 true false 70 239 69 201 44 187 22 185 38 200 51 214 67 243
Polygon -10899396 true false 59 182 58 144 37 128 25 107 27 143 40 157 56 186
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 83 134 82 96 64 81 53 55 51 95 64 109 60 124
Polygon -10899396 true false 118 94 117 56 99 41 88 15 86 55 99 69 95 84
Polygon -10899396 true false 137 41 125 17 117 6 108 5 117 1 128 3 138 13 140 17 140 7 140 1 158 0 162 16 169 10 180 3 204 7 186 10 174 28 168 42 168 55 155 27 151 18 146 29 136 20
Polygon -10899396 true false 92 245 82 217 82 192 86 187 101 166 103 158 117 186 120 205 113 220 112 241 102 248 99 234
Polygon -10899396 true false 121 167 111 139 111 114 115 109 130 88 132 80 146 108 149 127 142 142 141 163 131 170 128 156
Polygon -1 true false 156 36 163 26 160 29 157 99 153 199 152 283 145 255 144 183 147 145 152 96 155 44
Polygon -1 true false 158 36 167 44 171 80 168 121 168 150 168 180 168 210 167 236 150 282
Polygon -16777216 true false 153 243 154 233 158 235
Polygon -16777216 true false 149 217 150 207 154 209
Polygon -16777216 true false 156 197 157 187 161 189
Polygon -16777216 true false 159 166 160 156 164 158
Polygon -16777216 true false 149 179 150 169 154 171
Polygon -16777216 true false 159 166 160 156 164 158
Polygon -16777216 true false 161 132 164 133 162 129 156 130
Polygon -16777216 true false 154 148 154 143 160 143 152 148
Polygon -16777216 true false 154 148 154 143 160 143 152 148
Polygon -16777216 true false 161 132 164 133 164 125 156 130
Polygon -16777216 true false 163 131 164 133 164 125 156 130
Polygon -16777216 true false 157 118 158 111 160 114

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

freeze-banana
true
0
Polygon -13791810 true false 194 10 211 21 194 38 185 68 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 110 44 143 31 181 27
Polygon -6459832 true false 179 24 194 39 213 21 194 9
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -11221820 true false 158 99 63 120 51 150 108 132 141 132
Polygon -11221820 true false 187 65 110 43 88 76 145 72 170 85
Polygon -11221820 true false 187 65 110 43 88 76 145 72 170 85
Polygon -11221820 true false 159 214 147 243 125 276 182 272 179 228

freeze-bananahalf
true
0
Polygon -13791810 true false 107 122 108 122 111 121 125 120 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 83 115 105 120 107 121
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -11221820 true false 159 214 147 243 125 276 182 272 179 228
Polygon -1184463 true false 73 100 83 117 111 122 128 120 156 101 146 91 134 88 124 87 101 88 84 93
Polygon -6459832 true false 97 106 94 107 101 106 99 108

frenzy-banana
true
0
Polygon -955883 true false 194 10 211 21 194 38 185 68 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 110 44 143 31 181 27
Polygon -6459832 true false 179 24 194 39 213 21 194 9
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -2674135 true false 138 159 57 198 62 225 86 252 146 184
Polygon -2674135 true false 158 99 63 120 51 150 108 132 141 132
Polygon -11221820 true false 187 65 110 43 88 76 145 72 170 85
Polygon -2674135 true false 187 65 110 43 88 76 145 72 170 85
Polygon -2674135 true false 159 214 147 243 125 276 182 272 179 228

frenzy-bananahalf
true
0
Polygon -955883 true false 107 122 108 122 111 121 125 120 159 100 142 133 138 157 144 190 158 214 177 229 197 232 213 236 226 244 229 259 216 271 195 279 123 276 81 250 61 219 52 153 72 99 83 115 105 120 107 121
Polygon -11221820 true false 138 159 57 198 62 225 86 252 146 184
Polygon -2674135 true false 138 159 57 198 62 225 86 252 146 184
Polygon -2674135 true false 159 214 147 243 125 276 182 272 179 228
Polygon -1184463 true false 73 100 83 117 111 122 128 120 156 101 146 91 134 88 124 87 101 88 84 93
Polygon -6459832 true false 97 106 94 107 101 106 99 108

grape
true
0
Polygon -13840069 true false 150 75 165 45 195 30 195 60 150 90 150 75
Polygon -6459832 true false 135 75 135 60 135 45 150 45 150 75 150 90 135 90 135 75
Circle -8630108 true false 60 60 90
Circle -7500403 false true 116 116 67
Circle -8630108 true false 131 71 67
Circle -8630108 true false 108 108 85
Circle -8630108 true false 144 174 42
Circle -8630108 true false 71 116 67
Circle -8630108 true false 86 161 67
Circle -8630108 true false 129 204 42

grapehalf
true
0
Circle -8630108 true false 105 105 90

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

orange
true
0
Circle -955883 false false 30 30 240
Circle -955883 true false 29 29 242
Polygon -14835848 true false 150 30 135 15 120 15 108 12 91 15 64 25 41 32 53 47 96 64 118 49 131 46 150 30
Polygon -14835848 true false 150 30 165 15 180 15 192 12 209 15 236 25 259 32 247 47 204 64 182 49 169 46 150 30

orangehalf
true
0
Polygon -14835848 true false 150 70 153 36 128 17 107 12 81 11 82 36 90 49
Polygon -955883 true false 150 60 150 285 95 273 76 259 62 229 46 197 45 167 41 126 66 86 129 51
Polygon -1184463 true false 138 201 84 230 98 257 131 267 141 269
Polygon -1184463 true false 136 190 76 219 62 190 62 162 68 144
Polygon -1184463 true false 112 99 82 103 71 130 129 177 113 102
Polygon -1184463 true false 133 81 120 100 139 176

pear
true
0
Polygon -10899396 true false 148 288 189 280 210 266 225 248 235 229 237 212 234 192 220 173 205 158 194 146 184 133 178 118 177 101 181 82 182 63 176 47 158 43 145 41
Polygon -10899396 true false 149 288 108 280 87 266 72 248 62 229 60 212 63 192 77 173 92 158 103 146 113 133 119 118 120 101 116 82 115 63 121 47 139 43 152 41
Polygon -10899396 true false 149 288 108 280 87 266 72 248 62 229 60 212 63 192 77 173 92 158 103 146 113 133 119 118 120 101 116 82 115 63 121 47 139 43 152 41
Polygon -10899396 true false 149 288 108 280 87 266 72 248 62 229 60 212 63 192 77 173 92 158 103 146 113 133 119 118 120 101 116 82 115 63 121 47 139 43 152 41
Polygon -6459832 true false 139 44 140 16 158 17 156 51
Polygon -14835848 true false 152 48 168 35 183 24 203 27 219 37 235 55 214 62 195 62 180 58

pearhalf
true
0
Polygon -10899396 true false 148 288 189 280 210 266 225 248 235 229 237 212 234 192 220 173 205 158 194 146 184 133 178 118 177 101 181 82 182 63 176 47 158 43 145 41
Polygon -6459832 true false 144 45 145 17 163 18 161 52
Polygon -14835848 true false 152 48 168 35 183 24 203 27 219 37 235 55 214 62 195 62 180 58
Polygon -1 true false 146 45 138 58 131 111 129 191 131 242 134 269 150 289
Polygon -16777216 true false 140 184 138 202 140 218 144 196
Polygon -16777216 true false 133 184 131 202 133 218 137 196

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

pomegranate
true
0
Circle -2674135 true false 44 59 212
Polygon -2674135 true false 120 45 105 30 135 45 150 30 165 45 195 30 180 60 120 45
Polygon -2674135 true false 120 45 120 75 180 75 180 60 120 45
Line -2674135 false 180 60 165 60
Line -2674135 false 120 45 180 60

pomegranatehalf
true
0
Polygon -2674135 true false 150 60 150 285 102 273 72 251 52 223 40 186 45 141 58 102 119 65
Polygon -2674135 true false 151 80 131 80 130 55 102 44 113 40 116 30 143 35 152 24
Circle -2674135 true false 146 120 18
Circle -2674135 true false 146 135 18
Circle -2674135 true false 144 153 18
Circle -2674135 true false 155 149 18
Circle -2674135 true false 146 170 18
Circle -2674135 true false 146 170 18
Circle -2674135 true false 146 223 18
Circle -2674135 true false 160 181 18
Circle -2674135 true false 147 208 18
Circle -2674135 true false 156 198 18
Circle -2674135 true false 146 188 18
Circle -2674135 true false 158 163 18

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

strawberry
true
0
Polygon -2674135 true false 72 47 38 88 34 139 85 245 122 289 150 281 164 288 194 288 239 228 284 123 267 65 225 46 193 39 149 48 104 38
Polygon -10899396 true false 136 62 91 62 136 77 136 92 151 122 166 107 166 77 196 92 241 92 226 77 196 62 226 62 241 47 166 57 136 32

strawberryhalf
true
0
Polygon -10899396 true false 145 82 128 39 163 52 176 24 183 56 222 41
Polygon -2674135 true false 156 73 105 59 74 59 58 84 40 113 50 184 97 244 148 274 161 270 176 274 198 264 256 183 256 122 247 61
Polygon -2064490 true false 107 94 96 103 72 141 144 214 168 244 216 115
Polygon -1 true false 154 143 127 125 127 162 161 199 169 129 155 144

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

water
true
0
Polygon -7500403 true true 153 73 192 143 203 182 196 209 186 217 150 237 148 60
Polygon -11221820 true false 147 73 108 143 97 182 104 209 114 217 150 237 152 60
Polygon -7500403 true true 147 73 108 143 97 182 104 209 114 217 150 237 152 60

watermelon
true
0
Polygon -10899396 true false 147 290 186 280 212 258 223 240 231 207 234 181 235 146 233 107 222 86 212 62 185 41 149 27
Polygon -10899396 true false 153 290 114 280 88 258 77 240 69 207 66 181 65 146 67 107 78 86 88 62 115 41 151 27
Polygon -13840069 true false 149 29 106 67 95 117 95 157 96 204 107 246 126 260 110 230 103 192 102 152 105 116 108 80 126 57
Polygon -13840069 true false 148 288 135 250 131 202 134 170 147 115 143 170 136 209 139 251
Polygon -13840069 true false 153 52 169 113 158 166 151 199 173 136 179 100
Polygon -13840069 true false 195 157 159 213 161 251 167 276 165 223 168 208
Polygon -13840069 true false 191 77 199 110 196 148 194 188 186 198 202 189 202 141 207 100 182 63
Polygon -13840069 true false 188 262 214 218 219 176 220 140 225 179 222 204 221 227

watermelonhalf
true
0
Polygon -10899396 true false 150 45 150 285 83 264 53 233 40 184 33 131 60 92 96 63 149 21
Polygon -1 true false 148 53 80 100 55 137 66 215 88 252 148 272
Polygon -2674135 true false 149 62 96 115 69 139 77 199 95 229 150 258
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 155 135 173 139 168
Polygon -16777216 true false 133 117 135 135 139 130
Polygon -16777216 true false 109 193 111 211 115 206
Polygon -16777216 true false 103 155 105 173 109 168
Polygon -16777216 true false 133 206 135 224 139 219

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
NetLogo 5.3.1
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
