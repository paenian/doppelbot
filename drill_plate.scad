include<configuration.scad>


projection() difference(){
	cube([beam*1.9, beam*6, mdf_wall], center=true);
	
	translate([-beam/2, -beam*1.5])
	for(i=[0:1])
		for(j=[0:3])
			translate([i*beam, j*beam, 0]) cylinder(r=m5_rad+.1, h=mdf_wall*3, center=true);
}