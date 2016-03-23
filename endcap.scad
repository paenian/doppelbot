/*
 * this is the structural endcap for the doppelbot.
 * The design entails two endcaps, separating and stiffening the frame.
 * 
 * Each endcap is a torsion box - two main plates with internal horizontal separators
 * plus four surrounding plates, intersecting all the others.
 * 
 */

include <configuration.scad>
include <functions.scad>
use <beam.scad>
use <connectors.scad>

//cross plate vars
plate_sep = mdf_wall*3;
num_plates = 2;

//side vars
side_plate_width=80;
foot_height = 25;


//motor dimensions
bump_rad = 25/2;    //clearance for the central bump thingy
motor_w = 42.5;
screw_w = 31;
screw_rad = m3_rad;

pulley_rad = 20/2;  //outer rad for clearance
pulley_belt_rad = 20/2; //position of the belt



//the two end plates, both need the cross plates subtracted
difference(){
    union(){
        //the very end.  Stuff mounts to this guy.
        end_plate();
        
        //the almost very end - used to support the rods and keep them straight.
        translate([0,0,plate_sep+mdf_wall]) support_plate();
    }
    //holes for all the stiffening cross plates
    cross_plates_connectors(gender=FEMALE);
}

//these are cross bars used to stiffen the plates.  It's a torsion box.
cross_plates();

//the two vertical walls
difference(){
    union(){
        //front and back are identical
        for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,(plate_sep+mdf_wall)/2]) rotate([0,90,0]) vertical_plate();
    }
    //this subtracts the end connectors
    end_plate_connectors(gender=FEMALE);
    translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
    //the walls also get pinned at the bottom
    bottom_plate_connectors(gender=FEMALE);
}

//the top wall
*difference(){
    //top - motors on one end, idlers on the other - same part, though.
    top_plate();
    
    //this subtacts the connectors from whatever part comes next.
    end_plate_connectors(gender=FEMALE);
    translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
    //also gets hit by the verts
    for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,(plate_sep+mdf_wall)/2]) rotate([0,90,0]) vertical_plate_connectors();
}

//and the bottom wall
*difference(){
    //top - motors on one end, idlers on the other - same part, though.
    bottom_plate();
    
    //this subtacts the end plate connectors
    end_plate_connectors(gender=FEMALE);
    translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
}





module vertical_plate_connectors(gender=MALE, solid=1){
    for(i=[-1,1]){
            translate([mdf_tab*i,frame_z/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
}

//the front and back vertical plates.  Includes feet!
module vertical_plate(){
    difference(){
        union(){
            translate([0,-foot_height/2,0]) cube([side_plate_width, frame_y+foot_height, mdf_wall], center=true);
            vertical_plate_connectors(gender=MALE, solid=1);
        }
        vertical_plate_connectors(gender=MALE, solid=-1);
    }
}

module bottom_plate(){
}

module end_plate_connectors(gender = MALE, solid=1){
    for(i=[0:90:359]) rotate([0,0,i]) {
        for(i=[-1:1]){
            translate([(frame_y/2-beam*4)*i,-frame_y/2,0]) if(gender == MALE){
                pinconnector_male(solid=solid);
            }else{
                pinconnector_female();
            }
        }
    }
}

module end_plate(){
    difference(){
        union(){
            //the plate
            cube([frame_y, frame_z, mdf_wall], center=true);
   
            //connectors around the edge
            end_plate_connectors(solid=1);
        }
        //connectors around the edge
        end_plate_connectors(solid=-1);
        
        //mounting holes for the cross plates
        cross_plate_connectors_set(gender=FEMALE);
        
        //mounting holes for electronics etc.
        holes();
        
        //beam holes
        beam_cutout(screws=true, beams=false);
    }
}

module beam_cutout(screws=true, beams=false){
    if(beams==true){
        union(){
            for(i=[0:1]) mirror([i,0,0]) translate([frame_y/2,0,0])
                for(j=[0:1]) mirror([0,j,0]) translate([0,frame_z/2,0])
                    translate([-beam/2,-beam,0]) cube([beam+laser_slop, beam*2+laser_slop, mdf_wall*4], center=true);
        }
    }
    if(screws==true){
        for(i=[0:1]) mirror([i,0,0]) translate([frame_y/2,0,0])
                for(j=[0:1]) mirror([0,j,0]) translate([0,frame_z/2,0])
                    difference(){
                        union(){
                            for(k=[0:1]){
                                translate([-beam/2,-beam/2-k*beam,0]) beamHoles(slop=0);
                                }
                            }
                            translate([-beam/2,-beam,0]) rotate([0,0,180/8]) cylinder(r=beam/2-2.1, h=30, center=true, $fn=8);
                        }
    }
}

module support_plate(slots=false){
    difference(){
        end_plate();
        beam_cutout(screws=false, beams=true);
    }
}

module cross_plate_connectors(gender=MALE, num_spans = 10){
    start = -frame_z/2;
    end = frame_z/2;
    span = frame_z/num_spans;
    union(){
        for(i=[0:num_spans-1]){
            translate([i*span-frame_z/2+span/2,-plate_sep/2+plate_sep*(i%2),0]){
                if(gender==MALE){
                    difference(){
                        cube([span,mdf_wall*2,mdf_wall], center=true);
                        
                        //cut off the corners
                        for(j=[0,1]) mirror([j,0,0]) translate([span/2,-mdf_wall+mdf_wall*2*(i%2),0]) cylinder(r=mdf_wall/4, h=mdf_wall*2, center=true, $fn=4);
                    }
                }else{
                    cube([span+laser_slop,mdf_wall*2+laser_slop*2,mdf_wall+laser_slop], center=true);
                }
            }
        }
    }
}

module cross_plates_connectors(gender=MALE, num_spans = 10){
    plate_travel = frame_z/(num_plates+1);
    
    translate([0,-frame_z/2,plate_sep/2+mdf_wall/2]) 
    for(i=[1:num_plates]){
        translate([0,i*plate_travel,0]) rotate([90,0,0]) cross_plate_connectors(gender=gender, num_spans=num_spans);
    }
}

module cross_plate(slots=false){
    //rotate([90,0,0])
    difference(){
        union(){
            cube([frame_y,plate_sep,mdf_wall], center=true);
            cross_plate_connectors();
        }
    }
}

module cross_plates(){
    plate_travel = frame_z/(num_plates+1);
    
    translate([0,-frame_z/2,plate_sep/2+mdf_wall/2]) 
    for(i=[1:num_plates]){
        translate([0,i*plate_travel,0]) rotate([90,0,0]) cross_plate();
    }
}

module holes(){
    cylinder(r=5, h=mdf_wall*2, center=true, $fn=7);
}