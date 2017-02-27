in = 25.4;
pi = 3.14159;

wall = 6.5;
led_width = 15;

$fn = 180;

//lamp size variables
outer_rad = 220/2;
inner_rad = 170/2;
base_width = 75;
base_height = 60;
base_screw_rad = 3/2;
base_screw_sep = base_width*.4;
base_screw_drop = base_height/2-wall;


num_plates = ceil((led_width+wall*2) / wall);
echo(num_plates);
lamp_width = num_plates*wall;
echo(led_width + wall + wall);
echo(lamp_width);


//the inner hinge is compressed to stick into the slots - this is the compression.
inner_hinge_extra_length = 5;
inner_hinge_length = (inner_rad+wall)*pi*2 + inner_hinge_extra_length;


//this insets the outer hinge into the base a bit.
outer_hinge_extra_angle = 4;
//this is the angle that the hinge starts and ends at, to not hit the base.
outer_hinge_angle = asin((base_width/2)/outer_rad)-outer_hinge_extra_angle;

//the outer hinge is stretched to stick into the slots - this is the stretch.
inner_hinge_extra_length = -5;

//the calculation is diameter * degrees_of_hinge/360 - inner_hinge_extra_length
outer_hinge_length = outer_rad*pi*2*((360-outer_hinge_angle*2)/360) - inner_hinge_extra_length;


outer_tabs = 12;
inner_tabs = 10;

tab_width = wall;

//this is to fudge the outer hinge 
//base();
//translate([0,40,0]) stepped_base();
//translate([0,80,0]) switch_base();
//translate([0,120,0]) wire_base();

dxf_layout();

module dxf_layout(){
    projection(cut = true) layout();
}

module layout(){
    for(i=[-1,1]) translate([-i*outer_rad,0,0]) rotate([0,0,i*125]) {
        circle();
    }
    
    base();
    translate([0,40,0]) stepped_base();
    translate([0,80,0]) switch_base();
    translate([0,120,0]) wire_base();
        
    translate([0,-outer_rad-lamp_width*1.6,0]) outer_hinge();
    translate([0,-outer_rad-lamp_width/2,0]) inner_hinge();
    
}

module assembly(){
    for(i=[-1,1]) translate([0,0,i*(lamp_width-wall)/2]) circle();
        
    translate([0,-outer_rad-55,0]) outer_hinge();
    translate([0,-outer_rad-20,0]) inner_hinge();
}

module outer_hinge(){
    num_edge_cuts = outer_tabs * 4;
    num_center_cuts = num_edge_cuts;
    
    difference(){
        cube([outer_hinge_length, lamp_width, wall], center=true);
        
        //tabs
        for(j=[0:1]) mirror([0,j,0]) for(i=[-outer_hinge_length/2:outer_hinge_length/outer_tabs:outer_hinge_length/2])
            translate([i,lamp_width/2, 0]) cube([tab_width,wall*2,wall+1], center=true);
        
        
        //edge cuts
        for(j=[0:1]) mirror([0,j,0]) for(i=[-outer_hinge_length/2:outer_hinge_length/num_edge_cuts:outer_hinge_length/2+1])
            translate([i,lamp_width/2, 0]) edge_slice();
        
        //center cuts
        for(i=[-outer_hinge_length/2:outer_hinge_length/num_center_cuts:outer_hinge_length/2+1])
            translate([i-outer_hinge_length/num_center_cuts/2,0, 0]) center_slice();
    }
}

module inner_hinge(){
    num_edge_cuts = inner_tabs * 3;
    num_center_cuts = num_edge_cuts;
    
    difference(){
        cube([inner_hinge_length, lamp_width, wall], center=true);
        
        //tabs
        for(j=[0:1]) mirror([0,j,0]) for(i=[-inner_hinge_length/2:inner_hinge_length/inner_tabs:inner_hinge_length/2])
            translate([i,lamp_width/2, 0]) cube([tab_width,wall*2,wall+1], center=true);
        
        
        //edge cuts
        for(j=[0:1]) mirror([0,j,0]) for(i=[-inner_hinge_length/2:inner_hinge_length/num_edge_cuts:inner_hinge_length/2+1])
            translate([i,lamp_width/2, 0]) edge_slice();
        
        //center cuts
        for(i=[-inner_hinge_length/2:inner_hinge_length/num_center_cuts:inner_hinge_length/2+1])
            translate([i-inner_hinge_length/num_center_cuts/2,0, 0]) center_light();
    }
}

module center_light(){
    scale([.5,1,1]) cylinder(r=lamp_width/2-wall/2, h=wall+2, center=true, $fn=18);
}

module center_slice(){
    edge_slice();
}

module edge_slice(){
    scale([.1,1,1]) cylinder(r=lamp_width/2-wall/2, h=wall+2, center=true, $fn=18);
}

//extra plates for the base
module base(){
    difference(){
        translate([0,outer_rad,0]) cube([base_width, base_height, wall], center=true);
        
        //center hole
        cylinder(r=outer_rad, h=wall+1, center=true);
        
        //screwholes for the base
        for(i=[-base_screw_sep/2, base_screw_sep/2]) translate([i,outer_rad+base_screw_drop,0]){
            cylinder(r=base_screw_rad, h=wall*2, center=true);
        }
    }
}

//a base that's thinner than the usual
module stepped_base(step = 10){
    difference(){
        base();
        //step in the sides
        *for(i=[0,1]) mirror([i,0,0]) translate([base_width-step,outer_rad,0]) cube([base_width,base_height+2,wall+1],center=true);
        //step in the top
        cylinder(r=outer_rad+step, h=wall*2, center=true);
    }
}

switch_drop = 20;
//a base with holes in it to accept a micro switch
module switch_base(){
    switch_width = 23;
    switch_height = 18;
    difference(){
        base();
        
        //switch inset hole
        translate([0,outer_rad+switch_drop-switch_height/2,0]) cube([switch_width,switch_height,wall+2], center=true);
        
        //string hole
        translate([0,outer_rad,0]) cube([1,switch_height,wall+2], center=true);
    }
}

//a base with an inset to accept a power cord - there's two modified bases, so that they're both solid - otherwise it'd split into two pieces.
module wire_base(){
    wire_thick = 3;
    difference(){
        base();
        
        //wire hole
        translate([-base_width/2, outer_rad+switch_drop, 0]) cube([base_width, wire_thick, wall+2],center=true);
    }
}

module circle(){
    difference(){
        union(){
            cylinder(r=outer_rad, h=wall, center=true);
            translate([0,outer_rad,0]) cube([base_width, base_height, wall], center=true);
        }
        
        //center hole
        cylinder(r=inner_rad, h=wall+1, center=true);
        
        //screwholes for the base
        for(i=[-base_screw_sep/2, base_screw_sep/2]) translate([i,outer_rad+base_screw_drop,0]){
            cylinder(r=base_screw_rad, h=wall*2, center=true);
        }
        
        //inner tabs
        difference(){
            cylinder(r=inner_rad+wall, h=wall+1, center=true);
            
            for(i=[0:360/inner_tabs:359]) rotate([0,0,i]) translate([0,inner_rad,0]) cube([tab_width,wall*2,wall+2], center=true);
        }
        
        //outer_tabs - have to avoid the base
        difference(){
            cylinder(r=outer_rad+.5, h=wall+1, center=true);
            cylinder(r=outer_rad-wall, h=wall+2, center=true);
            
            //the tabs
            for(i=[outer_hinge_angle:(360-outer_hinge_angle*2)/outer_tabs:359-outer_hinge_angle/2]) rotate([0,0,i]) translate([0,outer_rad-wall,0]) cube([tab_width,wall*3,wall+2], center=true);
                
            //fill in between the two bottom tabs
            hull(){
                rotate([0,0,outer_hinge_angle]) translate([0,outer_rad-25,-25]) cube([50,50,50]);
                mirror([1,0,0]) rotate([0,0,outer_hinge_angle]) translate([0,outer_rad-25,-25]) cube([50,50,50]);
            }
        }
    }
}