include <../configuration.scad>
include <../functions.scad>

screw_sep = 260;

//this is a handle meant to mount on the beams of the printer
beam_handle(screw_sep = 150);

*difference(){
    translate([0,0,9.5]) rotate([90,0,0]) handle();
    
    //cut off the bottom for easier printing
    translate([0,0,-50]) cube([400,400,100], center=true);
}


wall=5;

$fn=32;

module beam_handle(rad = 10){
    //draw in the beam
    %translate([0,-beam,-beam/2]) cube([200,beam*2,beam], center=true);
    
    flatten = [1,.5,1];
    
    //hand
    %translate([0,25/2,-beam/2]) cube([100,25,beam], center=true);
    
    difference(){
        union(){
            //torus for the handle
            scale(flatten) rotate_extrude(){
                translate([screw_sep/2,0,0]) circle(r=rad, $fn=10);
            }
        }
        
        //screws
        for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,-beam/2,wall/2+6]) mirror([0,0,1]) screw_hole_m5(height = 50);
            
        //cut off the bottom the beam
        difference(){
            translate([0,-50-beam,-beam/2]) cube([200,100,100], center=true);
            
            #for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2+10,0,0])
            scale(flatten) sphere(r=rad, $fn=10);
        }
        
        //cut off the bottom
        
    }
}

module handle(width=20){
    difference(){
        union(){
            //smooth rounded base
            hull() for(i=[-1,1]) translate([i*screw_sep/2,0,0])
                sphere(r=width/2);
            
            //rounded top, too
            hull() for(i=[-1,1]) translate([i*screw_sep/4,0,50])
                sphere(r=width/2);
            
            //sides just connect it up
            for(i=[-1,1]){
                hull(){
                    translate([i*screw_sep/2,0,0])
                        sphere(r=width/2);
                    translate([i*screw_sep/4,0,50])
                        sphere(r=width/2);
                }
            }
            
            //mid-brace to make it a bit stronger
            *for(i=[-1,1]){
                hull(){
                    translate([i*screw_sep/3,0,0])
                        sphere(r=width/2);
                    translate([i*screw_sep/4,0,50])
                        sphere(r=width/2);
                }
            }
        }
        
        //screwholes
        for(i=[-1,1]) translate([i*screw_sep/2,0,-1]){
            cylinder(r=m5_rad, h=20);
            translate([0,0,wall*1.5+1]) cylinder(r=m5_cap_rad, h=100);
        }
        
        //cut off the base
        translate([0,0,-50]) cube([400,400,100], center=true);
    }
}