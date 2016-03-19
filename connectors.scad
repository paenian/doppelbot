/* 
 * connectors for the MDF panels.
 * 
 */


include <configuration.scad>
include <functions.scad>

//all connectors are centered.

rotate([90,0,0]) 
translate([-30,0,0]) difference(){
	cube([50,50,mdf_wall], center=true);
	pinconnector_female(screw=true);
}

translate([-30,mdf_wall/2,0]) difference(){
	union(){
		translate([0,25,0]) cube([50,50,mdf_wall], center=true);
		pinconnector_male(screw=true, solid=1);
	}
	pinconnector_male(screw=true, solid=-1);
} 

module pinconnector_female(screw = true){
	union(){
		if(screw){
			cylinder(r=m5_rad, h=mdf_wall*3, center=true);
		}

		for(i=[0,1]) mirror([i,0,0]) translate([mdf_tab, 0, 0]) cube([mdf_tab+laser_slop, mdf_wall+laser_slop, mdf_wall+2], center=true);
	}
}

module pinconnector_male(screw = true, solid=0){
	union(){
		if(screw){
			if(solid<=0){
				cube([m5_rad*2+screw_slop, mdf_wall*6, mdf_wall+2], center=true);
				translate([0,mdf_wall*1.5, 0]) cube([m5_nut_rad*2, m5_nut_height+1, mdf_wall+2], center=true);
			}
		}
	
		if(solid >= 0){
			for(i=[0,1]) mirror([i,0,0]) translate([mdf_tab, 0, 0]) difference(){
                cube([mdf_tab, mdf_wall*2, mdf_wall], center=true);
                for(j=[0,1]) mirror([j,0,0]) translate([mdf_tab/2,-mdf_wall,0]) cylinder(r=mdf_wall/4, h=mdf_wall*2, center=true, $fn=4);
            }
		}
	}
}