include <../configuration.scad>
include <../functions.scad>

screw_sep = 30;
height = 23;

base_rad = 9;
top_rad = 4;

foot();

module foot(){
    difference(){
        union(){
            *hull(){
                for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,0])
                    scale([1,1,.5]) sphere(r=base_rad, $fn=36);
            }
            
            for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,0])
                hull(){
                    scale([.75,1,1]) sphere(r=base_rad, $fn=72);
                    translate([-screw_sep/2,0,height-top_rad]) scale([1,1,.333]) sphere(r=top_rad, $fn=8);
                }
        }
        
        //screwholes
        for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,wall/2+2]) mirror([0,0,1]) screw_hole_m5(height = 50);
        
        //flatten the bottom
        translate([0,0,-100]) cube([200,200,200], center=true);
    }
}