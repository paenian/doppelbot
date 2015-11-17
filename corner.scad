include <configuration.scad>
include <functions.scad>
use <beam.scad>

inside_rad = .5;

corner_2040(motor=true);
translate([100,0,0]) mirror([1,0,0])  corner_2040(motor=true);
translate([0,0,150]) mirror([0,0,1]) corner_2040(idler=true);
translate([100,0,150]) mirror([0,0,1]) mirror([1,0,0]) corner_2040(idler=true);



motor_w = 42;
motor_r = 52/2;
slop=.2;

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
module corner_2040(motor=false, idler=false, guide_bearing=true){
    guide_offset=15;
    
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
                //guide bearing
                if(guide_bearing==true)
                    translate([idler_rad,-beam/2+wall/2,beam*2+wall+guide_offset]) rotate([90,0,0]) {
                        cylinder(r=idler_flange_rad, h=wall);
                        %cylinder(r=pulley_flange_rad, h=wall*3, center=true);
                        %cylinder(r=pulley_rad, h=wall*5, center=true);
                    }
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
            translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) motor_mount(solid=-1, guide_bearing=guide_bearing);
        if(idler==true)
            translate([motor_w/2,-beam/2+wall/2,beam*2+wall]) rotate([90,0,0]) idler_mount(solid=-1);
        //guide bearing
        if(guide_bearing==true)
            translate([idler_rad,-beam/2+wall/2+.5-wall-2,beam*2+wall+guide_offset]) rotate([-90,0,0]) screw_hole_m5(cap=true, height=15);
    }
}

//the motor mount - gets attached inline.
//motor cutout and mount
module motor_mount(solid=0, guide_bearing=false){
    if(solid>=0){
        motor_base();
    }
    if(solid<=0){
        motor_holes(guide_bearing);
    }
}

module motor_base(h=wall){
	intersection(){
		translate([0,0,h/2]) cube([motor_w, motor_w, h], center=true);
		cylinder(r=motor_r+slop, h=h, $fn=64);
	}
}

module motor_hole(hole_x = 31/2, slot = 1){
    translate([hole_x+slot, hole_x+slot, 0]) screw_hole_m3();
    translate([hole_x, hole_x, 0]) screw_hole_m3();
    translate([hole_x-slot, hole_x-slot, 0]) screw_hole_m3();
}

module motor_holes(guide_bearing=false){
    hole_x = 31/2;
    slot = 1;
    center_rad = 12;
    center_height = 2.5;
    
    %cylinder(r=pulley_flange_rad, h=wall*3, center=true);
    %cylinder(r=pulley_rad, h=wall*5, center=true);
    
    if(guide_bearing==false){
        for(i=[0:90:359]) rotate([0,0,i]){
            motor_hole();
        }
    }else{
        for(i=[180:90:449]) rotate([0,0,i]){
            motor_hole();
        }
    }
    
    translate([0,0,wall]) cylinder(r=center_rad, h=center_height*2, center=true);
    
    cylinder(r=m5_cap_rad, h=wall*4, center=true);
}

//the idler mount - gets attached inline on the corners.
module idler_mount(solid=0){
    if(solid>=0){
        //cylinder(r=idler_flange_rad, h=wall);  this is replaced by the guide wheel
        *translate([idler_rad+pulley_rad, 0, 0]) {
            cylinder(r=idler_flange_rad, h=wall);
            %cylinder(r=pulley_flange_rad, h=wall*3, center=true);
            %cylinder(r=pulley_rad, h=wall*5, center=true);
        }
    }
    if(solid<=0){
        //mirror([0,0,1]) translate([0,0,-wall*2+3]) rotate([0,0,180]) screw_hole_m5(cap=true, height=15);
        //translate([idler_rad+pulley_rad, 0, 0]) mirror([0,0,1]) translate([0,0,-wall*2+3]) rotate([0,0,180]) screw_hole_m5(cap=true, height=15);
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