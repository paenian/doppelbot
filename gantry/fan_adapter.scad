// adapt a 40mm fan to a 30mm mount


fan1_width = 30;
fan1_screw_rad = 3.4/2;
fan1_screw_sep = 24;

fan2_width = 40;
fan2_screw_rad = 3.4/2;
fan2_screw_sep = 32;

shift = 5;

wall = 2.5;

adaptFan();

module fan(width = 40){
    min_rad = 2;
    hull()
        for(i=[-1,1]) for(j=[-1,1]) translate([i*(width-min_rad*2)/2, j*(width-min_rad*2)/2, 0]) 
            cylinder(r=min_rad, h=wall, center=true);
}

module fan_holes(width = 40, screw_sep = 0, screw_rad = 3.4/2){
    for(i=[-1,1]) for(j=[-1,1]) translate([i*screw_sep/2, j*screw_sep/2, 0])
        cylinder(r=screw_rad, h = wall*2, center=true);
    
    //cylinder(r=width/2-wall/2, h=wall*2, center=true);
}

module adaptFan(height = 10, shift = 5){
    difference(){
        union(){
            fan(fan1_width);
            translate([shift,shift,height-wall]) fan(fan2_width);
            
            //tube
            hull(){
                cylinder(r=fan1_width/2, h=wall, center=true);
                translate([shift,shift,height-wall]) cylinder(r=fan2_width/2, h=wall, center=true);
            }
        }
        
        fan_holes(width = fan1_width, screw_sep = fan1_screw_sep, screw_rad = fan1_screw_rad);
        translate([shift,shift,height-wall]) fan_holes(width = fan2_width, screw_sep = fan2_screw_sep, screw_rad = fan2_screw_rad);
        
        //tube
        hull(){
            cylinder(r=fan1_width/2-wall/2, h=wall+1, center=true);
            translate([shift,shift,height-wall]) cylinder(r=fan2_width/2-wall/2, h=wall+1, center=true);
        }
    }
}



// fans' parameters
// wall thickness
t_wall = 2.5;
// fan 1: diameter
d_fan1 = 30;
// fan 1: distance between screw openings
ls_fan1 = 24;  
// fan 1: screw openings' diameter
ds_fan1 = 3.4;  
// fan 2: diameter
d_fan2 = 40;  
// fan 2: distance between screw openings
ls_fan2 = 32;
// fan 2: screw opening diameters
ds_fan2 = 3.4;   

// larger fan cone parameters
// length to manifold elbow  
l_mani1 = 0;
// cone angle
a_cone = 100;
// length to manifold elbow  
l_mani2 = 0;

// manifold parameters
// manifold angle
a_mani = 0;     
// z-axis rotation angle of the manifold elbow
az_mani = 0;     
// internal parameters
// pipe reduction ratio relative to fan 1 diameter
n_pipe = 1;
// angle factor
n_angle = 0.501;

// other advanced variables
// used to control the resolution of all arcs 
$fn = 90;        

// modules library
module fanplate(d,ls,t,ds) 
{
    /*
    d   : diameter of the fan
    ls  : distance between screws
    t   : wall thickness
    ds  : diameter of screws 
    */
    difference()
    {
        difference()
        {
            difference()
            {
                difference()
                {
                    //translate([d*0.1+d/-2,d*0.1+d/-2,0]) minkowski()
                    translate([-0.45*d,-0.45*d,0]) minkowski()
                        { 
                         //cube([d-2*d*0.1,d-2*d*0.1,t/2]);
                         cube([d*0.9,d*0.9,t/2]);
                         cylinder(h=t/2,r=d*0.05);
                        }
                    translate([ls/2,ls/2,0]) cylinder(d=ds,h=t);
                }
                translate([ls/-2,ls/2,0]) cylinder(d=ds,h=t);
            }
            translate([ls/-2,ls/-2,0]) cylinder(d=ds,h=t);
        }
        translate([ls/2,ls/-2,0]) cylinder(d=ds,h=t);
    }
}

module mani_elbow(a,d,t,az)
{
    // this is the manifold elbow
    // a  : angle of the elbow
    // d  : diameter of the elbow
    // t  : wall thickness
    
    rotate([0,0,az]) translate([-1*n_angle*d,0,0]) rotate([-90,0,0]) difference()
    {
        difference()
        {  
            difference()
            {
                rotate_extrude() translate([n_angle*d,0,0]) circle(r = d/2);
                rotate_extrude() translate([n_angle*d,0,0]) circle(r = (d-2*t)/2);
            }
            translate([-2*d,0,-2*d]) cube([4*d,4*d,4*d]);
        }
        rotate([0,0,90-a]) translate([-4*d,-2*d,-2*d]) cube([4*d,4*d,4*d]);
    }
}