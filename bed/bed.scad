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

top_width = 50; //width of the upper support ribs
rail_sep = bed_y + beam + m5_cap_rad/2; //center-to-center rail distance.
top_length = rail_sep + beam;

side_width = beam+mdf_wall;
side_length = rail_sep - beam;

//render everything
part=10;

//parts for laser cutting
if(part == 0)
    bedtop_projected();
if(part == 1)
    endplate_inner_projected();
if(part == 2)
    endplate_upper_projected();
if(part == 3)
    supportplate_upper_projected();
if(part == 4)
    supportplate_stiffener_projected();
if(part == 5)   //note that this outputs an STL, not a DXF.
    leadscrew_connector();
if(part == 6)   //note that this outputs an STL, not a DXF.
    leadscrew_connector(side=true);

//view the assembly
if(part == 10){
    //render an endcap for scale/matching
    %translate([-80,0,frame_z/2]) rotate([0,0,90]) rotate([90,0,0]) assembled_endcap(motor=true);
    
    //render some rails in
    %for(i=[-1,1]) translate([0,i*rail_sep/2,-beam/2-mdf_wall/2]) rotate([0,90,0]) beam(800, true, .25);
    
    //endplate
    bed_top_connected();
    
    bed_side_connected();
    
    //leadscrew connector
    //leadscrew_connector();
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

module bed_top(){
    difference(){
        union(){
            cube([top_width, top_length, mdf_wall], center=true);
            
            leadscrew_flange(solid=1);
        }
        
        leadscrew_flange(solid=-1);
        
        //beam holes
        for(i=[-1,1]) for(j=[-1,1]) translate([j*(top_width/2-beam/2),i*rail_sep/2,0]) cylinder(r=m5_rad, h=mdf_wall*2, center=true);
    }
}

module leadscrew_flange(solid=1){
    for(i=[-1:1]) translate([-top_width/2-bed_screw_offset_x,i*bed_screw_offset_y,0]){
        if(solid==1){
            hull(){
                cylinder(r=leadscrew_screw_rad+m3_cap_rad, h=mdf_wall, center=true);
                translate([bed_screw_offset_x,0,0]) scale([1,(top_width-bed_screw_offset_x)/(10*2),1]) cylinder(r=10, h=mdf_wall, center=true, $fn=50);
            }
        }
        if(solid==-1){
            cylinder(r=leadscrew_rad, h=mdf_wall*2, center=true);
            for(i=[0:120:359]) rotate([0,0,i]) translate([leadscrew_screw_rad,0,0]) cylinder(r=m3_rad, h=mdf_wall*2, center=true);
        }
    }
}

module bed_side_projected(){
    projection(){
        bed_side_connected();
    }
}

module bed_side_connected(){
    difference(){
        //the support plate
        translate([top_width/2+mdf_wall/2,0,-beam/2]) rotate([0,90,0]) bed_side();
    }        
}

module bed_side(){
    difference(){
        union(){
            cube([side_width, side_length, mdf_wall], center=true);
            
        }
        
    }
}