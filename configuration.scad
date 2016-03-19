mdf_wall = 6.5;
mdf_tab = 15;

wall = 5;

screw_slop = .2;
slop = .2;
laser_slop = .1;

//these can't change - measured values.
beam = 20;
bed_screw_sep = 309;
bed = 300;

layer_height=.2;

idler_rad = 17.5/2;
idler_flange_rad = 22/2;

pulley_rad = 13/2;
pulley_flange_rad = 18/2;

wheel_rad = 10.2;
wheel_clearance = 26;
wheel_height = 10.4;
wheel_flange_rad = 24.5/2;

eccentric_rad = 7.3/2;
eccentric_flange_rad = 11/2;

motor_w = 42;
motor_r = 52/2;

belt_thick = 6;
belt_width = 2;


//frame lengths - may be dependent on wall above.
frame_x = 500;  //we lose more in X because of the endcaps - it's where all the motors etc. will hide.
frame_y = 450;  //(450-300)/2-wall-beam=50mm on either side of the printer.
frame_z = 450;  //because square is nice.

echo("BOM: 4, reg rail, 2020", frame_x, "Frame");

//gantry - might want to make it bigger
echo("BOM: 1, v-rail, 2020", frame_y, "Gantry");

//bed lengths
bed_x = 300+beam*2;
bed_y = 300;  //the screwholes on the bed should line up with the long_bed rails.
echo("BOM: 2, reg rail, 2020", bed_x, "Bed mount");
echo("BOM: 3, reg rail, 2020", bed_y, "Bed mount");  //might want more than three - to hold insulation well.

//standard screw variables
m3_nut_rad = 6.01/2+slop;
m3_nut_height = 2.4;
m3_rad = 3/2+slop;
m3_cap_rad = 3.25;
m3_cap_height = 2;

m4_nut_rad = 7.66/2+slop;
m4_nut_height = 3.2;
m4_rad = 4/2+slop;
m4_cap_rad = 7/2+slop;
m4_cap_height = 2.5;

m5_nut_rad = 8.79/2+slop;
m5_nut_height = 4.7;
m5_rad = 5/2+slop;
m5_cap_rad = 10/2+slop;
m5_cap_height = 3;


//makes all the holes have lots of segments
$fs=.5;
$fa=.1;