/*
 * this is the structural endcap for the doppelbot.
 * The design entails two endcaps, separating and stiffening the frame.
 * 
 * Each endcap is a torsion box - two main plates with internal horizontal separators
 * plus four surrounding plates, intersecting all the others.
 * 
 */

include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../connectors.scad>

//this is the oval in the middle
separator_length = 79;


//render everything
part=1;

//parts for laser cutting
if(part == 0)
    belt_separator();

if(part == 1)
    aero_extra_washer();

$fn = 72;

%translate([0,0,wall+beam/2]) cube([beam,beam,beam], center=true);

module aero_extra_washer(){
    $fn = 144;
    rad = 8.4/2;
    outer_rad = rad+3.25;
    height = 1.9;
    
    difference(){
        union(){
            cylinder(r=outer_rad, h=height);
        }
        cylinder(r=rad, h=height*5, center=true);
    }
}

//this keeps the belts from rubbing at the crossover point.
module belt_separator(){
    wall = 4;
    thickness = 5;
    difference(){
        union(){
            hull(){
                //screwholes
                for(i=[0,1]) mirror([i,0,0]) translate([beam,0,0]) cylinder(r=beam/2, h=wall);
            
                //oval
                translate([0,beam,0]) scale([separator_length/thickness,1,1]) cylinder(r=thickness/2, h=wall);
            }
            
            //raised oval
            translate([0,beam,wall]) scale([separator_length/thickness,1,1]) minkowski(){
                cylinder(r=thickness/2-1, h=beam-wall);
                sphere(r=1);
            }
            
            //oval chamfer
            intersection(){
                translate([0,beam,wall-.1]) scale([separator_length/thickness,1,1]) 
                    cylinder(r1=thickness, h=thickness);
                
                hull(){
                    //screwholes
                    for(i=[0,1]) mirror([i,0,0]) translate([beam,0,0]) cylinder(r=beam/2, h=wall);
                        
                    //oval
                    translate([0,beam,0]) scale([separator_length/thickness,1,1]) cylinder(r=thickness/2, h=wall*3);
                }
            }
        }
        
        //screwholes
        for(i=[0,1]) mirror([i,0,0]) translate([beam,0,6]) mirror([0,0,1]) screw_hole_m5();
    }
}