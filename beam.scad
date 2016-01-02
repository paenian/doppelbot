include <configuration.scad>

beam(40, true, .25);

module beam_2040(height=20, v=false, slop=0){
    translate([-beam/2,0,0]) beam(height=height, v=v, slop=slop);
    translate([beam/2,0,0]) beam(height=height, v=v, slop=slop);
}

module beam(height=20, v=false, slop=0){
	rad = 2;
	

	center_w = 5;

	difference(){
		hull(){
			for(i=[0:90:359])
				rotate([0,0,i])
					translate([beam/2-rad, beam/2-rad, 0]) cylinder(r=rad+slop, h=height);
		}

		//slots
		beamSlots(height=height, v=v, slop=0);

		//center hole
		cube([center_w, center_w, height*3],center=true);
	}
}

module beamSlots(height=20, v=false, slop=0){
    slot_w = 6;
	slot_d = 6;
	slot_inner_w = 14;
	slot_inner_h = 4;
    
    for(i=[0:90:359]) rotate([0,0,i]){
			translate([beam/2,0,0]) cube([slot_d*2-slop*2,slot_w-slop*2,height*3],center=true);
			
			//angled inner
			hull(){
				translate([beam/2-slot_d+slop,0,0]) cube([.1,slot_w-slop*2,height*3],center=true);
				translate([beam/2-slot_d+slot_inner_h-slop,0,0]) cube([.1,slot_inner_w-slop*4,height*3],center=true);
			}

			//v rail
			if(v==true){
				hull(){
					translate([beam/2-slot_d+slot_inner_h+slop,0,0]) cube([.1,slot_w-slop*2,height*3],center=true);
					translate([beam/2-slot_d+slot_inner_h+10-slop,0,0]) cube([.1,slot_w+20-slop*2,height*3],center=true);
				}
			}
		}
}