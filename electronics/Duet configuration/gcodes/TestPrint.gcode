; Test Routine for Duet WiFi beta boards
; Test motors
G28 ; home all axes - trigger endstops manually
G1 Z100 F10000 ; Move Z down to 100
G4 P1000
G1 X100 F10000 ; Move X +100
G4 P1000
G1 X-100 F10000 ; Move X -100
G4 P1000
G1 Y100 F10000 ; Move Y +100
G4 P1000
G1 Y-100 F10000 ; Move Y -100
G4 P4000
; Test PWM fans
M106 P0 S255
G4 P4000
M106 P0 S0
M106 P1 S255
G4 P4000
M106 P1 S0
M106 P2 S255
G4 P4000
M106 P2 S0
; Start heating bed
M140 S50
;Override cold extrusion
M302 P1
T0 ; Select first extruder
M104 S50 ; start heating hotend
G4 P4000
G1 E20 F200 ; extrude 
G4 P4000
G1 E-20 F200 ; retract 100
G4 P4000
M104 S0
T1 ; Select second extruder
M104 S50 ; start heating hotend
G4 P4000
G1 E20 F100 ; extrude 100
G4 P4000
G1 E-20 F100 ; retract 100
G4 P4000
M104 S0
M140 S0
G28
M84     ; disable motors

