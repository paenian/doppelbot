/*
 * this is all the bits for the bed, including:
 * * laser cut endcaps & support beams
 * * printed lead screw adapters - connect the bed endcaps to the leadscrew nuts.
 */

include <../configuration.scad>
include <../functions.scad>
use <../endcap/endcap.scad>
use <../beam.scad>
use <../connectors.scad>

top_width = 80; //width of the upper support ribs
center_gap = 40;    //channel in the middle for the wires
rail_sep = bed_y + beam + m5_cap_rad/2; //center-to-center rail distance.
top_length = rail_sep + beam;

side_width = beam+mdf_wall;
side_length = rail_sep - beam;

bed_screw_offset = (m5_washer_rad-mdf_wall)/2;  //this is used to make sure that the side-tensioning screws of the bed plates don't protrude - so that the top plate and side plates are flush, but the screw cap and nut don't stick up past the top.

//render everything
part=0;

//parts for laser cutting
if(part == 0)
    bed_top_projected();
if(part == 1)
    bed_inside_projected();
if(part == 2)
    bed_outside_projected();
if(part == 3)
    bed_brace_projected();
if(part == 4)
    bed_clamp();

in=25.4;

//view the assembly
if(part == 10){
    //glass top
    %translate([12*in,0,mdf_wall*2]) cube([24*in, 12*in, .25*in], center=true);
    
    //render an endcap for scale/matching
    %translate([-89-35,0,frame_z/2-mdf_wall/2-6]) rotate([0,0,90]) rotate([90,0,0]) assembled_endcap(motor=true);
    
    //render some rails in
    %for(i=[-1,1]) translate([0,i*rail_sep/2,-beam/2-mdf_wall/2]) rotate([0,90,0]) beam(800, true, .25);
    
    //endplate
    bed_top_connected();
    
    translate([-.1,0,0]) bed_outside_connected();
    
    translate([.1,0,0]) bed_inside_connected();
    
    //brace
    translate([300,0,0]) {
        bed_brace_connected();
        
        translate([-top_width-.1-mdf_wall,0,0]) bed_inside_connected();
    
        translate([.1,0,0]) bed_inside_connected();
    }
}

module bed_clamp(){
    bed_thick = 7;
    bed_offset = 8;
    hook = 3;
    
    base_thick = 1.5;
    difference(){
        union(){
            //base
            hull(){
                intersection(){
                    cylinder(r=m5_rad+wall, h=base_thick, center=true);
                    cube([25, m5_rad*2+wall, base_thick], center=true);
                }
                translate([-bed_offset/2,0,0]) cube([bed_offset, m5_rad*2+wall, base_thick], center=true);
            }
            
            //riser
            translate([-bed_offset/2,0,bed_thick/2-base_thick/2+.1]) cube([bed_offset, m5_rad*2+wall, bed_thick], center=true);
            
            //hook
            hull(){
                translate([-bed_offset/2-hook/2,0,bed_thick]) cube([bed_offset+hook, m5_rad*2+wall, base_thick], center=true);
                
                translate([-bed_offset/2+hook/2,0,bed_thick+hook]) cube([bed_offset-hook, m5_rad*2+wall, base_thick], center=true);
            }
            
        }
        cylinder(r=m5_rad, h=4, center=true);
        translate([0,0,base_thick/2+10]) cylinder(r=m5_cap_rad-.25, h=20, center=true);
        echo(m5_cap_rad-.25);
    }
}

/************* Layout Section ***************
 * The plate files don't have cutouts for their intersections
 * with other plates - those are added here, in the layout.
 */



module bed_top_projected(){
    projection(){
        bed_top_connected();
    }
}

module bed_top_connected(){
    difference(){
        //the top plaqte
        bed_top();     
            
        //holes for all the stiffening support plates
        
    }
}

module bed_top_connectors(gender = MALE, solid=1, screw_offset=0, end=true){
    //both sides have the ends
    for(i=[0,1]) mirror([i,0,0]) translate([top_width/2, 0, 0]) {
        //for(j=[-1.085,-.44,.44,1.085]) translate([0,j*top_length/3,0]) rotate([0,0,90])
            for(j=[-1.085,-.44,.44,1.085]) translate([0,j*top_length/3,0]) rotate([0,0,90])
            if(gender == MALE){
                pinconnector_male(solid=solid);
            }else{
                pinconnector_female(screw_offset=screw_offset);
            }
    }
    
    //inside side has a middle one
    *translate([top_width/2,0,0]) rotate([0,0,90]) 
    if(gender == MALE){
        pinconnector_male(solid=solid);
    }else{
        pinconnector_female(screw_offset=screw_offset);
    }
    
    *if(end==false){
        //cut a third screw for the other side, too
        mirror([1,0,0]) translate([top_width/2,0,0]) rotate([0,0,90]) 
        if(gender == MALE){
            pinconnector_male(solid=solid);
        }else{
            pinconnector_female(screw_offset=screw_offset);
        }
    }
}

module smooth_rod_connectors(solid=1){
    flange_chamfer = 3;
    flange_width = 33;
    flange_screw_sep = 20;
    //the smooth rods are 10mm, and have flanged connectors on them
    echo(smooth_rod_sep);
    translate([-top_width/2-bed_screw_offset_x,0,0]) 
    for(i=[0:1]) mirror([0,i,0]) translate([0,smooth_rod_sep,0]) {
        //body
        if(solid > 0){
            union(){
                //the flange
                hull() for(j=[-1,1]) for(k=[-1,1]) {
                    translate([(flange_width/2-flange_chamfer)*j, (flange_width/2-flange_chamfer)*k, 0])
                    cylinder(r=flange_chamfer, h=mdf_wall, center=true);
                }
                
                //join to the body
                hull() for(j=[-1,1]){                    
                    translate([(flange_width/2-flange_chamfer)*1, (flange_width/2-flange_chamfer)*j, 0])
                    cylinder(r=flange_chamfer, h=mdf_wall, center=true);
                
                    translate([top_width/2,(flange_width/2-flange_chamfer)*j, 0])
                    cylinder(r=flange_chamfer, h=mdf_wall, center=true);
                }
            }
        }
        
        
        if(solid < 0){
            //screwholes
            for(j=[-1,1]) for(k=[-1,1]) {
                translate([flange_screw_sep/2*j, flange_screw_sep/2*k, 0])
                cylinder(r=m3_rad, h=mdf_wall*3, center=true);
            }
            
            //rod hole - for the whole connector, not just the rod
            cylinder(r=19/2+slop, h=mdf_wall*3, center=true);
        }
    }
}

module bed_top(){
    difference(){
        union(){
            cube([top_width, top_length, mdf_wall], center=true);
            
            leadscrew_flange(solid=1);
            
            //attach to the smooth rods for straight bed movement
            smooth_rod_connectors(solid=1);
            
            bed_top_connectors(solid=1);
        }
        
        leadscrew_flange(solid=-1);
        
        smooth_rod_connectors(solid=-1);
        
        bed_top_connectors(solid=-1);
        
        //beam holes
        for(i=[-1,1]) for(j=[-1,1]) translate([j*(top_width/2-beam/2),i*rail_sep/2,0]) cylinder(r=m5_rad, h=mdf_wall*2, center=true);
    }
}

module leadscrew_flange(solid=1){
    flange_rad = leadscrew_screw_rad+4;
    
    leadscrew_base_rad = 26/2;
    leadscrew_base_height = 5;
    
    for(i=[-1:1]) translate([-top_width/2-bed_screw_offset_x,i*bed_screw_offset_y,0]){
        if(solid>=0){
            hull(){
                cylinder(r=flange_rad, h=mdf_wall, center=true);
                translate([bed_screw_offset_x,0,0]) cube([mdf_wall*4,flange_rad*2.25,mdf_wall], center=true);
                //scale([1,1.2,1]) cylinder(r=flange_rad, h=mdf_wall, center=true, $fn=50);
            }
        }
        if(solid==-1){
            cylinder(r=leadscrew_shaft_rad, h=mdf_wall*2, center=true);
            for(i=[0:120:359]) rotate([0,0,i]) translate([leadscrew_screw_rad,0,0]) cylinder(r=m3_rad, h=mdf_wall*2, center=true);
        }
        
        *if(solid==0){
            #translate([0,0,-mdf_wall/2-leadscrew_base_height/2]) cube([100, leadscrew_base_rad*2, leadscrew_base_height+.1], center=true);
        }
    }
}

module bed_brace_projected(){
    projection(){
        bed_brace_connected();
    }
}

module bed_brace_connected(){
    difference(){
        //the top plate
        bed_brace();     
            
        //holes for all the stiffening support plates
        
    }
}

module bed_brace(){
    difference(){
        union(){
            cube([top_width, top_length, mdf_wall], center=true);
            
            //leadscrew_flange(solid=1);
            
            bed_top_connectors(solid=1, end=false);
        }
        
        bed_top_connectors(solid=-1, end=false);
        
        //beam holes
        for(i=[-1,1]) for(j=[-1,1]) translate([j*(top_width/2-beam/2),i*rail_sep/2,0]) cylinder(r=m5_rad, h=mdf_wall*2, center=true);
            
        //central gap
        cube([top_width+mdf_wall*3, center_gap, mdf_wall*2], center=true);
    }
}

module bed_inside_projected(){
    projection(){
        rotate([0,-90,0]) bed_inside_connected();
    }
}

module bed_inside_connected(){
    difference(){
        //the inside plate
        translate([top_width/2+mdf_wall/2,0,-beam/2]) rotate([0,90,0]) bed_inside();
        
        //remove holes from the top plate
        bed_top_connectors(gender=FEMALE, screw_offset = bed_screw_offset);
    }        
}

module bed_inside(){
    difference(){
        union(){
            cube([side_width, side_length, mdf_wall], center=true);
        }
        
        //locks for the side rails
        for(i=[0,1]) mirror([0,i,0]) translate([mdf_wall/2,side_length/2, 0]){
            cube([m5_rad*2+laser_slop*2, beam*2, mdf_wall*2], center=true);
            hull(){
                translate([0,-mdf_wall,0]) cube([m5_cap_rad*2+slop, .1, mdf_wall*2], center=true);
                translate([0,-beam-mdf_wall,0]) cube([m5_rad*2+slop, .1, mdf_wall*2], center=true);
            }
        }
        
        //central gap for the wires
        #translate([-side_width/2,0,0]) cube([mdf_wall*2, center_gap, mdf_wall*2], center=true);
    }
}

module bed_outside_projected(){
    projection(){
        rotate([0,-90,0]) bed_outside_connected();
    }
}

module bed_outside_connected(){
    difference(){
        //the inside plate
        translate([-top_width/2-mdf_wall/2,0,-side_width/2+mdf_wall*.75]) rotate([0,90,0]) bed_outside();
        
        //remove holes from the top plate
        bed_top_connectors(gender=FEMALE);
        
        //remove the smooth rod flanges
        smooth_rod_connectors(solid=1);
        
        //remove the flanges
        leadscrew_flange(solid=0);
    }        
}

module bed_outside(){
    difference(){
        union(){
            cube([side_width+mdf_wall/2, top_length, mdf_wall], center=true);
        }
        
        //beam holes
        for(i=[-1,1]) translate([mdf_wall*3/4,i*rail_sep/2,0]) cylinder(r=m5_rad, h=mdf_wall*2, center=true);
    }
}