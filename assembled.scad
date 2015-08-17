include <configuration.scad>
include <functions.scad>
use <corner.scad>
use <beam.scad>


//top
translate([0,0,height_frame+wall+wall+beam]) top_frame();

//bottom
translate([0,0,beam]) mirror([0,0,1]) top_frame();

//corner beams
for(i=[0:1]) mirror([i,0,0])
	for(j=[0:1]) mirror([0,j,0])
		translate([-long_frame/2+beam/2,-short_frame/2-beam/2-wall,beam+wall]) beam(height_frame,false);


module top_frame(){
	for(i=[0:1]) mirror([i,0,0]){
		translate([-long_frame/2+beam/2,short_frame/2,beam/2]) rotate([90,0,0]) beam(short_frame,false);
	
		for(j=[0:1]) mirror([0,j,0])
			translate([-long_frame/2+beam/2,-short_frame/2-beam/2-wall,0]) corner();
	}

	for(j=[0:1]) mirror([0,j,0])
		translate([-long_frame/2,-short_frame/2-beam/2-wall,beam/2]) rotate([0,90,0]) beam(long_frame,true);
}