mdf_wall = 6.5;
mdf_tab = 15;

wall = 5;

screw_slop = .2;
slop = .2;
laser_slop = -.1;

smooth_rod_rad = 10/2+laser_slop+.1;
smooth_rod_sep =490/5;

smooth_rod_sep = 115;

//these can't change - measured values.
beam = 20;
bed_screw_sep = 309;
bed = 300;

layer_height=.2;

//this is using the gt2 idlers from robotdigg
//idler_rad = 13/2;
//idler_flange_rad = 18/2;
//idler_thick = 12;

//these use the smaller M5 flanged bearings as idlers
idler_rad = 10/2;
idler_flange_rad = 12/2;
idler_thick = 10;

//flanged bearing for the Z idler
z_bearing=22/2;
z_bearing_flange = 25/2;
leadscrew_rad = 8/2+slop;
leadscrew_shaft_rad = 7;
leadscrew_screw_rad = 19.05/2;

pulley_rad = 13/2;
pulley_flange_rad = 18/2;

//using the mini V-wheels
wheel_rad = 11.5/2;
wheel_clearance = 18;
wheel_height = 9;
wheel_flange_rad = 16/2;

eccentric_rad = 7.3/2;
eccentric_flange_rad = 11/2;

//frame lengths - may be dependent on wall above.
frame_x = 500;  //we lose more in X because of the endcaps - it's where all the motors etc. will hide.
frame_y = 490;  //(490-300)/2-beam=75mm clearance on either side of the print bed.
corner_y = frame_y-75;
frame_z = 490;  //because square is nice.
corner_z = frame_z-75;

corner_endplate = true; //this controls wether you want a full endcap, or just the corners.  Corners allows twisting in a direction that should be impossible when the rails are connected on both ends, but I wanted to retain the old option just in case.
corner_length = 200; //length of the corner side support.

foot_height = 20;       //tall foot, cuz the Z motor will be underneath.

echo("BOM: 4, reg rail, 2020", frame_x, "Frame");

//motor size and placement variables
motor_w = 42;
motor_r = 52/2;
motor_y = frame_y/2-beam-pulley_rad; //distance motors are from the center.

belt_thick = 6;
belt_width = 1.5;


//gantry - might want to make it bigger
echo("BOM: 1, v-rail, 2020", frame_y, "Gantry");

//bed lengths
bed_x = 300+beam*2;
bed_y = 300;  //the screwholes on the bed should line up with the long_bed rails.

bed_screw_offset_y = bed_y/2;
bed_screw_offset_x = 15+5+2;

echo("BOM: 2, reg rail, 2020", bed_x, "Bed mount");
echo("BOM: 3, reg rail, 2020", bed_y, "Bed mount");  //might want more than three - to hold insulation well.

//standard screw variables
m3_nut_rad = 6.01/2+slop;
m3_nut_height = 2.4;
m3_rad = 3/2+slop;
m3_cap_rad = 3.25;
m3_cap_height = 2;
m3_sq_nut_rad = 7.9/2;

echo(m3_sq_nut_rad*2/sqrt(2));

m4_nut_rad = 7.66/2+slop;
m4_nut_height = 3.2;
m4_rad = 4/2+slop;
m4_cap_rad = 7/2+slop;
m4_cap_height = 2.5;

m5_nut_rad = 8.79/2;
m5_sq_nut_rad = (8*sqrt(2)+slop/2)/2;

echo(m5_sq_nut_rad);
echo(m5_sq_nut_rad*2/sqrt(2));

m5_nut_rad_laser = 8.79/2-.445;
m5_nut_height = 4.7;
m5_rad = 5/2+slop;
m5_rad_laser = 5/2-.1;
m5_cap_rad = 10/2+slop;
m5_cap_height = 3;
m5_washer_rad = 11/2+slop;


//some enums
MALE = 1;
FEMALE = -1;

//makes all the holes have lots of segments
$fs=.5;
$fa=.1;
