; Updated 28.10.2018 by Ladislav, Q5127950@live.tees.ac.uk
; Introduced assexual breeding to infetion spreading, added logging


;  !!! Description outdated !!!
;  Patch/human state properties:
;  - Healthy   (green): Can be infected by surrounding
;                       infected individuals
;
;  - Infected (orange): Infected individuals can be treated,
;                       if not cured they will die within
;                       a specified period of fatality.
;
;  - Treated  (yellow): Treatment takes set amount of time plus
;                       time individual had befre infection kills
;                       him. Treated individuals have a chance to
;                       turn back into a healthy individual
;                       or die due unsucces of the treatment.
;
;  - Dead      (black): Represents an empty human spot, after
;                       certain time a healthy individual
;                       takes its place. Cannot get infected.

__includes [ "breeding.nls" "logg.nls" ]

; ***********
; * GLOBALS *
; ***********
patches-own [ state age genome infected_time revive_timer ]
globals
[ target_x
  target_y
  total_death_count
  infection_death_count
  natural_death_count
  treatment_genome
]


; **************
; * PROCEDURES *
; **************
; <<General Procedures>>
to set-up
  clear-all
  reset-ticks
  ask patches
  [ spawn-human
    set age ( random max_human_life_length - 350 )
  ]
end

to go
  if (ticks mod new_treatment_introduction_rate) = 0
  [ set treatment_genome generate-genome ]       ; Introduce new tretment among the population

  ask patches
  [ set age age + 1
    ifelse age = max_human_life_length [ kill-human ]
    [if age >= max_human_life_length - 40        ; Simulates natural death occurence
      [if random 16 > 14                         ; Current values randomly selected
        [ kill-human
          set natural_death_count natural_death_count + 1
        ]
      ]
    ]

    if state = "dead"
    [ if revive_patches = true
      [ ifelse revive_timer > 0
       [ set revive_timer revive_timer - 1 ]
       [ spawn-human ]
      ]
    ]

    if state = "infected"
    [ ifelse  infected_time < infection_fatality_time
      [ set infected_time infected_time + 1 ]    ; Increment infected time countdown value
      [ kill-human                               ; Infection not treated for too long it became fatal
        set infection_death_count  infection_death_count + 1
      ]
    ]

  ]

  spread-infection
  if treat_infected = true [ apply-treatment ]
  tick
end

; <<Infection Procedures>>
to spread-infection
  ask patches
  [ if state = "infected"
    [ if random 101 < infection_spread_rate
      [ ask one-of neighbors
        [ let legacy_gen genome
          if random 101 < mutation_chance      ; Infection genome has a chance to mutate
          [ set legacy_gen change-random-bit-n-times genome 1 + random (genome_length - 1) ]

          ifelse state = "healthy"             ; Spread infection on a healthy idividual
          [ infect-human legacy_gen ]
          [ if state = "treated"               ; If
            [ let comparitor (list)                                          ;;Declare new empty list
              set comparitor (map = genome treatment_genome)               ;;Compare each bit of the malaria genome to the treatment and put the true/false result in the new list
              if (( length filter [ i -> i = true ] (comparitor) / length comparitor ) * 100 )  < treatment_succes_rate  ;;If the difference is > than the treatment effectiveness slider, kill the malaria (set colour to red)
              [ infect-human legacy_gen ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to infect-random                                ; Infect a random human patch
  ask one-of patches [ infect-human generate-genome ]
end

to infect-patchxy [x y]                         ; Infect specified human patch
  ask patch x y [ infect-human generate-genome ]
end

to infect-human [ gen ]                         ; Infects human with specified genome
  set state "infected"
  set pcolor 15
  set genome gen
  if pxcor mod 2 = 0 [ set pcolor 14 ]
  if pycor mod 2 = 0 [ set pcolor 14 ]
  if pxcor mod 2 = 0 and pycor mod 2 = 0 [ set pcolor 15]
  show "infected"
end

; <<Treatment Procedures>>
to apply-treatment                              ; Apply treatment
  ask patches
  [ if state = "infected"
    [ let comparitor (list)                                          ;;Declare new empty list
        set comparitor (map = genome treatment_genome)               ;;Compare each bit of the malaria genome to the treatment and put the true/false result in the new list
        if (( length filter [ i -> i = true ] (comparitor) / length comparitor ) * 100 )  < treatment_succes_rate  ;;If the difference is > than the treatment effectiveness slider, kill the malaria (set colour to red)
        [ treat-human  ]
    ]
  ]
end

to treat-human                                  ; Treat specified human patch
  set state "treated"
    set infected_time 0
    set genome treatment_genome
    set pcolor 96
    if pxcor mod 2 = 0 [ set pcolor 95 ]
    if pycor mod 2 = 0 [ set pcolor 95 ]
    if pxcor mod 2 = 0 and pycor mod 2 = 0 [ set pcolor 96]
    show "treated"
end

; <<Human Procedures>>
to spawn-human                                  ; Spawn a healthy individual
  set state "healthy"
  set pcolor 64
  if pxcor mod 2 = 0 [ set pcolor 63 ]
  if pycor mod 2 = 0 [ set pcolor 63 ]
  if pxcor mod 2 = 0 and pycor mod 2 = 0 [ set pcolor 64 ]
  set revive_timer respawn_delay
  set infected_time 0
end

to kill-human                                   ; Modifies patch to "dead" state
  set total_death_count total_death_count + 1
  set state "dead"
  set age 0
  set revive_timer respawn_delay         ; reset timers
  set pcolor 1
end


; *************
; * REPORTERS *
; *************

to-report report-state-from [y x]
  report [state] of patch x y
end

to-report report-age-from [y x]
  report [age] of patch x y
end

to-report report-genome-from [y x]
  report [genome] of patch x y
end

to-report report-treatment-genome
  report treatment_genome
end

to-report generate-genome                       ; Generate a random binary genome that is as long as specified by the genome_count global
  let new-genome (list)                         ; Make a new list to store the genome bits
  loop
  [ if length new-genome = genome_length [ report new-genome ]
    set new-genome lput random 2 new-genome
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
279
14
820
556
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

SLIDER
22
328
259
361
infection_fatality_time
infection_fatality_time
50
500
170.0
1
1
ticks
HORIZONTAL

SLIDER
22
165
258
198
treatment_succes_rate
treatment_succes_rate
1
100
11.0
1
1
%
HORIZONTAL

SLIDER
22
206
258
239
infection_spread_rate
infection_spread_rate
0
10
8.0
1
1
NIL
HORIZONTAL

SWITCH
870
499
1077
532
fatality_scaling_on
fatality_scaling_on
1
1
-1000

TEXTBOX
871
451
1067
511
Should the probability of death increase ovetime?\n(5% every tick) *IN PROGRESS*
12
15.0
1

BUTTON
22
69
261
102
Infect
infect-random
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
22
15
105
48
Set-up
set-up
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
115
15
182
48
Start
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
192
15
261
48
Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
344
565
404
610
Target Y
target_y
17
1
11

MONITOR
280
565
340
610
Target X
target_x
17
1
11

BUTTON
410
577
512
610
Obtain target
if mouse-down?\n[ set target_x (round mouse-xcor )\n  set target_y (round mouse-ycor )\n ]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
24
445
260
478
respawn_delay
respawn_delay
0
200
0.0
1
1
ticks
HORIZONTAL

TEXTBOX
28
413
253
443
Time delay before a new human re-spawns in place of a dead one
12
0.0
0

BUTTON
604
577
689
610
Infect target
ask patch target_x target_y \n[ infect-human generate-genome]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1009
15
1088
60
Sate
report-state-from mouse-xcor mouse-ycor
17
1
11

SWITCH
24
560
261
593
revive_patches
revive_patches
0
1
-1000

TEXTBOX
26
528
256
573
Should the dead patches be replaced with new humans?
12
0.0
1

MONITOR
947
15
1004
60
Age
report-age-from mouse-xcor mouse-ycor
17
1
11

SLIDER
22
287
259
320
max_human_life_length
max_human_life_length
1200
2400
1700.0
1
1
ticks
HORIZONTAL

SWITCH
24
486
260
519
treat_infected
treat_infected
1
1
-1000

BUTTON
517
577
600
610
Treat target
ask patch target_x target_y [ treat-human ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
846
217
1131
407
Mortality rate
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot total_death_count"
"Infection" 1.0 0 -5298144 true "" "plot infection_death_count"
"Natural" 1.0 0 -15637942 true "" "plot natural_death_count"

MONITOR
836
15
886
60
 X
round mouse-xcor
17
1
11

MONITOR
891
15
941
60
 Y
round mouse-ycor
17
1
11

MONITOR
836
67
1293
112
Infection Genome
report-genome-from mouse-xcor mouse-ycor
17
1
11

MONITOR
838
119
1294
164
Current Anti-genome treatment
report-treatment-genome
17
1
11

SLIDER
22
370
260
403
genome_length
genome_length
8
32
32.0
1
1
NIL
HORIZONTAL

SLIDER
22
125
258
158
new_treatment_introduction_rate
new_treatment_introduction_rate
1
1000
700.0
1
1
ticks
HORIZONTAL

SLIDER
22
246
259
279
mutation_chance
mutation_chance
0
100
4.6
0.1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.0.4
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