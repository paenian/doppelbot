box_x = 43;
box_y = 44;
box_z = 30;

lens_base_rad = 16/2+1;
lens_base_height = 8;
lens_top_rad = 14/2+.5;
lens_height = 15+3;

ant_base_rad = 10/2+.25;
ant_base_height = 36;
ant_z_inset = 7;

wire_offset_x = 8;
wire_offset_y = box_y/2-7;
wire_rad = 9/2;

body_rad = 38;
body_lift = 10;

body_screw_rad = 3.3/2;
body_screw_cap_rad = 6/2;
body_screw_cap_height = 2;

tooth_rad = body_lift;
tooth_screw_rad = 5.5/2;
tooth_facets = 16;
tooth_inner_rad = 1;
tooth_outer_rad = 3;


m5_rad = 5/2+.5;
m5_cap_rad = 10/2;
m5_sq_nut_rad = 11/2+.1;

//echo(2*m5_sq_nut_rad/sqrt(2));


wall = 4;

part = 10;
facets = 30;
$fn = facets;

if(part == 0)
    difference(){
        body();
        camera();
    }
if(part == 1)
    mirror([0,0,1]) body_rear();
if(part == 2)
    clamp();

if(part == 10)
    assembled();

module assembled(){
    difference(){
        union(){
            body();
            translate([0,0,-50]) body_rear();
            clamp();
        }
    
        #camera();
    }
}

module camera(){
    difference(){
        union(){
            //camera
            translate([0,0,box_z/2]) cube([box_x, box_y, box_z+.1], center=true);
            
            //lens
            hull(){
                cylinder(r=lens_base_rad, h=box_z+lens_base_height);
                cylinder(r=lens_top_rad, h=box_z+lens_base_height+2);
            }
            cylinder(r=lens_top_rad, h=box_z+lens_height);
            
            //antenna
            hull(){
                translate([0,0,ant_z_inset]) rotate([90,0,0]) cylinder(r=ant_base_rad, h=ant_base_height+box_y/2);
                rotate([90,0,0]) cylinder(r=ant_base_rad, h=ant_base_height+box_y/2);
            }
            
            //wires
            translate([wire_offset_x, wire_offset_y, -5]) cylinder(r=wire_rad, h=10);
            translate([wire_offset_x, wire_offset_y, 0]) rotate([0,0,18]) rotate([-90,0,0]) cylinder(r=wire_rad, h=25);
        }
    }
}

module body(){
    difference(){
        union(){
            //body
            translate([0,0,body_lift]) sphere(r=body_rad);
            
            //teeth bump
            hull(){
                translate([0,0,body_lift]) rotate([0,90,0]) cylinder(r=tooth_rad, h=body_rad*2, center=true);
                translate([0,0,body_lift]) rotate([0,90,0]) cylinder(r=tooth_rad*2, h=body_rad, center=true);
            }
            
            //antenna gaurd?
        }
        
        //teeth cuts
        for(i=[0,1]) mirror([i,0,0]) translate([body_rad+.75,0,body_lift]) rotate([0,90,0]) for(i=[0:360/tooth_facets:359]){
            translate([0,0,0]) rotate([0,0,i]) rotate([0,90,0]) cylinder(r1=tooth_inner_rad, r2=tooth_outer_rad, h=tooth_rad+3, $fn=4);
        }
            
        //screws
        body_screws();
        
        //mounting holes to the clamp
        side_screws();
        
        //cut off the butt
        translate([0,0,-50]) cube([100,100,100], center=true);
    }
}

module side_screws(){
    //translate([0,0,-body_lift])
    #union()for(i=[0,1]) mirror([i,0,0]) {
        translate([box_x/2+wall,0,body_lift]){
            //screw
            translate([-wall+1,0,0]) rotate([0,90,0]) cylinder(r=m5_rad, h=20);
            
            //screw cap
            translate([-wall+1+20,0,0]) rotate([0,90,0]) cylinder(r=m5_cap_rad+1, h=20);
            
            //nut
            rotate([0,90,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad, h=6, $fn=4);
            hull(){
                translate([0,0,-m5_sq_nut_rad]) rotate([0,90,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad, h=5, $fn=4);
                
                translate([0,0,-body_lift]) rotate([0,90,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad+1, h=5, $fn=4);
            }
        }
        
    }
}

module clamp(){
    flange_sep = 41;
    
    gap = 3;
    translate([0,-body_lift,body_lift]) rotate([-90,0,0]) 
    difference(){
        union(){
            //main body
            translate([0,0,body_lift]) intersection(){
                sphere(r=body_rad+wall+gap);
                hull(){
                    rotate([0,90,0]) cylinder(r=tooth_rad, h=body_rad*3, center=true);
                    translate([0,0,50]) rotate([0,90,0]) cylinder(r=tooth_rad, h=body_rad*3, center=true);
                }
            }
            
            //attach to stalk
            translate([0,0,body_rad+gap-wall]) hull(){
                //cylinder(r=32/2, h=wall*2);
                for(i=[0,1]) mirror([i,0,0]) translate([20,0,0])
                    cylinder(r=tooth_rad, h=wall*5);
            }
        }
        
        difference(){
            //hollow out around the body
            translate([0,0,body_lift]) sphere(r=body_rad+gap);
   
            //teeth
            for(i=[0,1]) mirror([i,0,0]) intersection(){
                translate([body_rad+gap/2,0,body_lift]) rotate([0,90,0]) for(i=[0:360/tooth_facets:359]){
                    translate([0,0,0]) rotate([0,0,i]) rotate([0,90,0]) cylinder(r1=tooth_inner_rad, r2=tooth_outer_rad, h=tooth_rad+3, $fn=4);
                }
                
                translate([body_rad-.75,0,body_lift]) rotate([0,90,0])  cylinder(r=tooth_rad, h=wall+2);
            }
            
            
        }
        
        //mounting holes to the camera
        side_screws();
        
        //hole for the wires
        cylinder(r=10/2, h=body_rad*4, center=true);
        
        translate([0,0,body_rad+wall*2+gap-1.5]) rotate([90,0,0]) scale([2,1,1]) cylinder(r=10/2, h=body_rad*4, center=true);
        
        //mount to the flange
        for(i=[0,1]) mirror([i,0,0]) translate([flange_sep/2,0,body_rad]){
            cylinder(r=m5_rad, h=25);
            cylinder(r2=m5_sq_nut_rad, r1=m5_sq_nut_rad+1, h=wall*3.5+gap, $fn=4);
        }
    }
}

module body_rear(){
    difference(){
        union(){
            translate([0,0,body_lift]) sphere(r=body_rad);
        }
        
        //screws
        body_screws();
        
        //cut off the notbutt
        translate([0,0,50]) cube([100,100,100], center=true);
    }
}

module body_screws(){
    union(){
        for(i=[0,1]) mirror([0,i,0]) mirror([i,0,0]) translate([box_y/2+m5_sq_nut_rad/sqrt(2),box_x/3,0]){
            //screw
            translate([0,0,-20]) cylinder(r=m5_rad, h=20+wall);
            
            //nut
            translate([0,0,wall/2]) rotate([0,0,45]) cylinder(r1=m5_sq_nut_rad, r2=m5_sq_nut_rad+1, h=5, $fn=4);
            
            translate([0,0,wall/2+5]) rotate([0,0,45]) cylinder(r1=m5_sq_nut_rad+1, r2=1, h=5, $fn=4);
            
            
            //screw cap
            translate([0,0,-20-wall/2]) cylinder(r=m5_cap_rad, h=20);
            
            *rotate([0,180,0]){
                translate([0,0,3]) cylinder(r1=body_screw_rad, r2=body_screw_cap_rad, h=body_screw_cap_height+.1);
                translate([0,0,3+body_screw_cap_height]) cylinder(r=body_screw_cap_rad, h=20);
            }
            
        }
    }
}