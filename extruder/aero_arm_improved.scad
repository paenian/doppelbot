
tol = .2;

m5_rad = 5/2+tol;

%cylinder(r=2.5, h=13, $fn=64, center=true);
printable_arm();

//this is a version of the arm that's filled in & toleranced for easier printing
module printable_arm(){
    difference(){
        union(){
            orig_arm();
        }
        
        //open up the mounting hole
        cylinder(r=m5_rad, h=47, center=true, $fn=64);
    }
}


//this is the original arm, oriented
module orig_arm(){
    rotate([0,180,0]) translate([6.666,-23,13.5])
    rotate([0,0,180]) import("aero_arm.stl");
}
