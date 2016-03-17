include <configuration.scad>
include <functions.scad>
use <beam.scad>


//four frame members
for(i=[0,1]) mirror([0,i,0])
	for(j=[beam, height_frame-beam])
		translate([-long_frame/2, short_frame/2, j]) rotate([0,90,0]) beam_2040(long_frame, true);

//endcaps


//gantry

//bed
translate([0,0,beam]) cube([bed, bed, wall], center=true);


module top_frame(){
	for(i=[0:1]) mirror([i,0,0]){
		translate([-long_frame/2+beam/2,short_frame/2,beam/2]) rotate([90,0,0]) beam(short_frame,false);
	
		for(j=[0:1]) mirror([0,j,0])
			translate([-long_frame/2+beam/2,-short_frame/2-beam/2-wall,0]) rotate([0,90,0]) rotate([0,0,90]) corner_2040();
	}

	for(j=[0:1]) mirror([0,j,0])
		translate([-long_frame/2,-short_frame/2-beam/2-wall,beam/2]) rotate([0,90,0]) beam(long_frame,true);
}