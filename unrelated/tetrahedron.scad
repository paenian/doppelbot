


rad = 250;

echo("Height = ");
echo(rad*1.5/12);
echo("Width = ");
echo(rad*sqrt(3)/12);

echo("Side Len = ");
echo((rad*sqrt(3)/2)/12);

projection() tetrahedron();

%translate([rad/4,0,0]) cube([rad*1.5, rad*sqrt(3), .1], center=true);
%translate([0,0,0]) cube([600, 1000, .05], center=true);

module tetrahedron(){
    difference(){
        union(){
            hull() for(i=[0:360/3:259]) rotate([0,0,i]) {
                translate([rad,0,0]) cylinder(r=1, h=1, center=true);
            }
        }
        
        //slots for folding
        for(i=[-60:360/3:259]) {
            hull(){
                #rotate([0,0,i]) translate([rad/2,0,0]) rotate([0,0,60]) translate([0,rad/10,0]) cylinder(r=1, h=2, center=true);
                #rotate([0,0,i+120]) translate([rad/2,0,0]) rotate([0,0,-60]) translate([0,-rad/10,0]) cylinder(r=1, h=2, center=true);
            }
        }
    }
}