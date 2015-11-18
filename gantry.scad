include <configuration.scad>
include <functions.scad>
use <beam.scad>

gantry_length = 60;
//width is defined by the beam profile.

hotend_effector();

translate([0,100,-50]) gantry_end();

translate([0,100,50])mirror([0,1,0]) gantry_end();

module guide_wheel_helper(solid=0){
    if(solid >= 0){
        hull(){
            for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
                translate([0,beam/2+wheel_rad,0]) cylinder(r=m5_rad+wall, h=wall);
                translate([0,-beam/2-wheel_rad,0]) cylinder(r=m5_rad+wall, h=wall);
            }
        }
    }
    if(solid <= 0){
        for(i=[-1,1]) translate([i*gantry_length/2,0,-.1]){
            translate([0,beam/2+wheel_rad,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,-beam/2-wheel_rad,0]) cylinder(r=eccentric_rad, h=wall+1);
        }
    }
}

module belt_screwholes(){
    for(i=[-1,1]) translate([i*(gantry_length/2-wheel_rad),0,-.1]){
            translate([0,beam/2+idler_flange_rad,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,-beam/2-idler_flange_rad,0]) cylinder(r=m5_rad, h=wall+1);
        }
}

module hotend_effector(){
    %translate([0,0,-beam-1]) cube([beam*5,beam,beam*2],center=true);
    difference(){
        union(){
            //guide wheels
            guide_wheel_helper(solid=1);
            
            translate([0,beam/2+wall+wall/2,-10-wall]) cyclops_holes(solid=1, jut=1);
        }
        //guide wheels
        guide_wheel_helper(solid=-1);
        
        //belt screws
        belt_screwholes();
    }
}

module gantry_end(){
    
}

//mounting holes for the cyclops
module cyclops_holes(solid=0, jut=0){
    hole_sep = 9;
    hole_zsep = 10;
    ind_jut = 2;
    
    for(i=[0,1]) mirror([i,0,0]){
        translate([hole_sep/2,-wall,hole_zsep]) rotate([-90,0,0]){
            if(solid>=0){
                cylinder(r=m3_rad+wall, h=wall);
                if(jut==1){
                    translate([0,0,wall-.1]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=ind_jut+.1);
                }
            }
            if(solid<=0) translate([0,0,-.1]) {
                cap_cylinder(r=m3_rad, h=wall*2);
                cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
            }
        }
    }
    
    translate([0,-wall,0]) rotate([-90,0,0]){
        if(solid>=0){
            cylinder(r=m3_rad+wall, h=wall);
            if(jut==1){
                translate([0,0,wall-.1]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=ind_jut+.1);
            }
        }
        if(solid<=0) translate([0,0,-.1]) {
            %translate([0,-5,9+wall+ind_jut+.1]) cube([30,30,18], center=true);
            %translate([0,-5,6+wall+ind_jut+.1]) rotate([90,0,0]) cylinder(r=1, h=50, center=true);
            cap_cylinder(r=m3_rad, h=wall*2);
            cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
        }
    }
}