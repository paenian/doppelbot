include <../configuration.scad>
include <../functions.scad>

use <gantry_extruder.scad>
use <../gantry/gantry.scad>

%translate([0,-beam-wall*2,0]) rotate([0,0,90]) aero();

cooling_fan_mount();


//the mount uses the top two holes, the duct uses the bottom one hole.


wall = 2.5;

fan_hole_sep = 35;

duct_width = 28;
duct_height = 20;
duct_offset_x = 12;
duct_offset_y = 0;
duct_offset_z = -30;
duct_rad = 16.333;

duct_bottom_height = 10;

nozzle_height = 20; //max thickness of everything



module fan_mount(solid=1){
    //mounting holes
    rotate([-90,0,0]) 
    for(i=[0:1]) mirror([i,0,0]) for(j=[0:1]) mirror([0,j,0]) translate([fan_hole_sep/2,fan_hole_sep/2,0]){
        if(solid == 1){
            cylinder(r=m3_rad+wall, h=wall);
        }else{
            translate([0,0,-.05]) cylinder(r=m3_rad, h=wall+.1);
        }
    }
}

//the connects the fan to the shroud
module duct(solid=1){
    duct_w = duct_width+solid*wall;
    duct_h = duct_height+solid*wall;
    
    translate([duct_offset_x,duct_offset_y,duct_offset_z])
    scale([1,1,duct_bottom_height/duct_height])
    rotate([0,90,0]) intersection(){
        rotate_extrude(){
            translate([duct_rad,0,0]) square([duct_h, duct_w], center=true);
        }
        
        translate([50,50,0]) cube([100,100,100], center=true);
    }
    
}

//connects to the duct, and wraps around the nozzle
module shroud(solid=1){
    
}

//plan is to make a duct on the right side, leaving the left of the nozzle open.
module cooling_fan_mount(){
    difference(){
        union(){
            translate([0,1,0]) rotate([-90,0,0]) attachment_base();
            
            translate([0,5.1,-8.82]) hull() fan_mount();
        }
        translate([0,5.1,-8.82]) fan_mount(solid=0);
        
        //screwhole
        translate([0,5,-7.5]) rotate([-90,0,0]) cylinder(r=m5_cap_rad, h=50);
        
        *duct(solid=0);
        *shroud(solid=0);
    }
}

//centered on the extruder hole
module aero(){
    translate([0,0,0]) {
        *rotate([-90,0,0]) import("ASM_EX_AERO_175.stl");
        aero_carriage();
        translate([beam,0,0]) mirror([1,0,0]) rear_carriage();
    }
    
}
