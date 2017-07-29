include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../gantry/gantry.scad>

part = 2;


//this is the bare attachment - doesn't mount anything
if(part == 0){
    rotate([0,0,90]) attachment_base();
}

//mount for E3D's Titan Aero
if(part == 1){
    rotate([0,0,90]) attachment_aero(diff_ir = true);
}


if(part == 2){
    belt_clamp();
}


module belt_clamp(){
    
}



module attachment_aero(diff_ir = false){
    wall = 5;
    slot_len = 5;
    base_height = 4;
    
    motor_w = 42;
    
    motor_drop = 42/2+slot_len*1.5+5+1;
    motor_extra_drop = 2;
    
    brace_width = motor_w/3;
    brace_height = motor_w/2;
    
    extra_jut = 13;
    
    diff_ir_hole_sep = 19.5;
    diff_ir_vert_offset = motor_w/2+motor_extra_drop+motor_drop+10;
    diff_ir_horz_offset = extra_jut+15;
    
    difference(){
        union(){
            attachment_base();
            
            //motor plate
            hull() {
                translate([0,motor_drop+motor_extra_drop,base_height+31/2+5+extra_jut]) rotate([0,90,0]) motor_holes(screw_rad = 5, slot = 0, height = wall);
                translate([0,motor_drop-wall/2,base_height+31/2+1])rotate([0,90,0]) motor_holes(screw_rad = 5, slot = 0, height = wall);
            }
            
            //differential IR sensor mount
            if(diff_ir == true){
                hull(){
                    //this is the motor mount area repeated
                    translate([0,motor_drop-wall/2,base_height+31/2+1])rotate([0,90,0]) motor_holes(screw_rad = 5, slot = 0, height = wall);
                    
                    translate([0,diff_ir_vert_offset,diff_ir_horz_offset])
                    for(i=[0:1]) mirror([0,0,i]) hull()
                for(j=[-3,3]) translate([0,j,diff_ir_hole_sep/2]) rotate([0,90,0]) cylinder(r=m3_rad+wall/2, h=wall, center=true);
                }
            }
            
            //top brace
            hull(){
                translate([0,motor_drop-motor_w/2-wall/2-.25,base_height+wall/2]) cube([brace_width,wall,wall+.1],center=true);
                translate([0,motor_drop-motor_w/2-wall/2-.25,base_height+wall/2+brace_height]) cube([wall,wall,wall+.1],center=true);
            }
        }
        
        //motor holes
        translate([0,motor_drop+motor_extra_drop,base_height+31/2+5+extra_jut]) rotate([0,90,0]) motor_holes(slot = .5, height = wall+1);
        
        //diff_ir holes
        if(diff_ir == true){
            translate([0,diff_ir_vert_offset,diff_ir_horz_offset])
            for(i=[0:1]) mirror([0,0,i]) hull()
                for(j=[-3,3]) translate([0,j,diff_ir_hole_sep/2]) rotate([0,90,0]) cylinder(r=m3_rad, h=wall+1, center=true);
            }
        
        //clear the screwheadhole
        translate([0,slot_len*1.5,base_height]) cylinder(r=5, h=50);
    }
}