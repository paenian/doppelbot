include <configuration.scad>
include <functions.scad>
use <beam.scad>


//four frame members
for(i=[0,1]) mirror([0,i,0])
	for(j=[beam, frame_z-beam])
		translate([-frame_x/2, frame_y/2, j]) rotate([0,90,0]) beam_2040(frame_x, true);

//endcaps


//gantry

//bed
translate([0,0,beam]) cube([bed_x, bed_y, wall], center=true);


module top_frame(){
	for(i=[0:1]) mirror([i,0,0]){
		translate([-frame_x/2+beam/2,frame_y/2,beam/2]) rotate([90,0,0]) beam(frame_y,false);
	
		for(j=[0:1]) mirror([0,j,0])
			translate([-frame_x/2+beam/2,-frame_y/2-beam/2-wall,0]) rotate([0,90,0]) rotate([0,0,90]) corner_2040();
	}

	for(j=[0:1]) mirror([0,j,0])
		translate([-frame_x/2,-frame_y/2-beam/2-wall,beam/2]) rotate([0,90,0]) beam(frame_x,true);
}