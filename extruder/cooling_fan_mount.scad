
%translate([0,26,0]) aero();

cooling_fan_duct();

wall = 2.5;

fan_rad = 40/2;

duct_width = 25;
duct_height = 15;
duct_offset_x = -20;
duct_rad = 15;

module fan_mount(solid=1){
    
}

//the connects the fan to the shroud
module duct(solid=1){
    duct_width = duct_width+solid*wall;
    duct_height = duct_height+solid*wall;
    
    translate([duct_offset_x,0,0])
    rotate([0,90,0]) intersection(){
        rotate_extrude(){
            translate([duct_rad,0,0]) square([duct_height, duct_width], center=true);
        }
        
        translate([50,-50,0]) cube([100,100,100], center=true);
    }
    
}

//connects to the duct, and wraps around the nozzle
module shroud(solid=1){
    
}

//plan is to make a duct on the right side, leaving the left of the nozzle open.
module cooling_fan_duct(){
    difference(){
        union(){
            fan_mount();
            
            duct();
            
            shroud();
        }
        fan_mount(solid=0);
        duct(solid=0);
        shroud(solid=0);
    }
}

//centered on the extruder hole
module aero(){
    translate([-17.75,0,0]) rotate([-90,0,0]) import("ASM_EX_AERO_175.stl");
}
