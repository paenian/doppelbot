include <../configuration.scad>

screw_sep = 260;

difference(){
    translate([0,0,9.5]) rotate([90,0,0]) handle();
    
    //cut off the bottom for easier printing
    translate([0,0,-50]) cube([400,400,100], center=true);
}


wall=5;

$fn=32;


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