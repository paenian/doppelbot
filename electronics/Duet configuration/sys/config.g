; CoreXY config file for 300x300x300mm doppelbot

M111 S0				; Debug off
M550 PBoxxyBrown		; Machine name (can be anything you like)
M551 Preprap			; Machine password (used for FTP connections)
ns)

;*** If you have more than one Duet on your network, they must all have different MAC addresses, so change the last digits
M540 P0xBE:0xEF:0xDE:0xAD:0xFE:0xED ; MAC Address

;*** Wifi Networking
M552 S1				; Enable WiFi

M555 P2				; Set output to look like Marlin
M575 P1 B57600 S1		; Comms parameters for PanelDue

; Machine configuration
M569 P0 S0			; Drive 0 goes forwards (change to S0 to reverse it)
M569 P1 S0			; Drive 1 goes forwards
M569 P2 S1			; Drive 2 goes forwards
M569 P3 S1			; Drive 3 goes forwards
M569 P4 S1			; Drive 4 goes forwards

; If you use an endstop switch for Z homing, change Z0 to Z1 in the following line, and see also M558 command later in this file
M574 X1 Y1 Z0 S1					; set endstop configuration (X and Y and endstops only, at low end, active high)

M667 S1							; set CoreXY mode

M350 X16 Y16 E16 I1    					; Set 16x microstepping with interpolation
M92 X80 Y80 Z1600					; Set axis steps/mm
M92 E419:419						; Set extruder steps/mm
M906 X1000 Y1000 Z1000 E1000	; Set motor currents (mA)
M201 X1000 Y1000 Z15 E1000	; Accelerations (mm/s^2)
M203 X15000 Y15000 Z100 E3600	; Maximum speeds (mm/min)
M566 X600 Y600 Z30 E20		; Maximum jerk speeds mm/minute
M208 X300 Y300 Z300		; set axis maxima (adjust to suit your machine)
M208 X-8 Y0 Z-0.5 S1		; set axis minima (adjust to make X=0 and Y=0 the edges of the bed)
G21				; Work in millimetres
G90				; Send absolute coordinates...
M83				; ...but relative extruder moves

; Z probe
M558 P1 X0 Y0 Z1                    ; Analog Z probe, also used for homing the Z axis
G31 Z1.30 P500                      ; Set the probe height and threshold (put your own values here)

; The following M557 commands are not needed if you are using a bed.g file to perform bed compensation
;*** Adjust the XY coordinates in the following M557 commands to suit your build and the position of the Z probe
M557 P0 X50 Y50                      ; Four... 
M557 P1 X50 Y250                    ; ...probe points...
M557 P2 X250 Y250                   ; ...for bed...
M557 P3 X250 Y50                     ; ...levelling
;M557 P4 X141 Y82.5                 ; 5th probe point for levelling

; Thermistors and heaters
;*** You can use S and B parameters to define the parameters of the thermistors you are using
M305 P0 R4700 H0 L0					; Put your own H and/or L values here to set the bed thermistor ADC correction
M305 P1 R4700 H0 L0					; Put your own H and/or L values here to set the first nozzle thermistor ADC correction
M305 P2 R4700 H0 L0					; Put your own H and/or L values here to set the second nozzle thermistor ADC correction
M301 H1 P10 I0.10 D100 T0.50 S1.0	; PID settings for extruder 0
M301 H2 P10 I0.10 D100 T0.50 S1.0	; PID settings for extruder 1
M570 S120							; Increase to allow extra heating time if needed

; Tool definition
M563 P0 D0 H1                       ; Define tool 0
G10 P0 S0 R0                        ; Set tool 0 operating and standby temperatures

;*** If you have a dual-nozzle build, un-comment the following 3 lines
;M563 P1 D1 H2                      ; Define tool 1
;G10 P1 S0 R0                       ; Set tool 1 operating and standby temperatures

;*** If you are using axis compensation, put the figures in the following command
M556 S78 X0 Y0 Z0                   ; Axis compensation here
T0									; select first hot end
