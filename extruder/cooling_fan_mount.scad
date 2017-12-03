include <../configuration.scad>
include <../functions.scad>

use <gantry_extruder.scad>
use <../gantry/gantry.scad>


cooling_fan_mount();

wall = 2;

//clamp to hold the hotend in
mount_screw_sep = 25;
mount_rad = 6.5;
mount_screw_rad = m5_rad+slop;

fan_sep = 73;

%translate([0,10,0]) rotate([90,0,0]) cylinder(r=16.5/2, h=65.6);
%translate([0,10,0]) rotate([90,0,0]) cylinder(r=22.5/2, h=60);


fan_screw_sep = 24;
fan_screw_rad = 3/2+slop;
fan_corner_rad = 3.25;
fan_rad = 27/2;
fan_width = fan_screw_sep+fan_corner_rad*2;

module cooling_fan_mount(){
    thick = wall*2; 
    hotend_fan_offset = [0,-23+2,6];
    
    difference(){
        union(){
            //attach to the hotend clamp
            hull() for(i=[0,1]) mirror([i,0,0]) translate([mount_s crew_sep/2+1,0,0]) cylinder(r=mount_rad, h=thick);
                
            translate(hotend_fan_offset) hotend_fan_mount();
            
            //side fans
            for(i=[0,1]) mirror([i,0,0]) translate([fan_sep/2,0,0]) rotate([90,0,0]){
                translate([-fan_width/2,0,0]) rotate([0,-45,0]) translate([fan_width/2,0,0]) hotend_fan_mount(shroud = false);
                fan_duct();
            }
            
        }
        
        //mounting holes
        for(i=[0,1]) mirror([i,0,0]) translate([mount_screw_sep/2,0,-1]) cylinder(r=m5_rad+slop, h=wall*4);
            
        translate(hotend_fan_offset) hotend_fan_mount(solid=-1);
        
        //side fans
        for(i=[0,1]) mirror([i,0,0]) translate([fan_sep/2,0,0]) rotate([90,0,0]){
            translate([-fan_width/2,0,0]) rotate([0,-45,0]) translate([fan_width/2,0,0]) hotend_fan_mount(solid=-1, shroud = false);
            fan_duct(solid = 0);
        }
        
        //flatten
        translate([0,0,-65]) cube([200,200,100], center=true);
    }
}

module fan_duct(solid = 1, thick=wall){
    
    duct_rad = 3;
    end_rad = 1;
    duct_height = 44;
    duct_width = 10;
    
    duct_inset = -9;
    
    middle_inset = -14.5;
    middle_rad = 7;
    middle_height = 23;
    middle_width = 17;
    
    
    //drop
    hull(){
        //top
        translate([-fan_width/2,0,0]) rotate([0,-45,0]) translate([fan_width/2,0,0]) cylinder(r=fan_rad+wall*solid, h=thick+1+(solid-1)*(-.1));
        
        //middle
        translate([middle_inset,-fan_rad-solid*wall,middle_height]) rotate([-90,0,0]) cylinder(r=middle_rad+solid*wall, h=middle_width+solid*wall*2);
    }
    hull(){
        //middle again
        translate([middle_inset,-fan_rad-solid*wall,middle_height]) rotate([-90,0,0]) cylinder(r=middle_rad+solid*wall, h=middle_width+solid*wall*2);
        
        //bottom
        translate([duct_inset,-fan_rad-solid*wall,duct_height]) rotate([-90,0,0]) cylinder(r=duct_rad+solid*wall, h=duct_width+solid*wall*2);
    }
    
    //exit
    hull(){
        translate([duct_inset,-fan_rad-solid*wall,duct_height]) rotate([-90,0,0]) cylinder(r=duct_rad+solid*wall, h=duct_width+solid*wall*2);
        
        translate([duct_inset*2+(solid-1)*10,-fan_rad-solid*wall,duct_height+duct_rad-end_rad*solid*4+wall*2.75]) rotate([-90,0,0]) cylinder(r=end_rad+solid*2, h=duct_width+solid*wall*2);
    }
}

module hotend_fan_mount(solid = 1, thick = wall, shroud = true){

    
    
    
    hotend_inset = [0,0,-16];
    hotend_rad = 22.75/2;
    
   
    
    if(solid == 1){
        //body
        hull(){
            for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, 0])
                cylinder(r=fan_corner_rad, h=thick);
            
            if(shroud == true){
                translate(hotend_inset) rotate([90,0,0]) cylinder(r=hotend_rad+wall, h=fan_screw_sep, center=true);
            }
        }
    }else{
        //screwholes
        for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, -thick*4+.1])
            cylinder(r2=fan_screw_rad, r1=fan_screw_rad-.5, h=thick*5);
        
        //center hole
        if(shroud == false){
            translate([0,0,-.1]) cylinder(r=fan_rad, h=thick+.2);
        }
        
        if(shroud == true){
            hull(){
                translate([0,0,thick/2+.1]) cylinder(r=fan_rad, h=thick/2);
                translate(hotend_inset) rotate([90,0,0]) cylinder(r=hotend_rad/2, h=fan_screw_sep+fan_corner_rad*2, center=true);
            }
            
            hull(){
                translate(hotend_inset) rotate([90,0,0]) cylinder(r=hotend_rad, h=fan_screw_sep+fan_corner_rad*2, center=true);
                translate([0,0,-25]) rotate([90,0,0]) cylinder(r=hotend_rad+.25, h=fan_screw_sep+fan_corner_rad*2, center=true);
            }
            
        }
    }
}