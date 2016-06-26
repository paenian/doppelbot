/*
 * this is the structural endcap for the doppelbot.
 * The design entails two endcaps, separating and stiffening the frame.
 * 
 * Each endcap is a torsion box - two main plates with internal horizontal separators
 * plus four surrounding plates, intersecting all the others.
 * 
 */

include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../connectors.scad>

//cross plate vars
plate_sep = 25;
num_plates = 2;

ps_width = 115;
ps_height = 50;
relay_width = 45;
relay_height = 35;

//bottom plate width: 

//side vars
side_plate_width=70;    //minimum 80mm for two clips in the corners.
num_clips = 1;          //for one clip, minimum is 60.


wall_inset = (plate_sep+mdf_wall)/2+15;
wall_inset = side_plate_width/2-mdf_wall*1.5;

z_offset = 14+2.5+2.5+2.5+2.5; //applies to both the lead screw and the smooth rods - they're inline.
z_bump = 6; //bump for the motor mount, to give it more strength



//motor dimensions
bump_rad = 25/2;    //clearance for the central bump thingy
motor_w = 42.5;
screw_w = 31;
screw_rad = m3_rad;

//render everything
part=10;

//parts for laser cutting
if(part == 0)
    end_plate_projected();
if(part == 1)
    support_plate_projected(motor = false);
if(part == 11)
    support_plate_projected(motor = true);
if(part == 12){
    support_plate_cover_projected();
    //#translate([0,0,10]) bottom_wall_connected(support=true);
}
if(part == 2)
    cross_plate_projected();
if(part == 3)
    vertical_wall_projected();
if(part == 4)
    top_wall_projected(motor=true);
if(part == 5)
    top_wall_projected(motor=false);
if(part == 6)
    bottom_wall_projected();
if(part == 61)
    bottom_wall_projected(motor=true);
if(part == 7)
    corner_plate_projected();
if(part == 71)
    corner_plate_projected(cover=true);

//view the assembly
if(part == 10){
    assembled_endcap(motor=true);
    
    translate([0,0,200]) 
    mirror([0,0,1]) assembled_endcap(motor=false);
}

//assemble
module assembled_endcap(motor=false){
    end_plate_connected();
    support_plate_connected(motor=motor);
    if(motor==true){
        support_plate_cover_connected();
    }
    if(corner_endplate==true){
        corner_plates(cover=true);
    }else{
        *cross_plates();
    }
    vertical_walls_connected();
    top_wall_connected(motor=motor);
    
    bottom_wall_connected(support=motor);
}

/************* Layout Section ***************
 * The plate files don't have cutouts for their intersections
 * with other plates - those are added here, in the layout.
 */
module end_plate_projected(){
    echo("Cut One per End");
    projection(){
        end_plate_connected();
    }
}

module end_plate_connected(){
    //we ignore assembled, cuz it's always flat :-)
    difference(){
        //the very end.  Stuff mounts to this guy.
        end_plate(corners=true, endcap=true);     
            
        //holes for all the stiffening cross plates
        if(corner_endplate==true){
            echo("corner plates");
            corner_plates_connectors(gender=FEMALE);
        }else{
            cross_plates_connectors(gender=FEMALE);
        }
        
        //top wall - belt holes
        translate([0,frame_z/2+mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0])
        top_plate_connectors(gender=FEMALE);
    }
}

module support_plate_projected(motor=false){
    echo("Cut One per End");
    projection(){
        support_plate_connected(motor=motor);
    }
}

module support_plate_cover_projected(){
    echo("Cut One per End");
    projection(cut=true){
        translate([0,0,mdf_wall]) support_plate_cover_connected();
    }
}

module support_plate_connected(motor=false){
    difference(){
        //the support plate
        translate([0,0,plate_sep+mdf_wall]) support_plate(motor=motor);
            
        //holes for all the stiffening cross plates
        if(corner_endplate==true){
            corner_plates_connectors(gender=FEMALE);
        }else{
            cross_plates_connectors(gender=FEMALE);
        }
            
        
        //top wall - belt holes
        translate([0,frame_z/2+mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0])
        top_plate_connectors(gender=FEMALE);
    }        
}

module support_plate_cover_connected(){
    difference(){
        //the support plate
        translate([0,-frame_z/2-mdf_wall,-mdf_wall]) support_plate_cover();
        translate([0,-frame_z/2-mdf_wall,-mdf_wall]) support_plate_cover_connectors(gender=MALE);
            
        //holes for all the stiffening cross plates
        if(corner_endplate==true){
            corner_plates_connectors(gender=FEMALE, support=true);
        }else{
            cross_plates_connectors(gender=FEMALE, support=true);
        }
            
        
        //bottom wall
        translate([0,-frame_z/2-mdf_wall/2-.1,wall_inset-.1]) rotate  ([0,0,90]) rotate([0,90,0]) bottom_plate_connectors(gender=FEMALE, support=true);
        
        translate([0,-.1,-.1])
        bottom_wall_connected(gender=FEMALE, support=true);
        
        //cut out the power supply
        translate([0,0,40]) ps_holes(solid=1);
        
        //cut out the relays
        translate([0,0,20]) relay_holes(solid=1);
    }        
}

module cross_plate_projected(cover = false){
    echo("Cut Two per End");
    projection() cross_plate(cover = cover);
}


module corner_plate_projected(cover=false){
    echo("Cut Four per End");
    projection() corner_plate(cover = cover);
}

module vertical_wall_projected(){
    echo("Cut Two per End");
    projection(){ 
       rotate([0,-90,0])
       difference(){
            union(){
                //front and back are identical, so we just pick one
                translate([-frame_y/2-mdf_wall/2,0,wall_inset]) rotate([0,90,0]) vertical_plate();
            }
        
            //this subtracts the end connectors
            end_plate_connectors(gender=FEMALE);
            translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
            //the walls also get pinned at the bottom
            translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate  ([0,0,90]) rotate([0,90,0]) bottom_plate_connectors(gender=FEMALE);
        } 
    }
}

module vertical_walls_connected(){
    //the two vertical walls
    difference(){
        union(){
            //front and back are identical
            for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate();
        }
        
        //this subtracts the end connectors
        end_plate_connectors(gender=FEMALE, endcap=true);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
        //the walls also get pinned at the bottom
        translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate  ([0,0,90]) rotate([0,90,0]) bottom_plate_connectors(gender=FEMALE);
    }
}

module top_wall_projected(motor=true){
    projection() rotate([90,0,0]) top_wall_connected(motor=motor);
}

//the top wall
module top_wall_connected(motor=true){
    difference(){
        //top - motors on one end, idlers on the other
        translate([0,frame_z/2+mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0]) 
        top_plate(motor=motor);
    
        //this subtacts the connectors from whatever part comes next.
        end_plate_connectors(gender=FEMALE, endcap=true);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
        //also gets hit by the verts
        for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate_connectors(gender=FEMALE);
    }
}

module bottom_wall_projected(support=false){
    projection() rotate([90,0,0]) bottom_wall_connected(support=support);
}

//the bottom wall
module bottom_wall_connected(support=false){
    difference(){
        //bottom - z motor in the middle
        translate([0,-frame_z/2-mdf_wall/2,wall_inset]) rotate([0,0,90]) rotate([0,90,0]) 
        bottom_plate(support=support);
    
        //this subtacts the connectors from whatever part comes next.
        end_plate_connectors(gender=FEMALE, endcap=true);
        translate([0,0,plate_sep+mdf_wall]) end_plate_connectors(gender=FEMALE);
    
    //also gets hit by the verts
        *for(i=[-frame_y/2-mdf_wall/2,frame_y/2+mdf_wall/2]) translate([i,0,wall_inset]) rotate([0,90,0]) vertical_plate_connectors(gender=FEMALE);
    }
}


//holes for an offset motor - the Z is on a stilt to accommodate a centering bearing.
module motor_mount_offset(){
    cylinder(r=z_bearing, h=mdf_wall*3, center=true);
    %translate([0,0,-20-mdf_wall]) cylinder(r=pulley_flange_rad, h=20);
    for(i=[0:90:359]) rotate([0,0,i]) translate([screw_w/2, screw_w/2, 0]){
        hull(){
            translate([-1,-1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
            translate([1,1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
        }
    }
}


//holes for the motor
module motor_mount(){
    cylinder(r=bump_rad, h=wall*3, center=true);
    %translate([0,0,-20]) cylinder(r=pulley_flange_rad, h=20);
    for(i=[0:90:359]) rotate([0,0,i]) translate([screw_w/2, screw_w/2, 0]){
        hull(){
            translate([-1,-1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
            translate([1,1,0]) cylinder(r=screw_rad, h=wall*3, center=true);
        }
    }
}


//holes for the idler
module idler_mount(){
    //correct for the difference in radii of the idler and pulley radii
    translate([0,pulley_rad-idler_rad,0]) {
        //outer pulley
        translate([idler_rad*3,0,0]){ //should be times 2, but 3 spreads the belts out more - at the cost of longer 
            cylinder(r=m5_rad, h=wall*3, center=true);
            %translate([0,0,-mdf_wall*3]) cylinder(r=idler_rad, h=idler_thick);
            %translate([0,0,-mdf_wall*3]) cylinder(r=idler_flange_rad, h=1);
        }
    
        //inner pulley
        translate([idler_rad*.5,-pulley_rad*2,0]){
            cylinder(r=m5_rad, h=wall*3, center=true);
            %translate([0,0,-mdf_wall*3]) cylinder(r=idler_rad, h=idler_thick);
            %translate([0,0,-mdf_wall*3]) cylinder(r=idler_flange_rad, h=1);
        }
    }
}

module smooth_rod_holes(solid=1){
    for(i=[0:1]) mirror([0,i,0]) translate([-plate_sep/2-z_offset,frame_y/5,0]) {
        if(solid==1){
            hull() for(j=[-1,1]) translate([0,j*(z_bearing+wall/2),0])
                rotate([0,0,22.5]) cylinder(r=z_bump/cos(180/8), h=mdf_wall, $fn=8, center=true);
        }
        if(solid==-1){
            cylinder(r=smooth_rod_rad, h=wall*3, center=true);
            %translate([0,0,-40]) cylinder(r=20/2, h=29, center=true);
        
            //zip tie holes, to hold the rods in
            for(i=[-1,1]) translate([0,i*(smooth_rod_rad+wall+1),0]) cube([5,3,mdf_wall*3], center=true);
        }
    }
}

module beam_holes(double = false){
    
    for(i=[0:1]) for(j=[wall_inset-mdf_wall*1.5,mdf_wall*2-side_plate_width/2])
        mirror([0,i,0]) translate([j,frame_y/2-beam/2,0]){
            cylinder(r=m5_rad, h=mdf_wall*3, center=true);
            
            //this is for the flat of the beam
            if(double==true){
                translate([0,-beam,0]) cylinder(r=m5_rad, h=mdf_wall*3, center=true);
            }
        }
}

//there are some now
module top_plate_connectors(gender=MALE, solid=1){
    //draw in a few belt lines
	%rotate([90,0,0]) rotate([0,90,0]) for(j=[-pulley_rad,pulley_rad]) for(i=[0:1]) mirror([i,0,0]) translate([motor_y+j,-beam/2-mdf_wall/2,-50]){
		cube([2,6,200], center=true);
    }
    
    if(gender==FEMALE){
        //lets make those belt lines into holes
        rotate([90,0,0]) rotate([0,90,0]) for(j=[-pulley_rad,pulley_rad]) for(i=[0:1]) mirror([i,0,0]) translate([motor_y+j,-beam/2-mdf_wall/2,0]){
            cube([belt_width+wall/2,belt_thick+wall/2,50], center=true);
        }
    }
}

module support_plate_cover_connectors(gender=MALE, solid=1){
    height = 120;
    bot_width = frame_y/4;
    top_width = bot_width+height*2;
    
    //bottom holes
    for(i=[0]) translate([i*30,0,0]){
        translate([0, mdf_wall/2, 0]) cylinder(r=m5_rad, h=mdf_wall*3, center=true);
    }
}

module power_switch(){
    chamfer = 3;
    union(){
        difference(){
            cube([25.5, 43, mdf_wall*3],center=true);
            
            //corners
            for(i=[-1,1]) translate([i*25.5/2, -43/2,0]) 
                cylinder(r=chamfer, h=mdf_wall*4, center=true, $fn=4);
        }
        
        //mounting holes
        for(i=[-1,1]) translate([i*40/2, 0,0]) 
                cylinder(r=m5_rad, h=mdf_wall*4, center=true);
    }
}

module support_plate_cover(){
    height = 110;
    bot_width = frame_y/4;
    top_width = bot_width+height*2;
    
    difference(){
        union(){
            hull(){
                translate([0, .5, 0]) cube([bot_width, 1, mdf_wall], center=true);
                translate([0, height-.5, 0]) cube([top_width, 1, mdf_wall], center=true);
            }
        }
        
        //power switch hole
        translate([0,23,0]) rotate([0,0,90]) power_switch();
        
        //top mounting holes
        for(i=[0,1]) mirror([i,0,0]) translate([top_width/2-mdf_wall*3,height-10,0]) cylinder(r=m5_rad, h=mdf_wall*10, center=true);
    }
}

//the uppermost plate.  Includes mounts for the motors on one side, and idlers on the other
module top_plate(motor=true){
    motor_offset = plate_sep/2+mdf_wall*2+pulley_flange_rad+1;
    difference(){
        union(){
            cube([side_plate_width, frame_y+mdf_wall*3, mdf_wall], center=true);
            
            //xy motor/idler sticky-outy
            for(i=[0:1]) mirror([0,i,0]) hull() translate([motor_offset,motor_y,0])
            if(motor==true){    //motor mounts
                rotate([0,0,-45]) motor_mount(screw_rad = screw_rad+mdf_wall/2, wall=wall/3);
                translate([-mdf_wall,0,0]) rotate([0,0,-45]) motor_mount(screw_rad = screw_rad+mdf_wall, wall=wall/3);
            }else{              //idler mounts
                idler_mount(m5_rad = m5_rad+mdf_wall/2, wall=wall/3);
                translate([-mdf_wall*3,0,0]) idler_mount(m5_rad = m5_rad+mdf_wall*2, wall=wall/3);
            }
            
            //the z motor mounts
            z_motor_mounts(solid=1);
            
            smooth_rod_holes(solid=1);
            
            top_plate_connectors(gender=MALE, solid=1);
        }
        top_plate_connectors(gender=MALE, solid=-1);
        
        //mount the motors and idlers
        for(i=[0:1]) mirror([0,i,0]) translate([motor_offset,motor_y,0])
        if(motor==true){    //motor mounts
            rotate([0,0,-45]) motor_mount();
        }else{              //idler mounts
            idler_mount();
        }
        
        //smooth rod mounts
        smooth_rod_holes(solid=-1);
        
        //beam holes
        beam_holes();
        
        //hole for the Z rod
        //translate([-plate_sep/2-z_offset,0,0]) cylinder(r=4+slop, h=mdf_wall*3, center=true);
        
        //this is for an m8 flanged bearing
        z_motor_mounts(solid=-1);
    }
}


//there aren't any...
module bottom_plate_connectors(gender=MALE, solid=1, support=false){
    if(num_clips == 2){
        for(j=[0,1]) for(i=[-1,1]){
            mirror([0,j,0]) translate([mdf_tab*i,frame_y/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
    }
    if(num_clips == 1){
        for(j=[0,1])
            mirror([0,j,0]) translate([0,frame_y/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
        
    if(support==true){
        //cut out a center section
        for(i=[0]) translate([0,i*30,0]){
            if(solid == -1){
                difference(){
                    translate([side_plate_width/2,0,0]) cube([mdf_wall*2, mdf_wall*10, mdf_wall*3], center=true);
                    translate([side_plate_width/2-mdf_wall,0,0]) rotate([0,0,90]) pinconnector_male(solid=1);
                }
            }
            translate([side_plate_width/2-mdf_wall,0,0]) rotate([0,0,90]) pinconnector_male(solid=solid);
        }
    }
}

module z_motor_mounts(solid=1){
    for(i=[-1:1]) {
        if(solid==1){
            hull() for(j=[-1,1]) translate([-plate_sep/2-z_offset,bed_screw_offset_y*i+j*motor_w*sqrt(2)/2,0])
                rotate([0,0,22.5]) cylinder(r=z_bump/cos(180/8), h=mdf_wall, $fn=8, center=true);
                //cube([z_bump*2, motor_w*sqrt(2), mdf_wall], center=true);
        }
        if(solid==-1){
            //holes for the motors
            translate([-plate_sep/2-z_offset,bed_screw_offset_y*i,0])
                rotate([0,0,-45]) motor_mount_offset();
        }
    }
}

module z_idler_mounts(solid=1){
    for(i=[-1:1]) {
        if(solid==1){
            hull() for(j=[-1,1]) translate([-plate_sep/2-z_offset,bed_screw_offset_y*i+j*(z_bearing+wall/2),0])
                rotate([0,0,22.5]) cylinder(r=z_bump/cos(180/8), h=mdf_wall, $fn=8, center=true);
                //cube([z_bump*2, motor_w*sqrt(2), mdf_wall], center=true);
        }
        if(solid==-1){
            //holes for the bearings
            translate([-plate_sep/2-z_offset,bed_screw_offset_y*i,0])
                cylinder(r=z_bearing, h=mdf_wall*3, center=true);
            //screws to hold the bearings in
            for(j=[0:90:359]) translate([-plate_sep/2-z_offset,bed_screw_offset_y*i,0]) rotate([0,0,j]) translate([0,z_bearing_flange+m3_rad,0])
                cylinder(r=m3_rad, h=wall*3, center=true);
        }
    }
}

//the bottom plate.  Includes mounts for the Z motor in the middle, and the smooth rods on the sides.
module bottom_plate(support=false){
    difference(){
        union(){
            cube([side_plate_width, frame_y, mdf_wall], center=true);
            bottom_plate_connectors(gender=MALE, solid=1, support=support);
            
            z_idler_mounts(solid=1);
            
            //smooth rod mounts
            smooth_rod_holes(solid=1);
        }
        bottom_plate_connectors(gender=MALE, solid=-1, support=support);
        

        //mount the motors
        z_idler_mounts(solid=-1);
        
        //smooth rod mounts
        smooth_rod_holes(solid=-1);
        
        //beam holes
        beam_holes();
    }
}

module vertical_plate_connectors(gender=MALE, solid=1){
    if(num_clips == 2){
        for(i=[-1,1]){
            translate([mdf_tab*i,frame_z/2,0]) if(gender == MALE){
                mirror([0,1,0]) pinconnector_male(solid=solid);
            }else{
                mirror([0,1,0]) pinconnector_female();
            }
        }
    }
    if(num_clips == 1){
        translate([0,frame_z/2,0]) if(gender == MALE){
            mirror([0,1,0]) pinconnector_male(solid=solid);
        }else{
            mirror([0,1,0]) pinconnector_female();
        }
    }
}

//the front and back vertical plates.  Includes feet!
module vertical_plate(){
    difference(){
        union(){
            translate([0,-foot_height/2,0]) cube([side_plate_width, frame_y+foot_height, mdf_wall], center=true);
            vertical_plate_connectors(gender=MALE, solid=1);
        }
        vertical_plate_connectors(gender=MALE, solid=-1);
        
        beam_holes(double=true);
    }
}

module end_plate_connectors(gender = MALE, solid=1, endcap=false){
    for(i=[0:90:359]) rotate([0,0,i]) {
        for(i=[-1,1]){
            translate([(frame_y/2-beam*5)*i,-frame_y/2,0]) if(gender == MALE){
                pinconnector_male(solid=solid);
            }else{
                pinconnector_female();
            }
        }
        
        //middle connector, on the support plate only
        if(endcap==false){
            translate([0,-frame_y/2,0]) if(gender == MALE){
                pinconnector_male(solid=solid);
            }else{
                pinconnector_female();
            }
        }
    }
    
    //tabs in the corners, to better align the beams
    if(endcap==true){
        translate([frame_y/2,frame_z/2-beam,0]) {
            rotate([0,0,90]) tab(width=beam/2, gender=gender);
        }
    }
    
}

module end_plate(corners=false, endcap=false){
    inner_sub = 75;
    difference(){
        union(){
            //the plate
            cube([frame_y, frame_z, mdf_wall], center=true);
   
            //connectors around the edge
            end_plate_connectors(solid=1, endcap=endcap);
        }
        
        if(corners == true){
            rotate([0,0,45]) cube([corner_y,corner_z,mdf_wall+1], center=true);
        }
        
        //connectors around the edge
        end_plate_connectors(solid=-1);
        
        //mounting holes for the cross plates
        //cross_plates_connectors(gender=FEMALE);
        
        //mounting holes for electronics etc.
        holes();
        
        //beam holes
        beam_cutout(screws=true, beams=false);
    }
}

module beam_cutout(screws=true, beams=false){
    if(beams==true){
        union(){
            for(i=[0:1]) mirror([i,0,0]) translate([frame_y/2,0,0])
                for(j=[0:1]) mirror([0,j,0]) translate([0,frame_z/2,0])
                    translate([-beam/2+.5,-beam+.5,0]) cube([beam+1, beam*2+1, mdf_wall*4], center=true);
        }
    }
    if(screws==true){
        for(i=[0:1]) mirror([i,0,0]) translate([frame_y/2,0,0])
                for(j=[0:1]) mirror([0,j,0]) translate([0,frame_z/2,0])
                    difference(){
                        union(){
                            for(k=[0:1]){
                                translate([-beam/2,-beam/2-k*beam,0]) beamHoles(slop=0);
                                }
                            }
                            translate([-beam/2,-beam,0]) rotate([0,0,180/8]) cylinder(r=beam/2-2.1, h=30, center=true, $fn=8);
                        }
    }
}

module ps_holes(solid=-1){
    x_sep = 50;
    y_sep = 150;
    indent = 20;
    
    width = 115;
    length = 215;
    height = 50;
    
    translate([-115/2,-50,0]) rotate([0,0,180]) {
        if(solid == -1){
            %translate([0,-indent/2,-height/2-mdf_wall]) cube([width,length-indent,height], center=true);
            %translate([0,0,-15-mdf_wall]) cube([width,length,height/2], center=true);
        }else{
            translate([0,-indent/2,-height/2-mdf_wall]) cube([width,length-indent,height], center=true);
            translate([0,0,-15-mdf_wall]) cube([width,length,height/2], center=true);
            
            //wings
            for(i=[-1,1]) translate([width/2*i,0,-height/2-mdf_wall]) cube([5,length+1,height], center=true);
        }
    
        for(i=[-1,1]) for(j=[-1,1]) translate([i*x_sep/2, j*y_sep/2,-mdf_wall]) 
            screw_hole_m4(height = wall*3);
    }
}

module relay_holes(solid=-1){
    y_sep = 48;
    for(k=[35, 90]) translate([k,-115-2.5,0]) {
        if(solid==-1){
            %translate([0,0,-35/2-mdf_wall]) cube([45,60,35], center=true);
        }else{
            translate([0,0,-35/2-mdf_wall]) cube([45,60,35], center=true);
        }
    
        for(i=[-1,1]) translate([0,i*y_sep/2,-mdf_wall]) 
            screw_hole_m4(height = wall*3);
    }
}

module duet_holes(){
    hole_inset = 4;
    width = 100;
    length = 123;
    
    %translate([0,0,10-mdf_wall]) cube([width,length,20], center=true);
    for(i=[-1,1]) for(j=[-1,1]) translate([i*(width/2-hole_inset), j*(length/2-hole_inset),-mdf_wall]) 
        screw_hole_m3(height = wall*3);
}

module duet_x4_holes(){
    hole_inset_left = 4;
    hole_inset_right_x = 12.131;
    hole_inset_right_y = 3.048;
    width = 77.409;
    length = 123;
    
    %translate([0,0,10-mdf_wall]) cube([width,length,20], center=true);
    
    translate([width/2-hole_inset_left, length/2-hole_inset_left, -mdf_wall]) screw_hole_m3(height = wall*3);
    translate([width/2-hole_inset_left, -1 * (length/2-hole_inset_left), -mdf_wall]) screw_hole_m3(height = wall*3);
    
    translate([-width/2+hole_inset_right_x, length/2-hole_inset_right_y, -mdf_wall]) screw_hole_m3(height = wall*3);
    translate([-width/2+hole_inset_right_x, -1 * (length/2-hole_inset_right_y), -mdf_wall]) screw_hole_m3(height = wall*3);
}

//make holes for all of the electronics
module electronics_mounts(){
    ps_holes();
    relay_holes();
    
    translate([45,135]) duet_holes();
    translate([-55,135,0]) duet_x4_holes();
}

module support_plate(slots=false, motor=false){
    difference(){
        end_plate();
        beam_cutout(screws=false, beams=true);
        
        if(motor == true){
            electronics_mounts();
        }
        
        //mounting holes for the electronics, power supply, etc.
    }
}

module corner_plates_connectors(){
    difference(){
        union(){
            for(i=[45:90:359]){
                rotate([0,0,i]) translate([0,corner_y/2+mdf_wall,plate_sep/2+mdf_wall/2]) rotate([90,0,0]){
                    cross_plate_connectors(frame_z=corner_length, num_spans=5, gender=FEMALE);
                }
            }
        }
    }
}

//in place
module corner_plates(cover = false){
    difference(){
        union(){
            for(i=[45:90:359]){
                rotate([0,0,i]) translate([0,corner_y/2+mdf_wall,plate_sep/2+mdf_wall/2]) rotate([90,0,0]){
                    corner_plate(cover = cover);
                    cross_plate_connectors(frame_z=corner_length, num_spans=5);
                }
            }
        }
    }
}

module corner_plate(cover = false){
    difference(){
        union(){
            cube([corner_length,plate_sep,mdf_wall], center=true);
            cross_plate_connectors(frame_z=corner_length, num_spans=5, cover = cover);
        }
        
        if(cover == true){
            translate([0,-plate_sep+mdf_wall+1,0]) pinconnector_male(solid=-1);
        }
    }
}

module cross_plate_connectors(gender=MALE, num_spans = 10, cover=false){
    //start = -frame_z/2-wall;
    //end = frame_z/2-wall;
    span = (frame_z-wall*2)/num_spans;
    difference(){
        union(){
            for(i=[0:num_spans-1]){
                translate([i*span-frame_z/2+span/2+wall,-plate_sep/2+plate_sep*(i%2),0]){
                    if(gender==MALE){
                        difference(){
                            cube([span,mdf_wall*2,mdf_wall], center=true);
                        
                            //cut off the corners
                            for(j=[0,1]) mirror([j,0,0]) translate([span/2,-mdf_wall+mdf_wall*2*(i%2),0]) cylinder(r=mdf_wall/4, h=mdf_wall*2, center=true, $fn=4);
                        }
                    }else{
                        cube([span+laser_slop,mdf_wall*2+1,mdf_wall+laser_slop], center=true);
                    }
                }
            }
        }
    }
}

            /*translate([(frame_y/2-beam*5)*i,-frame_y/2,0]) if(gender == MALE){
                pinconnector_male(solid=solid);
            }else{
                pinconnector_female();*/

module cross_plates_connectors(gender=MALE, num_spans = 10, cover = false){
    plate_travel = frame_z/(num_plates+1);
    
    translate([0,-frame_z/2,plate_sep/2+mdf_wall/2]) 
    for(i=[1:num_plates]){
        translate([0,i*plate_travel,0]) rotate([90,0,0]) cross_plate_connectors(gender=gender, num_spans=num_spans);
    }
}

module cross_plate(slots=false, cover = false){
    //rotate([90,0,0])
    difference(){
        union(){
            cube([frame_y,plate_sep,mdf_wall], center=true);
            cross_plate_connectors(cover = cover);
        }
        
        if(cover == true){
            translate([0,-plate_sep+mdf_wall+1,0]) pinconnector_male(solid=-1);
        }
    }
}

module cross_plates(){
    plate_travel = frame_z/(num_plates+1);
    
    translate([0,-frame_z/2,plate_sep/2+mdf_wall/2]) 
    for(i=[1:num_plates]){
        translate([0,i*plate_travel,0]) rotate([90,0,0]) cross_plate();
    }
}

module holes(){
    cylinder(r=5, h=mdf_wall*2, center=true, $fn=7);
}
