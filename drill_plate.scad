include<configuration.scad>

/*
 * This is a simple hole array to help drill & tap the ends of the extrusion.
 * If you mount the long frame extrusions all to this plate, then you can cut
 * all of them at the same time and ensure that they're all exactly the same
 * length, at least if you use an accurate and squared saw.
 */

projection() difference(){
	cube([beam*1.9, beam*6, mdf_wall], center=true);
	
	translate([-beam/2, -beam*1.5])
	for(i=[0:1])
		for(j=[0:3])
			translate([i*beam, j*beam, 0]) cylinder(r=m5_rad+.1, h=mdf_wall*3, center=true);
}
