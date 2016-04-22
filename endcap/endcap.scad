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

//cross plate vars
plate_sep = 20;
num_plates = 2;

//side vars
side_plate_width=60;    //minimum 80mm for two clips in the corners.
num_clips = 1;          //for one clip, minimum is 60.

foot_height = 60;       //tall foot, cuz the Z motor will be underneath.


wall_inset = (plate_sep+mdf_wall)/2+15;
wall_inset = side_plate_width/2-mdf_wall*1.5;

z_offset = 10; //applies to both the lead screw and the smooth rods - they're inline.


//motor dimensions
bump_rad = 25/2;    //clearance for the central bump thingy
motor_w = 42.5;
screw_w = 31;
screw_rad = m3_rad;

//render everything
part=10;

//parts for laser cutting
if(part == 0)
    end_plate_projected();
if(part == 1)
    support_plate_projected();
if(part == 2)
    cross_plate_projected();
if(part == 3)
    vertical_wall_projected();
if(part == 4)
    top_wall_projected(motor=true);
if(part == 5)
    top_wall_projected(motor=false);
if(part == 6)
    bottom_wall_projected();

//view the assembly
if(part == 10){
    assembled_endcap();
}

//assemble
module assembled_endcap(){
    end_plate_connected();
    support_plate_connected();
    cross_plates();
    vertical_walls_connected();
    top_wall_connected();
    bottom_wall_connected();

	//draw in a few belt lines
	%for(j=[-pulley_rad,pulley_rad]) for(i=[0:1]) mirror([i,0,0]) translate([motor_y+j,frame_z/2-3-6,100]){
		cube([2,6,200], center=true);
	}
}

/************* Layout Section ***************
 * The plate files don't have cutouts for their intersections
 * with other plates - those are added here, in the layout.
 */
module end_plate_projected(){
    echo("Cut One per End");
    projection(){
        end_plate_connected();
    }
}

module end_plate_connected(){
    //we ignore assembled, cuz it's always flat :-)
    difference(){
        //the very end.  Stuff mounts to this guy.
        end_plate();     
            
        //holes for all the stiffening cross plates
        cross_plates_connectors(gender=FEMALE);
    }
}

module support_plate_projected(){
    echo("Cut One per End");
    projection(){
        support_plate_connected();
    }
}

module support_plate_connected(){
    difference(){
        //the support plate
        translate([0,0,plate_sep+mdf_wall]) support_plate();
            
        //holes for all the stiffening cross plates
        cross_plates_connectors(gender=FEMALE);
    }        
}

module cross_plate_projected(){
    echo("Cut Two per End");
    projection() cross_plate();
}

module vertical_wall_projected(){
    echo("Cut Two per End");
    projection(){ 
       rotate([0,-90,0])
       difference(){
            union(){
                //front and back are identical, so we just pick one
                translate([-frame_y/2-mdf_wall/2,0,wall_inset]) rotate([0,90,0]) vertical_plate();
            }
        
            //this subtracts the end connectors
            end_plate_connectors(gender=FEMALE);
            translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
            //the walls also get pinned at the bottom
            translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate  ([0,0,90]) rotate([0,90,0]) bottom_plate_connectors(gender=FEMALE);
        } 
    }
}

module vertical_walls_connected(){
    //the two vertical walls
    difference(){
        union(){
            //front and back are identical
            for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate();
        }
        
        //this subtracts the end connectors
        end_plate_connectors(gender=FEMALE);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
        //the walls also get pinned at the bottom
        translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate  ([0,0,90]) rotate([0,90,0]) bottom_plate_connectors(gender=FEMALE);
    }
}

module top_wall_projected(motor=true){
    projection() rotate([90,0,0]) top_wall_connected(motor=motor);
}

//the top wall
module top_wall_connected(motor=true){
    difference(){
        //top - motors on one end, idlers on the other
        translate([0,frame_z/2+mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0]) 
        top_plate(motor=motor);
    
        //this subtacts the connectors from whatever part comes next.
        end_plate_connectors(gender=FEMALE);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
        //also gets hit by the verts
        for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate_connectors(gender=FEMALE);
    }
}

module bottom_wall_projected(){
    projection() rotate([90,0,0]) bottom_wall_connected();
}

//the bottom wall
module bottom_wall_connected(){
    difference(){
        //bottom - z motor in the middle
        translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0]) 
        bottom_plate();
    
        //this subtacts the connectors from whatever part comes next.
        end_plate_connectors(gender=FEMALE);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
    //also gets hit by the verts
        *for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate_connectors(gender=FEMALE);
    }
}


//holes for the motor
module motor_mount(){
    cylinder(r=bump_rad, h=wall*3, center=true);
    for(i=[0:90:359]) rotate([0,0,i]) translate([screw_w/2, screw_w/2, 0]){
        hull(){
            translate([-1,-1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
            translate([1,1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
        }
    }
}

//holes for the idler
module idler_mount(){
    cylinder(r=m5_rad, h=wall*3, center=true);
}

module smooth_rod_holes(){
    for(i=[0:1]) mirror([0,i,0]) translate([-plate_sep/2-z_offset,frame_y/4,0]) {
        cylinder(r=smooth_rod_rad, h=wall*3, center=true);
        %translate([0,0,-40]) cylinder(r=20/2, h=29, center=true);
        
        //zip tie holes, to hold the rods in
        for(i=[-1,1]) translate([0,i*(smooth_rod_rad+wall+1),0]) cube([5,3,mdf_wall*3], center=true);
    }
}

module beam_holes(double = false){
    
    for(i=[0:1]) for(j=[wall_inset-mdf_wall*1.5,mdf_wall*2-side_plate_width/2])
        mirror([0,i,0]) translate([j,frame_y/2-beam/2,0]){
            cylinder(r=m5_rad, h=mdf_wall*3, center=true);
            
            //this is for the flat of the beam
            if(double==true){
                translate([0,-beam,0]) cylinder(r=m5_rad, h=mdf_wall*3, center=true);
            }
        }
}

//there aren't any...
module top_plate_connectors(gender=MALE, solid=1){
}

//the uppermost plate.  Includes mounts for the motors on one side, and idlers on the other
module top_plate(motor=true){
    difference(){
        union(){
            cube([side_plate_width, frame_y+mdf_wall*3, mdf_wall], center=true);
            top_plate_connectors(gender=MALE, solid=1);
        }
        top_plate_connectors(gender=MALE, solid=-1);
        
        //mount the idlers/motors
        for(i=[0:1]) mirror([0,i,0]) translate([-plate_sep/2-mdf_wall-pulley_rad,motor_y,0])
        if(motor==true){    //motor mounts
            rotate([0,0,-45]) motor_mount();
        }else{              //idler mounts
            idler_mount();
        }
        
        //smooth rod mounts
        smooth_rod_holes();
        
        //beam holes
        beam_holes();
        
        //hole for the Z rod
        translate([-plate_sep/2-z_offset,0,0]) cylinder(r=4+slop, h=mdf_wall*3, center=true);
        
        //this is for an m8 flanged bearing
        translate([-plate_sep/2-z_offset,0,0]) cylinder(r=22/2, h=mdf_wall*3, center=true);
    }
}


//there aren't any...
module bottom_plate_connectors(gender=MALE, solid=1){
    if(num_clips == 2){
        for(j=[0,1]) for(i=[-1,1]){
            mirror([0,j,0]) translate([mdf_tab*i,frame_y/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
    }
    if(num_clips == 1){
        for(j=[0,1])
            mirror([0,j,0]) translate([0,frame_y/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
}

//the bottom plate.  Includes mounts for the Z motor in the middle, and the smooth rods on the sides.
module bottom_plate(){
    difference(){
        union(){
            cube([side_plate_width, frame_y, mdf_wall], center=true);
            bottom_plate_connectors(gender=MALE, solid=1);
        }
        bottom_plate_connectors(gender=MALE, solid=-1);
        
        //mount the motor
        translate([-plate_sep/2-z_offset,0,0])
            rotate([0,0,-45]) motor_mount();
        
        translate([-plate_sep/2-z_offset,150,0])
            rotate([0,0,-45]) motor_mount();
        
        translate([-plate_sep/2-z_offset,-150,0])
            rotate([0,0,-45]) motor_mount();
        
        
        //smooth rod mounts
        smooth_rod_holes();
        
        //beam holes
        beam_holes();
    }
}

module vertical_plate_connectors(gender=MALE, solid=1){
    if(num_clips == 2){
        for(i=[-1,1]){
            translate([mdf_tab*i,frame_z/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
    }
    if(num_clips == 1){
        translate([0,frame_z/2,0]) if(gender == MALE){
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
        
        beam_holes(double=true);
    }
}

module end_plate_connectors(gender = MALE, solid=1){
    for(i=[0:90:359]) rotate([0,0,i]) {
        for(i=[-1,1]){
            translate([(frame_y/2-beam*5)*i,-frame_y/2,0]) if(gender == MALE){
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
        //cross_plates_connectors(gender=FEMALE);
        
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
                    translate([-beam/2+.5,-beam+.5,0]) cube([beam+1, beam*2+1, mdf_wall*4], center=true);
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
    //start = -frame_z/2-wall;
    //end = frame_z/2-wall;
    span = (frame_z-wall*2)/num_spans;
    union(){
        for(i=[0:num_spans-1]){
            translate([i*span-frame_z/2+span/2+wall,-plate_sep/2+plate_sep*(i%2),0]){
                if(gender==MALE){
                    difference(){
                        cube([span,mdf_wall*2,mdf_wall], center=true);
                        
                        //cut off the corners
                        for(j=[0,1]) mirror([j,0,0]) translate([span/2,-mdf_wall+mdf_wall*2*(i%2),0]) cylinder(r=mdf_wall/4, h=mdf_wall*2, center=true, $fn=4);
                    }
                }else{
                    cube([span+laser_slop,mdf_wall*2+1,mdf_wall+laser_slop], center=true);
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
