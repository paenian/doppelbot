include <configuration.scad>

beam(40, true);

module beam(height=20, v=false){
	rad = 2;
	
	slot_w = 6;
	slot_d = 6;
	slot_inner_w = 14;
	slot_inner_h = 4;
	center_w = 5;

	difference(){
		hull(){
			for(i=[0:90:359])
				rotate([0,0,i])
					translate([beam/2-rad, beam/2-rad, 0]) cylinder(r=rad, h=height);
		}

		//slots
		for(i=[0:90:359]) rotate([0,0,i]){
			translate([beam/2,0,0]) cube([slot_d*2,slot_w,height*3],center=true);
			
			//angled inner
			hull(){
				translate([beam/2-slot_d,0,0]) cube([.1,slot_w,height*3],center=true);
				translate([beam/2-slot_d+slot_inner_h,0,0]) cube([.1,slot_inner_w,height*3],center=true);
			}

			//v rail
			if(v==true){
				hull(){
					translate([beam/2-slot_d+slot_inner_h,0,0]) cube([.1,slot_w,height*3],center=true);
					translate([beam/2-slot_d+slot_inner_h+10,0,0]) cube([.1,slot_w+20,height*3],center=true);
				}
			}
		}

		//center hole
		cube([center_w, center_w, height*3],center=true);
	}
}