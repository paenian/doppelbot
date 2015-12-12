include <configuration.scad>
include <functions.scad>
use <beam.scad>

wall=3;

gantry_length = 60;
//width is defined by the beam profile.

cyclops_width=30;
cyclops_drop = 18; //how far down the cyclops should be.

ind_rad = 18/2+slop;
ind_offset = beam/2+ind_rad+wall+1;
ind_lift = 20;
ind_height = 12;

//flip for printing
translate([0,0,wall]) rotate([180,0,0]) 
hotend_carriage();

translate([0,100,-50]) gantry_end();

translate([0,100,50])mirror([0,1,0]) gantry_end();

//the top of the gantry
module gantry_end(){
    
}

//just a little spar below the gantry to make sure it remains level
module gantry_clamp(){
}

module hotend_carriage(){
    wall=3;
    min_rad = 2;
    
    %translate([0,0,-beam-1]) cube([beam*5,beam,beam*2],center=true);
    difference(){
        union(){
            
            //guide wheels
            difference(){
                guide_wheel_helper(solid=1);
                
                //cutout for the cyclops
                translate([0,beam/2+wall+1+min_rad+10,-cyclops_drop-wall]) minkowski(){
                    cube([cyclops_width-min_rad*2,20,100], center=true);
                    cylinder(r=min_rad, h=1);
                }
                
                //round the front corners
                for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2+min_rad,beam/2+m5_rad+wall+1,0]) difference(){
                    translate([-min_rad-1,0,-wall]) cube([min_rad+1, min_rad+1, wall*5]);
                    cylinder(r=min_rad, h=wall*11, center=true);
                }
            }
            
            //cyclops mount
            translate([0,beam/2+wall+1,-cyclops_drop-wall]) {
                hull() {
                    for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2-wall,0,cyclops_drop+wall]){
                        rotate([90,0,0]) cylinder(r=wall, h=wall);
                    }
                    cyclops_holes(solid=1, jut=0, wall=wall);
                }
                intersection(){
                    for(i=[0,1]) mirror([i,0,0]) rotate([0,23.5,0]) hull(){
                        translate([-1.5,-.1,0]) cube([3, .1, cyclops_drop*2]);
                        translate([-.5,2-.1,0]) cube([1, .1, cyclops_drop*2]);
                    }
                    cube([cyclops_width, 30, cyclops_drop*2+wall*2+wall*2], center=true);
                }
                cyclops_holes(solid=1, jut=1, wall=wall);
            }
            
            //induction sensor mount
            translate([0, -ind_offset,-ind_height+wall-ind_lift]) mirror([0,1,0]){
                extruder_mount(solid=1, m_height=ind_height,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                translate([0,0,ind_height-.1]) cylinder(r=(ind_rad+wall)/cos(30), h=ind_lift+.1, $fn=6);
            }
            
        } //Holes below here
        
        //guide wheels
        guide_wheel_helper(solid=-1);
        
        //belt screws
        belt_screwholes();
        
        //cyclops mount
        translate([0,beam/2+wall+1,-cyclops_drop-wall]) cyclops_holes(solid=-1, jut=0, wall=wall);
        
        //induction sensor mount
        translate([0, -ind_offset,-ind_height+wall-ind_lift]) mirror([0,1,0]){
                extruder_mount(solid=0, m_height=ind_height,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                translate([0,0,ind_height-.1]) cylinder(r1=ind_rad, r2=ind_rad+2, h=ind_lift+.15);
            }
    }
}

module guide_wheel_helper(solid=0){
    min_rad=3;
    if(solid >= 0){
        difference(){
            hull(){
                for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
                    translate([0,beam/2+wheel_rad,0]) cylinder(r=.1, h=wall);
                    translate([0,-beam/2-wheel_rad,0]) cylinder(r=.1, h=wall);
                }
            }
            
            for(i=[0,1]) mirror([i,0,0]) translate([gantry_length/2,0,-.1]){
                hull() for(j=[0,1]) mirror([0,j,0]) translate([0,beam/2+wheel_rad-m5_rad-wall-min_rad,0]) 
                    cylinder(r=min_rad, h=wall+.2);
            }
            for(i=[0,1]) mirror([0,i,0]) translate([0,beam/2+wheel_rad,-.1]){
                hull() for(j=[0,1]) mirror([j,0,0]) translate([gantry_length/2-m5_rad-wall-min_rad/2,0,0]) 
                    cylinder(r=min_rad/2, h=wall+.2);
            }
        }
        
        for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
            translate([0,beam/2+wheel_rad,0]) cylinder(r=m5_rad+wall, h=wall);
            translate([0,-beam/2-wheel_rad,0]) cylinder(r=m5_rad+wall, h=wall);
        }
    }
    if(solid <= 0){
        for(i=[-1,1]) translate([i*gantry_length/2,0,-.1]){
            translate([0,beam/2+wheel_rad,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,-beam/2-wheel_rad,0]) cylinder(r=eccentric_rad, h=wall+1);
        }
    }
}

module belt_screwholes(){
    for(i=[-1,1]) translate([i*(gantry_length/2-wheel_rad),0,-.1]){
            translate([0,beam/2+m5_rad+1,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,-beam/2-m5_rad-1,0]) cylinder(r=m5_rad, h=wall+1);
        }
}

//mounting holes for the cyclops
module cyclops_holes(solid=0, jut=0){
    hole_sep = 9;
    hole_zsep = 10;
    ind_jut = 2;
    flat = 2;
    
    for(i=[0,1]) mirror([i,0,0]){
        translate([hole_sep/2,-wall,hole_zsep]) rotate([-90,0,0]){
            if(solid>=0){
                cylinder(r=m3_rad+flat, h=wall);
                if(jut==1){
                    translate([0,0,wall-.1]) cylinder(r1=m3_rad+flat, r2=m3_rad+flat/2, h=ind_jut+.1);
                }
            }
            if(solid<=0) translate([0,0,-.1]) {
                rotate([0,0,180]) cap_cylinder(r=m3_rad, h=wall*50, center=true);
                rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
            }
        }
    }
    
    translate([0,-wall,0]) rotate([-90,0,0]){
        if(solid>=0){
            cylinder(r=m3_rad+flat+1, h=wall);
            if(jut==1){
                translate([0,0,wall-.1]) cylinder(r1=m3_rad+flat, r2=m3_rad+flat/2, h=ind_jut+.1);
            }
        }
        if(solid<=0) translate([0,0,-.1]) {
            %translate([0,-wall,9+wall+ind_jut+.1]) cube([30,50,18], center=true);
            %translate([0,-wall,6+wall+ind_jut+.1]) rotate([90,0,0]) cylinder(r=1, h=50, center=true);
            rotate([0,0,180]) cap_cylinder(r=m3_rad, h=wall*50, center=true);
            rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
            
            //cutout above the block
        }
    }
}

//reusing this to make the induction mount :-)
module extruder_mount(solid = 1, m_height = 10, m_thickness=50, fillet = 8, tap_height=0, width=20){
	gap = 3;
	tap_dia = 9.1;
	tap_rad = tap_dia/2;
	
	clamp_offset = 1.5+1.5;
    nut_rad = 5;
    
    bolt_rad = m3_rad;

	if(solid){		
		//clamp material
		if(m_height > nut_rad*2){
			cylinder(r=(hotend_rad+wall)/cos(30), h=m_height, $fn=6);
			hull(){
                translate([hotend_rad+bolt_rad+clamp_offset,gap,m_height/2]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
                translate([hotend_rad+bolt_rad+clamp_offset,gap,m_height/2]) rotate([0,60,0]) translate([-20,0,0]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
            }
			hull(){
                translate([hotend_rad+bolt_rad+clamp_offset,-wall-1,m_height/2]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
                translate([hotend_rad+bolt_rad+clamp_offset,-wall-1,m_height/2]) rotate([0,60,0]) translate([-20,0,0]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
            }
		}
	}else{
		union(){
			//hotend hole
			translate([0,0,-.05]) cylinder(r=hotend_rad/cos(180/18)+.1, h=m_height*3, $fn=36);
            //flare the underside
            translate([0,0,-16]) cylinder(r1=hotend_rad/cos(180/18)+2 , r2=hotend_rad/cos(180/18)+.1, h=16, $fn=36);

			//bolt slots
			if(m_height > nut_rad*2){
				render() translate([hotend_rad+bolt_rad+clamp_offset,-m_thickness-.05,m_height/2]) rotate([-90,0,0]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=m_thickness+10);
				translate([hotend_rad+bolt_rad+clamp_offset,-wall*3.5-1,m_height/2]) rotate([-90,0,0]) cylinder(r2=m3_nut_rad, r1=m3_nut_rad+2, h=wall*3, $fn=6);

				//mount tightener
				translate([hotend_rad+bolt_rad+clamp_offset,wall+gap,m_height/2]) rotate([-90,0,0]) rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=10);
				translate([0,0,-m_height*2]) cube([wall*5, gap, m_height*10+.1]);
			}
		}
	}
}