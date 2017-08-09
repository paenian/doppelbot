//This is an extruder that's firmly mounted to the gantry.
include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../endcap/endcap.scad>
use <../gantry/gantry.scad>

wall = 6;

//flange in front of the aero
flange_thick = 4;
motor_z = -10;
motor_y = 5;
motor_x = -8;

//!aero_orig();
    carriage_len = 60;
    carriage_spread = -15;

aero_carriage();
motor_width = 42;
echo(motor_width);

//carriage to mount a single Titan Aero extruder
module aero_carriage(){
    %translate([motor_x-wall-motor_width/2,motor_y,motor_z])
    aero_orig();
    
    difference(){
        union(){
            hull() vertical_gantry_carriage(v_mount  = false, belt_holes = false);
        }
        
        //groove for the belt
        #rotate([0,0,90]) rotate([-90,0,0]) belt_attach_flat();
        
        //cutout above the belt
        translate([0,0,beam/2+beam/2+belt_thick/2+1.5]) cube([20,35,beam], center=true);
        
        //guide wheel holes
        translate([-wall,0,0]) rotate([-90,0,0]) rotate([0,90,0]) guide_wheel_helper(solid=-1, span=2, gantry_spread = carriage_spread, gantry_length=carriage_len, spring_compression=1);
    }
    
        
}

module aero_orig(){
    mirror([0,0,0]) translate([-6.75,0,-20.5]) rotate([-90,0,0]) import("ASM_EX_AERO_175.stl");
}