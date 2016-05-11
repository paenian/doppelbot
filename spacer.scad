length = 20;

difference(){
    cylinder(r=5, h=length, center=true, $fn=6);
    cylinder(r=2, h=length+1, center=true, $fn=36);
}