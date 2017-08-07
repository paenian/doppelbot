
tol = .2;

m5_rad = 5/2+tol;

%cylinder(r=2.5, h=13, $fn=64, center=true);
printable_arm();
translate([-11,0,0]) idler_support_washer();
translate([-13.5,12,0]) rotate([0,0,-45]) shaft_support_insert(thick = 2);

//draw in place
%translate([idler_offset_x, idler_offset_y, 0]) rotate([0,0,180]) mirror([0,0,1]) idler_support_washer();
%translate([0, 0, -2.05]) rotate([0,0,180]) shaft_support_insert(thick = 2);

arm_thick = 8;
arm_width = 10;
arm_length = 40;

idler_offset_y = 16;
idler_offset_x = -5.5;

filament_guide_offset_x = -11;
filament_guide_rad = 4/2;
filament_guide_length = 18;
filament_rad = 1.75/2+tol;

nub_rad = 4/2-tol/2;
nub_offset_x = 3;
nub_offset_y = 23;

//bearing size for the motor shaft
bearing_rad = 10/2+tol/2;
bearing_thick = 4;
bearing_inner_rad = 8/2+tol;
bearing_washer_thick = .5;
bearing_bore = 5/2-tol/2;

$fn = 64;

//this is a version of the arm that's filled in & toleranced for easier printing
module printable_arm(){
    wall = 2;
    min_rad = .5;
    %rotate([0,180,0]) orig_arm();
    difference(){
        union(){
            //main body
            translate([0,arm_length/2,0]) minkowski(){
                union(){
                    //arm
                    cube([arm_width-min_rad*2, arm_length-min_rad*2, arm_thick-min_rad*2], center=true);
                    //filament guide
                    translate([filament_guide_offset_x,arm_length/2-filament_guide_length/2,0]) cube([filament_guide_rad*2+wall*2,filament_guide_length-min_rad*2,arm_thick-min_rad*2], center=true);
                    //connect them a bit better
                    translate([filament_guide_offset_x/2,arm_length/2-filament_guide_length/2,0]) cube([filament_guide_rad*2+wall*2,filament_guide_length-min_rad*4,arm_thick/2-min_rad*2], center=true);
                }
                sphere(r=.5, $fn=12);
            }
            
            //bearing meat
            cylinder(r=bearing_rad+wall, h=arm_thick, center=true);
            
            //idler meat
            intersection(){
                translate([idler_offset_x, idler_offset_y]) cylinder(r=bearing_rad+wall, h=arm_thick, center=true);
                cube([arm_width+wall*3,100,arm_thick], center=true);
            }
            
            //nubbin - really not useful, the nub clear out overwrites it.
            translate([nub_offset_x, nub_offset_y, 0]) sphere(r=nub_rad);
        }
        /////////////////////CUTOUTS
        
        
        
        //filament guide hole - this is for a teflon tube
        translate([0,arm_length/2+wall,0]){
            //tube hole
            translate([filament_guide_offset_x,arm_length/2-filament_guide_length/2,0]) rotate([90,0,0]) cylinder(r=filament_guide_rad, h=filament_guide_length, center=true);
            //slit on top, to make sure the tube is in
            translate([filament_guide_offset_x,arm_length/2-filament_guide_length/2-wall/2,arm_thick/2]) cube([wall/2,filament_guide_length+1,arm_thick], center=true);
            
            //filament hole
            translate([filament_guide_offset_x,0,0]) rotate([90,0,0]) cylinder(r=filament_rad, h=arm_length, center=true);
        }
        
        //bearing mount on the motor shaft
        translate([0,0,-bearing_thick/2+arm_thick/2]) cylinder(r=bearing_rad, h=bearing_thick+.1, center=true, $fn=64);
        cylinder(r=bearing_inner_rad, h=arm_thick+1, center=true, $fn=64);
        //this cuts out a bottom corner so that it misses the hotend holder.  Probably glue the bearing in, but really there's nowhere for it to go.
        translate([-bearing_rad,-bearing_rad,0]) cube([bearing_rad*2, bearing_rad*2, arm_thick+2], center=true);
        
        //idler mount
        translate([idler_offset_x, idler_offset_y])
        difference(){
            hull() {
                cylinder(r=bearing_rad+.5, h=bearing_thick+bearing_washer_thick*2, center=true);
                translate([0,0,arm_thick]) cylinder(r=bearing_rad+.75, h=bearing_thick, center=true);
            }
            
            //bottom washer
            translate([0,0,-bearing_thick/2-bearing_washer_thick-.1]) cylinder(r1=bearing_rad, r2=bearing_inner_rad-1, h=bearing_washer_thick+.1);
            //shaft
            cylinder(r1=bearing_bore, r2=bearing_bore-tol/2, h=arm_thick, center=true);
        }//end idler mount
        
        //nubbin - really not useful, the nub clear out overwrites it.
        difference(){
            translate([arm_width/2, nub_offset_y+wall-.25, 0]) hull(){
                cube([(arm_width/2-nub_offset_x)*2+1,10,arm_thick+1], center=true);
                translate([arm_width,0,0]) cube([(arm_width/2-nub_offset_x)*2+1,15,arm_thick+1], center=true);
            }
            
            hull(){
                translate([nub_offset_x, nub_offset_y, 0]) sphere(r=nub_rad);
                translate([0, nub_offset_y, 0]) sphere(r=nub_rad+.5);
            }
        }
    }
}

module idler_support_washer(){
    difference(){
        union(){
            translate([0,0,-arm_thick/2]) cylinder(r=bearing_rad+.75-tol, h=1.45);
            //washer
            translate([0,0,-bearing_thick/2-bearing_washer_thick-.1]) cylinder(r1=bearing_rad-tol, r2=bearing_inner_rad-1, h=bearing_washer_thick+.1);
        }
        
        cylinder(r1=bearing_bore+tol/2, r2=bearing_bore+tol, h=arm_thick+.1, center=true);
        
        //flat to miss the inside of the hotend mount
        translate([bearing_rad*2-2,0,0]) cube([bearing_rad*2, 20, arm_thick+1], center=true);
    }    
}

module shaft_support_insert(thick = 2){
    translate([0,0,-arm_thick/2])

    union(){
        difference(){
            //the base
            cylinder(r=bearing_inner_rad+2, h=thick);
            //missing a chunk for the hotend mount clearance
            translate([bearing_inner_rad+2,bearing_inner_rad+2,0]) cylinder(r=bearing_inner_rad+2, h=thick*4, center=true);
        }
        cylinder(r1=bearing_inner_rad-tol*1.5, r2=bearing_inner_rad-tol*2, h=thick+arm_thick/2-1);
    }
}

//this is the original arm, oriented
module orig_arm(){
    rotate([0,180,0]) translate([6.666,-23,13.5])
    rotate([0,0,180]) import("aero_arm.stl");
}
