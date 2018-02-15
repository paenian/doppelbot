//This is an extruder that's firmly mounted to the gantry.
include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../endcap/endcap.scad>
use <../gantry/gantry.scad>

wall = 6;

chain_width = 1.1*in;
chain_length = 1.77*in;
chain_hole_sep = .31*in;
chain_hole_rad = .13*in/2+slop;

cablechain_mount();

module cablechain_mount(chain_lift = 20, cable_angle = 5){
    height = chain_lift+wall+chain_hole_rad;
    difference(){
        union(){
            rotate([cable_angle,0,0]) translate([0,0,-5]) cylinder(r=smooth_rod_rad+wall, h=height+5);
            translate([smooth_rod_rad+wall,10,wall+chain_hole_rad]) rotate([90,0,0]) hull() cablechain_bracket(solid = 1);
        }
        
        rotate([cable_angle,0,0]) translate([0,0,5-.1]) cylinder(r=smooth_rod_rad+slop, h=height+5);
        
        translate([smooth_rod_rad+wall,10,wall+chain_hole_rad]) rotate([90,0,0]) cablechain_bracket(solid = -1);
        
        translate([0,0,-100]) cube([200,200,200], center=true); 
    }
}


module cablechain_bracket(){
    
    //%cube([5,chain_width,chain_length], center=true);
    
    for(i=[0:1]) mirror([0,0,i]) hull()
        translate([0,0,chain_hole_sep/2]) rotate([0,90,0])
            if(solid == 1){
                cylinder(r=chain_hole_rad+wall, h=wall, center=true);
            }else{
                cylinder(r=chain_hole_rad, h=wall+1, center=true);
                #translate([0,0,wall-m3_nut_height]) cylinder(r1=m3_nut_rad, r2=m3_nut_rad+1, h=m3_nut_height*3, $fn=6);
            }
}

module groovemount_screw(solid=1,e3d=1, height = 19){
    dia = 16;
    rad = dia/2+slop;
    mink = 1;
    inset = 3;
    groove = 9+2;
    thick = 5;
    length = 10;
    
    bowden_tube_rad = 2.5;
    
    base_rad=screw_mount_rad+3;
    
    screw_inset = 4.2;
    screw_offset = rad+1;
    screw_height = rad+m3_nut_height+wall;

    filament_height = 14;

    if(solid){
        //body
        //hull(){
            *translate([0,filament_height,0]) rotate([90,0,0])  cylinder(r=4, h=.1, center=true);
            
            
            
            //screwmount mount
            translate([0,0,-inset+4.25+6/2-slop]) hull(){
                for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) rotate([90,0,0]){
                    cylinder(r=screw_mount_rad, h=height, center=true);
                    translate([0,base_rad-screw_mount_rad,-height/2]) cylinder(r=base_rad, h=1, center=true);
                }
            }
        //}
    }else{
        
        //screwmount
        translate([0,0,-inset+4.25+6/2-slop]){
            for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) rotate([90,0,0]) {
                translate([0,0,-wall+m5_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m5_rad, h=25);
                translate([0,0,-28+-wall+m5_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m5_rad, h=25);
                
                //nuts
                translate([0,0,-wall]) rotate([0,0,45]) cylinder(r2=m5_sq_nut_rad, r1=m5_sq_nut_rad+1, h=m5_nut_height+1, center=true, $fn=4);
                hull(){
                    translate([0,m5_sq_nut_rad/2,-wall]) rotate([0,0,45]) cylinder(r2=m5_sq_nut_rad, r1=m5_sq_nut_rad+1, h=m5_nut_height+1, center=true, $fn=4);
                    translate([0,m5_sq_nut_rad*2,-wall]) rotate([0,0,45]) cylinder(r2=m5_sq_nut_rad+.5, r1=m5_sq_nut_rad+1.5, h=m5_nut_height+1, center=true, $fn=4);
                }
                
                %translate([0,0,+2]) cylinder(r=m3_rad, h=25.4*3/4);
            }
        }
        
        //hotend holes
       render(){
           //PTFE tube hole
           translate([0,0,-inset-wall*2]) {
               cap_cylinder(r=bowden_tube_rad, h=wall*3);
               translate([0,-3+.75,wall*1.5])
               hull(){
                cube([1,wall*2,wall*3], center=true);
                translate([0,-bowden_tube_rad,0]) cube([bowden_tube_rad*2,wall*2,wall*3], center=true);
               }
           }
           //top part
           translate([0,0,-inset-2]) hull(){
               cap_cylinder(r=4+slop, h=wall);
               translate([0,-3,0]) cap_cylinder(r=4+slop, h=wall);
           }
           
           //the groove
           translate([0,0,-inset]) hull(){
               cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
               translate([0,-3,0]) cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
           }
           
           translate([0,0,-inset]) difference(){
               cap_cylinder(r=rad, h=4+groove+.2+10, $fn=90);
               translate([0,0,4.25]) cylinder(r=rad+1, h=6-slop*3);
           }
       }
        
        //backstop
        translate([0,0,-inset]) cylinder(r=rad+slop*2, h=slop*2);
        
        //clamp cutout
        translate([0,-rad-1.5,-inset+20]) cube([rad*2+wall*3+20,rad*2,100], center=true);
    }
}


//carriage to mount a single Chimaera or Cyclops extruder
module chimaera_carriage(diff_ir = true){
    diff_ir_z = diff_ir_z-5;
    
    echo(diff_ir_z);
    difference(){
        union(){
            //the carriage
            vertical_gantry_carriage(v_mount  = false, belt_holes = false, nut_traps=true);
            
            //mount the chimaera
            translate([-wall,0,-beam]) rotate([0,0,90]) chimaera_helper(solid = 1, jut = 1, height = 5, proud = 5);
            
            //mount a cable chain
            hull(){
                hull() translate([0,0,beam/2]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=1, wall=flange_thick);
                    
                translate([motor_x-10,0,motor_z+motor_width/2+chain_width/2+flange_thick+.666-10]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=1, wall=flange_thick);
            }
            
            //mount a depth sensor
            if(diff_ir == true){
                hull(){
                    translate([-wall/2,0,0]) rotate([0,0,0]) diff_ir(solid=1, wall=wall);
                    translate([-wall/2,0,diff_ir_z]) rotate([90,0,0]) diff_ir(solid=1, wall=wall);
                }
            }            
        }
        
        //chimaera holes
            translate([-wall,0,-beam]) rotate([0,0,90]) chimaera_helper(solid = -1, jut = 1, height = 5, proud = 5, onion=false);
        
        //cable chain holes
        translate([motor_x-10,0,motor_z+motor_width/2+chain_width/2+flange_thick+.666-10]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=-1, wall=flange_thick);
        
        //depth sensor holes
        if(diff_ir == true){
            translate([-wall/2,0,diff_ir_z]) rotate([90,0,0]) diff_ir(solid=0, wall=wall);
        }
        
              
        //groove for the belt
        rotate([0,0,90]) rotate([-90,0,0]) belt_attach_flat();
        
        //instead of belt clamp, just some zip ties - one on each end
        translate([0,0,beam/2]) belt_zips();
                       
        //cutout above the belt - for looks
        hull(){
            translate([0,0,beam/2+beam]) cube([12,belt_gap,beam], center=true);
            translate([0,0,beam/2*2.6+beam/2+belt_thick/2+1.4]) cube([12,51,beam], center=true);
        }
        
        //flatten the back
        translate([100,0,0]) cube([200,200,200], center=true);
    }     
}

//carriage to mount a single Bowden type extruder.
module bowden_carriage(diff_ir = true){    
    extruder_drop = 7-9;
    extruder_jut = 23+5;
    
    difference(){
        union(){
            //the carriage
            difference(){
                vertical_gantry_carriage(v_mount = false, belt_holes = false, nut_traps=true);
                
                //cutout above the belt - for looks
                hull(){
                    translate([0,0,beam/2+beam]) cube([20,belt_gap,beam], center=true);
                    translate([0,0,beam/2*2.6+beam/2+belt_thick/2+1.4]) cube([20,51,beam], center=true);
                }
            }
            
            //mount the extruder!
            rotate([0,0,-90]) translate([0,-extruder_jut,-extruder_drop]) groovemount_screw(height=extruder_jut);
            
            //extra meat for the zip tie belt
            intersection(){
                translate([0,0,beam/2]) belt_zips(solid=1);
                scale([2,1,1]) vertical_gantry_carriage(v_mount = false, belt_holes = false, nut_traps=true);
            }
            
            //mount a cable chain
            hull(){
                translate([-wall/2,20+1,beam/2]) cube([wall,wall,wall*6], center=true); 
                    
                translate([motor_x,20,motor_z+motor_width/2+chain_width/2+flange_thick+2]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=1, wall=flange_thick);
            }
            
            //strengthen the cablechain mount
            hull(){
                translate([-wall/2-wall,20+1,beam/2+wall*1.5]) cube([wall,wall-1,wall*3], center=true); 
                translate([-wall/2,20+1-wall,beam/2]) cube([wall,wall-1,wall*3], center=true); 
            }
            
            
            //mount a depth sensor
            if(diff_ir == true){
                hull() translate([-wall/2,0,diff_ir_z]) rotate([0,0,0]) rotate([90,0,0]) diff_ir(solid=1, wall=wall);
            }            
        }
        
        //mount the extruder!
        rotate([0,0,-90]) translate([0,-extruder_jut,-extruder_drop]) groovemount_screw(solid = 0,height=extruder_jut);
        
        //cable chain holes
        translate([motor_x,20,motor_z+motor_width/2+chain_width/2+flange_thick+2]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=-1, wall=flange_thick+1);
        
        //depth sensor holes
        if(diff_ir == true){
            translate([-wall/2,0,diff_ir_z]) rotate([0,0,0]) rotate([90,0,0]) diff_ir(solid=0, wall=wall);
        }
        
        //instead of belt clamp, just some zip ties - one on each end
        translate([0,0,beam/2]) belt_zips();
    }     
}

//carriage to mount a single Titan Aero extruder
module aero_carriage(diff_ir = true){
    %translate([motor_x-motor_width/2,motor_y,motor_z])
    aero_orig();
    
    difference(){
        union(){
            //the carriage
            vertical_gantry_carriage(v_mount  = false, belt_holes = false, nut_traps=true);
            
            //the motor plate
            hull() {
                translate([motor_x-motor_width/2,motor_y,motor_z]) rotate([90,0,0]) motor_holes(screw_rad = 6.5, slot = 0, height = flange_thick);
                translate([-motor_width/2+wall-.6,motor_y,motor_z]) rotate([90,0,0]) motor_holes(screw_rad = .1, slot = 0, height = flange_thick);
            }
            
            //chamfer the back to strengthen
            translate([-wall,motor_y,motor_z]) cylinder(r=5, h=motor_width+wall, center=true, $fn=4);
            
            //brace above the motor
            hull(){
                //bar above motor
                translate([-motor_width/2,motor_y,motor_z+motor_w/2+flange_thick/2+.333]) cube([motor_width,flange_thick,flange_thick], center=true);
                //bar along carriage
                translate([-wall,motor_y+motor_width/4,motor_z+motor_w/2+flange_thick/2+.333]) cube([flange_thick,motor_width/3,flange_thick], center=true);
            }
            
            //mount a cable chain
            hull(){
                //this is the motor repeated
                hull() translate([motor_x-motor_width/2,motor_y,motor_z]) scale([1,1,1]) rotate([90,0,0]) motor_holes(screw_rad = 6.5, slot = 0, height = flange_thick);
                    
                translate([motor_x-motor_width/2-7,motor_y,motor_z+motor_width/2+chain_width/2+flange_thick+.666]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=1, wall=flange_thick);
            }
            
            //mount a depth sensor
            if(diff_ir == true){
                hull(){
                    //this is the motor mount area repeated
                    translate([-motor_width/2+wall-.6,motor_y,motor_z]) rotate([90,0,0]) motor_holes(screw_rad = .1, slot = 0, height = flange_thick);
                    
                    translate([diff_ir_x,motor_y,diff_ir_z]) rotate([0,0,90]) rotate([90,0,0]) diff_ir(solid=1, wall=flange_thick);
                }
            }            
        }
        
        //motor mounting holes
        translate([motor_x-motor_width/2,motor_y,motor_z]) rotate([90,0,0]) motor_holes(slot = .75, height = flange_thick+1);
        
        //cable chain holes
        translate([motor_x-motor_width/2-7,motor_y,motor_z+motor_width/2+chain_width/2+flange_thick+.666]) rotate([0,0,90]) rotate([90,0,0]) cablechain_bracket(solid=0, wall=flange_thick+1);
        
        //depth sensor holes
        if(diff_ir == true){
            translate([diff_ir_x,motor_y,diff_ir_z]) rotate([0,0,90]) rotate([90,0,0]) diff_ir(solid=0, wall=flange_thick);
        }
        
        //cutout for the Aero's non-coprime gear
        //srsly guys, go prime or go home.  Figure it out.
        translate([motor_x-motor_width/2+motor_screw_sep/2,motor_y-8.75,motor_z+motor_screw_sep/2]) rotate([90,0,0]) cylinder(r=19, h=7, center=true);
        
        //groove for the belt
        rotate([0,0,90]) rotate([-90,0,0]) belt_attach_flat();
        
        //instead of belt clamp, just some zip ties - one on each end
        translate([0,0,beam/2]) belt_zips();
                       
        //cutout above the belt - for looks only
        hull(){
            translate([0,0,beam/2+beam]) cube([20,belt_gap,beam], center=true);
            translate([0,0,beam/2*2.6+beam/2+belt_thick/2+1.4]) cube([20,51,beam], center=true);
        }
    }     
}

//back of the carraige, to match; has the belt tensioning system.
module rear_carriage(){    
    difference(){
        union(){
            //the carriage
            vertical_gantry_carriage(v_mount  = false, belt_holes = false, nut_traps=false);
            
            //belt tensioner mount
            rotate([0,0,90]) rotate([-90,0,0])belt_tensioner_mount();
            
            //mount for the attachments
            rotate([0,0,90]) rotate([-90,0,0]) attachment_mount(solid=1, jut=mount_standoff, wall=wall);
        }
        
        //mount for the attachments
        rotate([0,0,90]) rotate([-90,0,0]) attachment_mount(solid=0, jut=mount_standoff, wall=wall+.1);
        
        rotate([0,0,90]) rotate([-90,0,0]) belt_attach_holes();
        
        //groove for the belt
        rotate([0,0,90]) rotate([-90,0,0]) belt_attach_flat();
        
        //instead of belt clamp, just some zip ties - one on each end
        //translate([0,0,beam/2]) belt_zips();
                       
        //cutout above the belt - for looks only
        hull(){
            translate([0,0,beam/2+beam]) cube([20,belt_gap,beam], center=true);
            translate([0,0,beam/2*2.6+beam/2+belt_thick/2+1.4]) cube([20,51,beam], center=true);
        }
        
        translate([50,0,0]) cube([100,100,100],center=true);
    }     
}

module aero_orig(){
    mirror([0,0,0]) translate([-6.75,-flange_thick/2,-23]) rotate([-90,0,0]) import("ASM_EX_AERO_175.stl");
}
