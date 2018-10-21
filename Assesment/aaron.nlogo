;;Solution for modeling Malaria mutations and treatment in NetLogo
;;Last updated 17/10/2018 by Aaron Walker - Q5045715

patches-own [ genome state ]                                     ;;Patches own a list of bits representing a binary genome and a state
globals [ mal-genome treatment-genome attribute-1 attribute-2 attribute-3 attribute-4 ]

to setup
  clear-all
  reset-ticks
  setup-patches
  set treatment-genome generate-genome
end

to setup-patches                                                 ;;Colour patches in a grid formation so they are easier to see, generate a random genome for each patch
  ask patches
  [ set genome generate-genome                                   ;;Generate a random genome
    set state "alive"                                            ;;Set the initial state of the malaira to 'alive'
  ]
  colour-grid
end

to colour-grid
  ask patches
  [ if state = "alive"
    [ set pcolor 2
      if pxcor mod 2 = 0 [ set pcolor 3 ]
      if pycor mod 2 = 0 [ set pcolor 4 ]
      if pxcor mod 2 = 0 and pycor mod 2 = 0 [ set pcolor 2 ]
    ]
  ]
end

to-report generate-genome                                        ;;Generate a random binary genome that is as long as specified by the genome-count global
  let new-genome (list)                                          ;;Make a new list to store the genome bits
  loop
  [ if length new-genome = genome-length [ report new-genome ]
    set new-genome lput random 2 new-genome
  ]
end

to mouse-update
  ask patch mouse-xcor mouse-ycor [ set mal-genome genome ]      ;;Update "selected genome" monitor
  ask patch mouse-xcor mouse-ycor [ set attribute-1 sublist genome 0 8 ]      ;;Update "attribute-1" monitor
  ask patch mouse-xcor mouse-ycor [ set attribute-2 sublist genome 8 16 ]      ;;Update "attribute-2" monitor
  ask patch mouse-xcor mouse-ycor [ set attribute-3 sublist genome 16 24 ]      ;;Update "attribute-3" monitor
  ask patch mouse-xcor mouse-ycor [ set attribute-4 sublist genome 24 32 ]      ;;Update "attribute-4" monitor

  if mouse-down?
  [ ask patch mouse-xcor mouse-ycor [ reproduce-mal ]            ;;Kill malaria patch when clicked and generate a new genome
  ]
end

to go                                                            ;;Start the kill/reproduce cycle of the malaria cells
  apply-treatment
  colour-grid
  if ( count patches with [ state = "dead" ] = 0 ) [ stop ]      ;;Stop the 'go' button if the system has completed running
  replace-dead
end

to-report get-neighbor-genome                                    ;;Get the genome of a random neighbor malaria parasite
  let neighbor-genome ""
  ask one-of neighbors [ set neighbor-genome genome ]
  report neighbor-genome
end

to reproduce-mal                                                 ;;Get a random neighbor malaria to asexually reproduce with a chance of mutation
  let res ""                                                     ;;Declare empty string
  ifelse kill                                                    ;;If kill switch active
  [ set res get-neighbor-genome ]                                ;;Perform mutation on neighbor genome (kill and reproduce)
  [ set res genome ]                                             ;;Else perform mutation on own genome (mutate)

  set genome map                                                 ;;Set current genome to results of...
  [ gen -> ifelse-value (random-float 100.0 < mutation)          ;;If random number is less than mutation value (of each bit in genome)
    [ 1 - gen ]                                                  ;;Value if true
    [ gen ]                                                      ;;Value if false
  ] res                                                          ;;Run map on random neighbor(8) genome or current genome (Dependant on kill switch)
end

to apply-treatment                                               ;;Apply the treatment to the existing malaria and kill any that don't survive (set colour to red)
  let comparitor (list)                                          ;;Declare new empty list
  ask patches
  [ set comparitor (map = genome treatment-genome)               ;;Compare each bit of the malaria genome to the treatment and put the true/false result in the new list
    if (( length filter [ i -> i = true ] (comparitor) / length comparitor ) * 100 )  < treatment-effectiveness  ;;If the difference is > than the treatment effectiveness slider, kill the malaria (set colour to red)
    [ set pcolor red
      set state "dead"
    ]
  ]

  tick
end

to replace-dead                                                  ;;Replace the malaria cells that have been killed off by the treatment
  colour-grid
  ask patches
  [ if state = "dead" [ reproduce-mal ]                          ;;If the malaria dies, replace the dead cell by having an alive cell asexually reporoduce to keep a constant population
    set state "alive"                                            ;;Set the state of the new malaria to "alive"
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
673
474
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-17
17
-17
17
0
0
1
ticks
30.0

BUTTON
18
11
73
44
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
134
11
189
44
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
692
11
1038
56
Selected Genome
mal-genome
17
1
11

SLIDER
18
56
190
89
genome-length
genome-length
0
32
32.0
1
1
NIL
HORIZONTAL

SLIDER
18
102
190
135
mutation
mutation
0
1.0
0.3
0.1
1
NIL
HORIZONTAL

BUTTON
76
11
131
44
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
18
243
121
276
kill
kill
0
1
-1000

TEXTBOX
19
286
169
482
If \"kill\" switch is set to \"off\", the malaria will mutate when clicked.\n\nIf the \"kill\" switch is set to \"on\" the malaria will be killed when clicked and a random neighbor (8) will asexually reproduce to replace it. During this process there may be a mutation that you can adjust with the \"mutation\" slider
11
0.0
1

MONITOR
692
75
1038
120
Treatment Genome
treatment-genome
17
1
11

BUTTON
692
140
826
173
Apply Treatment
apply-treatment
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
693
192
827
225
Reproduce
replace-dead
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
149
190
182
treatment-effectiveness
treatment-effectiveness
0
100
68.0
1
1
NIL
HORIZONTAL

PLOT
696
242
896
392
Treatment Effectiveness
Time
Dead Malaria
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Malaria Deaths" 1.0 0 -16777216 true "" "plot count patches with [ state = \"dead\" ]"

MONITOR
1085
10
1191
55
Attribute 1
attribute-1
17
1
11

MONITOR
1206
10
1312
55
Attribute 2
attribute-2
17
1
11

MONITOR
1085
76
1191
121
Attribute 3
attribute-3
17
1
11

MONITOR
1207
76
1313
121
Attribute 4
attribute-4
17
1
11

BUTTON
18
196
136
229
Mouse update
mouse-update
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
