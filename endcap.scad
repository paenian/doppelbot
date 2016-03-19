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

plate_sep = mdf_wall*3;

//the very end.  Stuff mounts to this guy.
end_plate();

//the almost very end - used to support the rods and keep them straight.
translate([0,0,plate_sep+mdf_wall]) support_plate();

//these are cross bars used to stiffen the plates.  It's basically a torsion box.
cross_plate();

%for(i=[0:90:359]) rotate([0,0,i]) {
    translate([frame_y/2-beam, frame_z/2-beam, 0]) cube([beam*2, beam*2, beam*2], center=true);
}

module end_plate_connectors(slots = false, solid=solid){
    for(i=[0:90:359]) rotate([0,0,i]) {
        for(i=[-1:1]){
            translate([(frame_y/2-beam*4)*i,-frame_y/2,0]) pinconnector_male(solid=solid);
        }
    }
}

module end_plate(slots=false){
    difference(){
        union(){
            //the plate
            cube([frame_y, frame_z, mdf_wall], center=true);
   
            //connectors around the edge
            end_plate_connectors(slots=false, solid=1);
        }
        //connectors around the edge
        end_plate_connectors(slots=false, solid=-1);
        
        //mounting holes for the cross plates
        cross_plate_set(slots=true);
        
        //mounting holes for electronics etc.
        holes();
    }
}

module support_plate(slots=false){
    difference(){
        end_plate();
        for(i=[0:1]) mirror([i,0,0]) translate([frame_y/2,0,0])
            for(j=[0:1]) mirror([0,j,0]) translate([0,frame_z/2,0])
                translate([-beam/2,-beam,0]) cube([beam+laser_slop, beam*2+laser_slop, mdf_wall*4], center=true);
    }
}

module holes(){
    cylinder(r=5, h=mdf_wall*2, center=true, $fn=7);
}