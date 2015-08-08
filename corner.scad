include <configuration.scad>
include <functions.scad>

inside_rad = .5;

corner();


//a standard corner, with a slight twist - one beam is internal, the other two are surface-mount.
module corner(){
	difference(){
		union(){
			hull(){
				translate([-wall/4,wall/4,wall/2]) cube([beam+wall/2, beam+wall/2, wall], center=true);
				translate([0,beam/2+wall/2,beam/2+wall*3/4]) cube([beam, wall, beam+wall/2], center=true);
				translate([-beam/2-wall/2,0,beam/2+wall*3/4]) cube([wall, beam, beam+wall/2], center=true);
			}
		}

		//hollow out the center
		translate([0,0,beam/2+wall]) cube([beam+.1, beam+.1, beam+.1], center=true);

		//cut the inside corners
		translate([-beam/2, beam/2, wall]) for(i=[0,-90]) for(j=[0,-90])
			rotate([0,i,0])
			rotate([0,0,j]) 
			hull(){
				sphere(r=inside_rad);
				translate([beam,0,0]) sphere(r=inside_rad); 
			}

		corner_holes();
	}
}

module corner_holes(){
	translate([0,0,-.1]) cylinder(r=m5_rad, h=wall);
	translate([0,0,wall-m5_cap_height]) cylinder(r=m5_cap_rad, h=wall);

	translate([0, beam/2+wall, beam/2+wall]) rotate([90,0,0]){
		translate([0,0,-.1]) rotate([0,0,180]) cap_cylinder(r=m5_rad, h=wall);
		translate([0,0,wall-m5_cap_height]) rotate([0,0,180]) cap_cylinder(r=m5_cap_rad, h=wall);
	}

	translate([-beam/2-wall, 0, beam/2+wall]) rotate([0,90,0]){
		translate([0,0,.1]) rotate([0,0,270]) cap_cylinder(r=m5_rad, h=wall);
		translate([0,0,m5_cap_height-wall]) rotate([0,0,270]) cap_cylinder(r=m5_cap_rad, h=wall);
	}
}