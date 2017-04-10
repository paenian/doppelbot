include <configuration.scad>
use <beam.scad>
use <connectors.scad>

test_plate();

module test_plate(){
    projection() translate([0,-30,0]) rotate([-90,0,0])
    translate([-30,0,0]) difference(){
       	rotate([90,0,0]) translate([0,-12,0]) cube([50,70,mdf_wall], center=true);
        //laser slop
      	translate([0,mdf_wall/2,0]) pinconnector_female(screw=true);
    	translate([0,0,15]) rotate([90,0,0]) write(str(laser_slop),t=wall*3,h=10,center=true, font = "Writescad/orbitron.dxf");
        
        //beam
        rotate([90,0,0]) translate([-beam/2,-15,0]) beamHoles(slop=0);
        rotate([90,0,0]) translate([beam/2,-15,0]) beamHoles(slop=0);
        
        //smooth rod mounting
        translate([0,0,-32]) rotate([0,90,0]) rotate([90,0,0]) {
            cylinder(r=smooth_rod_rad, h=wall*3, center=true);        
            //zip tie holes, to hold the rods in
            for(i=[-1,1]) translate([0,i*(smooth_rod_rad+wall+1),0]) cube([5,3,mdf_wall*3], center=true);
        }
	}
    
    translate([55,0,0]) difference(){
		projection()
	    translate([-30,-45,0]) difference(){
	        union(){
	            translate([0,38/2,0]) cube([50,38,mdf_wall], center=true);
	            pinconnector_male(screw=true, solid=1);
	        }
            //test the screw fit
	        pinconnector_male(screw=true, solid=-1);
            translate([0,30,0]) rotate([0,0,0]) write(str(m5_nut_rad_laser),t=wall*3,h=10,center=true, font = "Writescad/orbitron.dxf");
	    }
	}
}