include <configuration.scad>
include <functions.scad>
use <beam.scad>

inside_rad = .5;

corner_2040(motor=true);
translate([100,0,0]) corner_2040(idler=true);
translate([200,0,0]) corner_2040();

motor_w = 42;
motor_r = 52/2;
slop=.2;

//corner();

%translate([-(beam+wall)/2,(beam+wall)/2,wall-.1]) rotate([0,0,90]) beam_2040(height=50);
%translate([-wall/2,-(beam+wall)/2,beam/2+wall-.1]) rotate([90,0,0]) beam_2040(height=50);
%translate([(wall)/2,(beam+wall)/2,beam/2+wall-.1]) rotate([0,90,0]) rotate([0,0,90])beam_2040(height=50);


module beamEnd(){
    difference(){
        cube([beam,beam,wall], center=true);
        beamSlots(slop=.25);
    }
}

//corner for using 2040 extrusion.
module corner_2040(motor=false, idler=false){
    difference(){
        union(){
            //base, seen from the outside.
            translate([0,0,wall/2]) cube([beam*2+wall,beam*3+wall,wall], center=true);
            translate([0,(beam+wall)/2-.1,beam+wall-.1]) cube([wall,beam*2+.2, beam*2+.1], center=true);
            
            hull(){
                translate([0,-beam/2,beam+wall-.1]) cube([beam*2+wall, wall, beam*2+.1], center=true);
            
                //motor mount
                if(motor==true)
                    translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) motor_mount(solid=1);
                //idler mount
                if(idler==true)
                    translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) idler_mount(solid=1);
            }
        }
        
        //side screwholes - the bottom as it's drawn
        for(i=[0,1]) translate([-beam/2-wall/2+beam*i,-beam-wall/2, 0]) screw_hole_m5(cap=false, onion=layer_height*1.5);
        for(i=[0,1]) mirror([i,0,0]) for(j=[0,1]) translate([-beam/2-wall/2,beam*j+wall/2, 0]) screw_hole_m5(cap=false, onion=layer_height*1.5);
            
        //front screwholes - the front beam gets 4 attachment points on the side
        for(i=[0,1]) for(j=[0,1])
            translate([-wall/2,wall/2+beam*i, wall+beam/2+beam*j]) rotate([0,90,0]) rotate([0,0,-90]) mirror([0,0,j]) translate([0,0,-wall*j]) screw_hole_m5(cap=true);
        
        //top screwholes - the vertical beam gets 2 attachment points.
        for(i=[0,1])
            translate([-beam/2-wall/2+beam*i,-beam/2+wall/2,beam/2+wall]) rotate([90,0,0]) rotate([0,0,180])screw_hole_m5(cap=true);
        
        //motor mount
        if(motor==true)
            translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) motor_mount(solid=-1);
        if(idler==true)
            translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) idler_mount(solid=-1);
    }
}

//the motor mount - gets attached inline.
//motor cutout and mount
module motor_mount(solid=0){
    if(solid>=0){
        motor_base();
    }
    if(solid<=0){
        motor_holes();
    }
}

module motor_base(h=wall){
	intersection(){
		translate([0,0,h/2]) cube([motor_w, motor_w, h], center=true);
		cylinder(r=motor_r+slop, h=h, $fn=64);
	}
    
    //extra idler
    TODO: make an extra idler above the motor, to guide the belt into the gap - belt should be 
}

module motor_holes(){
    hole_x = 31/2;
    slot = 1;
    center_rad = 12;
    center_height = 2.5;
    
    %cylinder(r=14, h=100, center=true);
    
    for(i=[0:90:359]) rotate([0,0,i]){
        translate([hole_x+slot, hole_x+slot, 0]) screw_hole_m3();
        translate([hole_x, hole_x, 0]) screw_hole_m3();
        translate([hole_x-slot, hole_x-slot, 0]) screw_hole_m3();
    }
    
    translate([0,0,wall]) cylinder(r=center_rad, h=center_height*2, center=true);
    
    cylinder(r=m5_cap_rad, h=wall*4, center=true);
}

//the idler mount - gets attached inline on the corners.
module idler_mount(solid=0){
    idler_rad = 19/2;
    
    if(solid>=0){
        cylinder(r=m5_cap_rad*2, h=wall);
        translate([idler_rad, idler_rad, 0]) cylinder(r=m5_cap_rad*2, h=wall);
    }
    if(solid<=0){
        mirror([0,0,1]) translate([0,0,-wall*2+3]) rotate([0,0,180]) screw_hole_m5(cap=true, height=15);
        translate([idler_rad, idler_rad, 0]) mirror([0,0,1]) translate([0,0,-wall*2+3]) rotate([0,0,180]) screw_hole_m5(cap=true, height=15);
    }
}

//a standard corner, with a slight twist - one beam is internal, the other two are surface-mount.  TODO: add flanges for the beams, to lock them against flexing?  Shouldn't be necessary with all corners installed, though.
module corner(){
	echo("BOM: 1, corner.scad");
	echo("BOM: 3, screws, M5, 10mm");  
	translate([0,0,-wall]) 
	difference(){
		union(){
			hull(){
				translate([-wall/4,wall/4,wall/2]) cube([beam+wall/2, beam+wall/2, wall], center=true);
				translate([0,beam/2+wall/2,beam/2+wall*3/4]) cube([beam, wall, beam+wall/2], center=true);
				translate([-beam/2-wall/2,0,beam/2+wall*3/4]) cube([wall, beam, beam+wall/2], center=true);
			}
			translate([-beam/2-wall/2,0,-beam/2+wall*3/4]) cube([wall, beam, beam+wall/2], center=true);
			translate([-beam/2-wall/2,beam,beam/2+wall*3/4]) cube([wall, beam, beam+wall/2], center=true);
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