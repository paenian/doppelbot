include <../configuration.scad>
include <../functions.scad>
use <../beam.scad>
use <../endcap/endcap.scad>



wall=3;

gantry_length = 60;
//width is defined by the beam profile.

cyclops_width=30;
cyclops_drop = 18; //how far down the cyclops should be.

ind_rad = 18/2;
ind_offset = beam/2+ind_rad+wall+15;
ind_forward = 12;
ind_lift = 10;
ind_height = 12;

idler_extension = 0; //beam/2+idler_flange_rad+10+6;
idler_extension_x = beam/2+wheel_rad+wheel_clearance/2+idler_flange_rad+1;
idler_extension_y = -mdf_wall/2+idler_rad+pulley_rad*2;


//render everything
part=10;

//parts for laser cutting
if(part == 0)
    //flip for printing
    rotate([180,0,0]) 
    hotend_carriage2();
if(part == 1)
    gantry_end();
if(part == 2)
    gantry_clamp();
if(part == 3)
    gantry_carriage();
if(part == 4){
    rotate([-90,0,0]) belt_stretcher();
}

if(part == 5){
    hotend_mount();
}

if(part == 10){
//flip for printing
    translate([frame_y/2-90,0,0]) rotate([0,0,0]) 
    hotend_carriage2();

    *translate([frame_y/2,-60,0]) gantry_end();

    *translate([frame_y/2,-60,-beam*2]) mirror([0,0,1]) gantry_clamp();
    
    translate([frame_y/2-beam,0,-beam]) gantry_carriage();
    
    translate([frame_y/2-77.5,0,0]) belt_stretcher();
    
    //the endcap, for reference
    translate([0,100,-frame_z/2]) rotate([90,0,0]) assembled_endcap(); 
}




//just a little spar below the gantry to make sure it remains level
//Obsolete!
module gantry_clamp(){
    roller_sep = 40; //distance between rod centers
    ridge_length = 20;
    wall=5;
    
    %translate([-beam/2,0,-beam]) cube([beam, 100, beam*2],center=true);
    
    difference(){
        union(){
            //y wheel mounts
            for(i=[-1,1]) translate([-beam/2, roller_sep/2*i, 0]) roller_mount(1);
            //y wheel support spines
            for(i=[-1,1]) hull(){
                translate([-beam/2, roller_sep/2*i, 0]) roller_mount(1);
                translate([-ridge_length/2-beam/2-(m5_rad+wall),beam/4*i,wall/2]) cube([ridge_length,beam/2,wall], center=true);
            }
            
            //main base
            hull(){
                //gantry beam mount
                for(i=[0,1]) translate([-beam-wall-beam*3/2-i*beam, 0, 0]) cylinder(r=m5_rad+wall, h=wall);
                #translate([-ridge_length/2-beam/2-(m5_rad+wall),0,wall/2]) cube([ridge_length,beam,wall], center=true);
            }
        }
        //holes for the mounts
        for(i=[-1,1]) translate([-beam/2, roller_sep/2*i, 0]) roller_mount(0);
            
        //gantry beam mount
        for(i=[0,1]) translate([-beam-wall-beam*3/2-i*beam, 0, 0]) translate([0,0,wall*1.5+.25]) mirror([0,0,1]) screw_hole_m5(height=wall*2, cap=false);
        //flatten the bottom
        translate([0,0,-100]) cube([200,200,200], center=true);
    }
}

//the top of the gantry
//Obsolete!
module gantry_end(){
    roller_sep = 40; //distance between wheel centers
    ridge_length = 30;
    wall=5;
    %translate([-beam/2,0,-beam-1]) cube([beam, 100, beam*2],center=true);

					//line up with motor   //
	idler_pos = -(frame_y/2-motor_y) - idler_rad - pulley_rad - belt_width;
    
	difference(){
        union(){
            //y wheel support spines
            for(i=[-1,1]) hull(){
                translate([-beam/2, roller_sep/2*i, 0]) roller_mount(1);
                translate([-ridge_length/2-beam/2-(m5_rad+wall),beam/4*i,wall/2]) cube([ridge_length,beam/2,wall], center=true);
            }
            
            //main base
            hull(){
                //idler guide rollers
                for(i=[-1,1]) translate([idler_pos, i*idler_extension, 0]) cylinder(r=m5_rad+wall, h=wall);
            }
            hull(){
                //gantry beam mount
               for(i=[0,1]) translate([-beam-wall-beam/2-beam*i, 0, 0]) cylinder(r=m5_rad+wall, h=wall);
                    //translate([-ridge_length/2-beam/2,0,wall/2]) cube([ridge_length,beam,wall], center=true);
            }
        }
        //holes for the horizontal rollers
        for(i=[-1,1]) translate([-beam/2, roller_sep/2*i, 0]) roller_mount(0);
            
        //idler rollers
        for(i=[-1,1]) translate([idler_pos, i*idler_extension, 0])
           translate([0,0,wall+wall/2+.25]) mirror([0,0,1]) screw_hole_m5(cap=false, height=10);
            
        //gantry beam mount
        for(i=[0,1]) translate([-beam-wall-beam/2-beam*i, 0, wall/2+.25]) translate([0,0,wall+.1]) mirror([0,0,1]) screw_hole_m5(cap=false, height=10);
            
        //flatten the bottom
        translate([0,0,-100]) cube([200,200,200], center=true);
    }
}

module wheel(){
    for(i=[0:1]) mirror([0,0,i]) translate([0,0,-wheel_height*3/8]) cylinder(r1=wheel_rad, r2=wheel_clearance/2+slop, h=wheel_height/4, center=true);
    cylinder(r=wheel_clearance/2+slop, h=wheel_height/2, center=true);
}



//New roller mounts that are flush with the end of the beam
//  move the wheel support back and use a spacer to mount the wheels.
module roller_mount(solid=1){
    wall = 5;
    min_rad = wall/2;
    w = wheel_height+wall;
    r = 10;//(wheel_clearance+wall)/2;
    
    //main body
    if(solid==1){
        translate([0,0,wheel_rad]) rotate([0,90,0]){
            translate([0,0,-m5_nut_height-wall-wheel_height/2]) cylinder(r=m5_nut_rad+wall/2+.5, h=m5_nut_height+wall);
        }
    }
    
    //hull section
    if(solid==2){
        *translate([0,0,wheel_rad]) rotate([0,90,0]){
            translate([0,0,-m5_nut_height-wall-wheel_height/2]) cylinder(r=m5_nut_rad+wall/2, h=m5_nut_height+wall);
        }
    }
    
    //wheel cutouts
    if(solid==0){
        //cutout for wheel            
            translate([0,0,wheel_rad]) rotate([0,90,0]){
                rotate([0,0,-90]) cap_cylinder(r=m5_rad, h=40, center=true);
                difference(){
                    %wheel();
                    cylinder(r=wheel_clearance/2+slop, h=wheel_height+2, center=true);
                    translate([0,0,-m5_nut_height-wall-wheel_height/2]) cylinder(r=m5_nut_rad+wall/2, h=m5_nut_height+wall-2);
                    #translate([0,0,-m5_nut_height-wall-wheel_height/2+m5_nut_height+wall-2.1]) cylinder(r1=m5_nut_rad+wall/2, r2=8/2, h=2.1);
                }
                translate([0,0,-wheel_height/2-m5_nut_height+1-wall]) cylinder(r1=m5_nut_rad+slop, r2=m5_nut_rad, h=m5_nut_height-1, $fn=6);
					hull(){
                	translate([0,0,-wheel_height/2-m5_nut_height-1-wall-4.9+2]) cylinder(r1=m5_nut_rad+slop*2, r2=m5_nut_rad+slop, h=m5_nut_height+.5, $fn=6);
						translate([-10,0,-wheel_height/2-m5_nut_height-1-wall-4.9+2]) cylinder(r1=m5_nut_rad+slop, r2=m5_nut_rad+slop, h=m5_nut_height+.5, $fn=6);
					}
            }
    }
}

module beam_holder(){
    wall = 5;
    translate([0,beam/2,wall]){
        if(solid==1){
            hull(){
                translate([0,0,beam/4+wall/2]) cube([beam+wall*2, beam+wall*2, beam/2+wall], center=true);
                translate([0,beam/4+wall/2,beam/2+wall]) cube([beam+wall*2, beam/2+wall, beam+wall*2], center=true);
            }
            
            //fillets
            hull(){
                for(i=[0,1]) mirror([i,0,0]) translate([beam/2+wall,0,0]) rotate([90,0,0]) scale([1.25,1.5,1]) cylinder(r=wall, h=beam+wall*2, center=true, $fn=4);
                    
                translate([0,beam/2+wall,0]) rotate([0,90,0]) scale([1.5,.65,1]) cylinder(r=wall, h=beam+wall*2, center=true, $fn=4);
            }
        }
        
        if(solid==-1){
            //beam
            translate([0,slop-beam/2,beam]) cube([beam+slop, beam*2+slop*2, beam*2], center=true);
            
            //mounting holes
            translate([0,0,beam]) rotate([0,90,0]) cylinder(r=m5_rad, h=beam*5, center=true);
            translate([0,0,beam]) rotate([90,0,0]) cylinder(r=m5_rad, h=beam*5, center=true);
        }
        
    }
}

module gantry_carriage(){
    wall=5;
    min_rad = 2;
    carriage_len = 50;
    carriage_spread = 25;
    rotate([0,0,90]) rotate([-90,0,0]) {
    %translate([0,0,-beam/2-1]) cube([120,beam*2,beam],center=true);
    %translate([0,0,mdf_wall/2+30]) cube([beam,beam*2,60],center=true);
    difference(){
        union(){
            //idler mounts
            translate([0,0,mdf_wall/2]) idler_mounts(solid=1);
            
            //guide wheels
            difference(){
                guide_wheel_helper(solid=1, span=2, gantry_length=carriage_len, gantry_spread = carriage_spread, cutout=false);
                
                
                //round the front corners
                *for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2+min_rad,beam/2+m5_rad+wall+1,0]) difference(){
                    translate([-min_rad-1,0,-wall]) cube([min_rad+1, min_rad+1, wall*5]);
                    cylinder(r=min_rad, h=wall*11, center=true);
                }
            }
            
            //lovingly clasp the beam
            beam_holder(solid=1);

            
        } //Holes below here
        
        //beam slot
        beam_holder(solid=-1);
        
        //guide wheels
        translate([0,0,mdf_wall-1]) rotate([0,0,180]) mirror([0,0,1]) guide_wheel_helper(solid=-1, span=2, gantry_spread = carriage_spread, gantry_length=carriage_len);
        
        //idler screws
        translate([0,0,mdf_wall/2]) idler_mounts(solid=0);
        
        //holes for the beam
        //for(i=[-beam/2, beam/2]) translate([0,i,-1]) cap_cylinder(r=m5_rad, h=20);
        
        //belt path
        translate([0,-beam/2,0]) cube([100,belt_thick*2,wall], center=true);
        
        //flatten the bottom
        translate([0,0,-50]) cube([100,100,100],center=true);
        
    }
}
}

module idler_mounts(solid=1){
    wall=5;
    bump_height = 1;
    translate([0,-beam/2,0]) for(i=[0,1]) mirror([i,0,0]) {
        if(solid==1){
            hull(){
                translate([beam/2+idler_rad+wall,0,0]) rotate([90,0,0]) cylinder(r=idler_rad+wall, h=idler_thick+wall*2, center=true);
            
                translate([idler_extension_x,0,idler_extension_y]) rotate([90,0,0]) cylinder(r=idler_rad, h=idler_thick+wall+bump_height*2, center=true);
                //%translate([idler_extension_x,0,idler_extension_y]) rotate([90,0,0]) cylinder(r=idler_rad, h=50, center=true);
            
            }
        }
        if(solid <= 0){
            translate([idler_extension_x,0,idler_extension_y]) rotate([90,0,0])
            difference(){
                cylinder(r=idler_flange_rad+1, h=idler_thick+bump_height*2, center=true);
                
                //belt paths
                for(j=[0,-90]) rotate([0,0,j]) translate([0,-idler_rad,0]) 
                    %cube([100, belt_width*1.5, belt_thick], center=true);
                
                //bumps
                for(i=[0,1]) mirror([0,0,i]) translate([0,0,idler_thick/2]) cylinder(r1=m5_rad+1, r2=idler_rad, h=bump_height+.1);
                
            }
        
            translate([idler_extension_x,0,idler_extension_y]) rotate([90,0,0]) cylinder(r=m5_rad, h=idler_thick*3, center=true);
        }
    }
}

module belt_screwholes(){
    wall = 5;
    for(i=[-1,1]) for(j=[-1,1]) translate([i*(gantry_length/2-wheel_rad),j*(idler_extension_x-idler_rad),0]){
        if(solid==0){
            cylinder(r=m5_rad, h=wall*3, center=true);
            translate([0,0,-wall+1]) cylinder(r2=m5_nut_rad, r1=m5_nut_rad+slop, h=wall, $fn=6);
        }
        if(solid==1){
            hull(){
                cylinder(r=m5_rad+wall,h=wall);
                translate([0,-10*j,0]) cylinder(r=m5_rad+wall,h=wall);
            }
        }
    }
}

module belt_left_screwholes(solid=1, screw_sep = 50){
    wall = 5;
    for(i=[-1,1]) translate([i*screw_sep/2,idler_extension_x-idler_rad+m5_rad,0]){
        if(solid==0){
            cylinder(r=m5_rad, h=wall*3, center=true);
            translate([0,0,-wall+1]) cylinder(r2=m5_nut_rad, r1=m5_nut_rad+slop, h=wall, $fn=6);
        }
        if(solid==1){
            hull(){
                cylinder(r=m5_rad+wall,h=wall);
                translate([0,-10,0]) cylinder(r=m5_rad+wall,h=wall);
            }
        }
    }
}

module belt_stretcher(){
    wall = 5;
    
    height = 10;
    length = 15;
    peg = 12;
    peg_rad = m5_rad;
    
    translate([0,-50,0])
    difference(){
        union(){
            //base
            translate([-15/2,-length/2,-height+wall]) cube([15,length,height]);
            
            //knob
            intersection(){
                union(){
                    hull(){
                        translate([0,0,-(height)/2-peg]) cylinder(r=peg_rad, h=height+peg);
                        translate([0,length/2,-(height)/2-peg]) cylinder(r=1, h=height+peg);
                    }
                    hull(){
                        translate([0,0,-height/2-peg]) cylinder(r1=peg_rad+wall/2, r2=peg_rad, h=peg/4);
                        translate([0,length/2,-(height)/2-peg]) cylinder(r=1-.15, h=peg/4);
                    }
                }
                
                translate([-15/2,-length/2,-height*2]) cube([15,length,height*2]);
            }
        }
        
        //hole for the tensioning screw
        translate([0,-m5_nut_height/2-.5,0]) rotate([90,0,0]) cylinder(r=m5_rad+slop, h=25);
        translate([0,10,0]) rotate([90,0,0]) cylinder(r=m5_rad+slop, h=10);
        
        //tensioning nut hole
        translate([0,0,0]) hull(){
            rotate([90,0,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad, h=m5_nut_height, $fn=4, center=true);
            translate([0,.5,10]) rotate([90,0,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad+.125, h=m5_nut_height+1, $fn=4, center=true);
        }
        
        //stretch pole screw
        *translate([0,wall,0]) {
            cylinder(r=m5_rad, h=60, center=true);
            translate([0,0,-m5_sq_nut_rad*cos(180/4)-m5_cap_height]) cylinder(r1=m5_cap_rad, r2=m5_cap_rad+.5, h=m5_cap_height+20);
        }
    }
}

module belt_tensioner(solid=1){
    wall = 5;
    bump_height=1;
    //two redirects
    if(solid==1){
        hull(){
            for(i=[-1,1]) translate([i*(idler_rad+m5_rad),0,0]){
                translate([0,-idler_extension_x,-(beam/2-idler_thick/2)]) cylinder(r=m5_rad+wall/2, h=wall+beam/2-idler_thick/2);
                translate([0,-idler_extension_x/2,0]) cylinder(r=m5_rad+wall/2, h=wall);
            }
        }
        
        //bumps
        for(i=[-1,1]) translate([i*(idler_rad+m5_rad),0,0])
            translate([0,-idler_extension_x,-wall-bump_height]) cylinder(r1=m5_rad+1, r2=m5_rad+wall/2, h=bump_height+.1);
        
        //belt stretcher roughed in
        %belt_stretcher();
    }else{
        //holes for idlers
        for(i=[-1,1]) translate([i*(idler_rad+m5_rad),0,0])
            translate([0,-idler_extension_x,0]) cylinder(r=m5_rad, h=wall*3, center=true);
        
        //screwhole to align the stretcher
        translate([0,-29,0]) rotate([90,0,0]) cylinder(r=m5_rad, h=30);
    }
}

//redo the carriage.
//Rotate the nozzles to face forwards
//move induction sensor to behind nozzles?
//bonus: able to install two cyclopses, one forward one reverse?
// - would be really hard to level the right-side nozzles.
module hotend_carriage2(){
    gantry_length = 50;
    wall=5;
    min_rad = 2;
    
    %translate([0,0,-beam-1]) cube([120,beam,beam*2],center=true);
    difference(){
        union(){
            
            //rough in the bits
            //cyclopses
            %translate([0,15+beam/2+15,-30]) cube([28, 30, 60],center=true);
            //%translate([15,(15+beam/2+15),-30]) cube([28, 30, 60],center=true);
            
            //belt clamp on one side, induction sensor on the other
            %translate([-10, -beam/2-26, -20]) cylinder(r=9, h=60, center=true);
            
            //belt tensioner
            translate([gantry_length/4+2, 0, 0]) belt_tensioner(solid=1);
            
            //belt attachment
            belt_left_screwholes(solid=1, screw_sep = gantry_length);
            
            //guide wheels
            difference(){
                hull() guide_wheel_helper(solid=1,gantry_length=gantry_length, cutout=false);
                
                //cutout for the cyclops
                translate([0,beam/2+wall+1+min_rad+5,-cyclops_drop-wall]) minkowski(){
                    cube([cyclops_width+.5,20,100], center=true);
                    cylinder(r=min_rad, h=1);
                }
                
                //round the front corners
                *for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2+min_rad,beam/2+m5_rad+wall+1,0]) difference(){
                    translate([-min_rad-1,0,-wall]) cube([min_rad+1, min_rad+1, wall*5]);
                    cylinder(r=min_rad, h=wall*11, center=true);
                }
            }
            
            //induction sensor mount
            translate([-ind_forward, -ind_offset,-ind_height+wall-ind_lift]) rotate([0,0,-180]) {
                extruder_mount(solid=1, m_height=ind_height+.25,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                hull(){
                    translate([0,-3,ind_height+ind_lift-.1]) cylinder(r=ind_rad+6, h=.2, center=true);
                    translate([0,0,ind_height-.1]) cylinder(r=(ind_rad+3)/cos(30), h=.1, $fn=6);
                }
            }
            
        } //Holes below here
        
        //guide wheels
        mirror([0,1,0]) guide_wheel_helper(solid=-1,gantry_length=gantry_length, cutout=false);
        
        //belt screws
        belt_left_screwholes(solid=0, screw_sep = gantry_length);
        
        //belt tensioner
        translate([gantry_length/4+2, 0, 0]) belt_tensioner(solid=0);
        
        //cyclops mount
        *translate([0,beam/2+wall+1,-cyclops_drop-wall+2]) cyclops_holes(solid=-1, jut=0, wall=wall);
        
        //induction sensor mount
        translate([-ind_forward, -ind_offset,-ind_height+wall-ind_lift]) rotate([0,0,-180]) {
                extruder_mount(solid=0, m_height=ind_height,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                translate([0,0,ind_height-.1]) cylinder(r1=ind_rad, r2=ind_rad+2, h=ind_lift+.15);
            }
        //cutout for the belt
        translate([0,-ind_offset+11,-beam/2-2]) cube([60,belt_width+2,belt_thick+6], center=true);
    }
}

module hotend_carriage(){
    wall=3;
    min_rad = 2;
    
    %translate([0,0,-beam-1]) cube([120,beam,beam*2],center=true);
    difference(){
        union(){
            //belt mounts
            belt_screwholes(solid=1);
            
            //guide wheels
            difference(){
                guide_wheel_helper(solid=1);
                
                //cutout for the cyclops
                translate([0,beam/2+wall+1+min_rad+10,-cyclops_drop-wall]) minkowski(){
                    cube([cyclops_width-min_rad*2+.5,20,100], center=true);
                    cylinder(r=min_rad, h=1);
                }
                
                //round the front corners
                for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2+min_rad,beam/2+m5_rad+wall+1,0]) difference(){
                    translate([-min_rad-1,0,-wall]) cube([min_rad+1, min_rad+1, wall*5]);
                    cylinder(r=min_rad, h=wall*11, center=true);
                }
            }
            
            //cyclops mount
            translate([0,beam/2+wall+1,-cyclops_drop-wall+2]) {
                hull() {
                    for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2-wall,0,cyclops_drop+wall]){
                        rotate([90,0,0]) cylinder(r=wall, h=wall);
                    }
                    cyclops_holes(solid=1, jut=0, wall=wall);
                }
                intersection(){
                    for(i=[0,1]) mirror([i,0,0]) rotate([0,23.5,0]) hull(){
                        translate([-1.5,-.1,0]) cube([3, .1, cyclops_drop*2]);
                        translate([-.5,2-.1,0]) cube([1, .1, cyclops_drop*2]);
                    }
                    cube([cyclops_width, 30, cyclops_drop*2+wall*2+wall*2], center=true);
                }
                cyclops_holes(solid=1, jut=1, wall=wall);
            }
            
            //induction sensor mount
            translate([0, -ind_offset,-ind_height+wall-ind_lift+wall-1]) mirror([0,1,0]) rotate([0,0,90]) {
                extruder_mount(solid=1, m_height=ind_height+.25,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                translate([0,0,ind_height-.1]) cylinder(r=(ind_rad+wall)/cos(30), h=ind_lift+.1, $fn=6);
            }
            
        } //Holes below here
        
        //guide wheels
        guide_wheel_helper(solid=-1);
        
        //belt screws
        belt_screwholes(solid=0);
        
        //cyclops mount
        translate([0,beam/2+wall+1,-cyclops_drop-wall+2]) cyclops_holes(solid=-1, jut=0, wall=wall);
        
        //induction sensor mount
        translate([0, -ind_offset,-ind_height+wall-ind_lift+wall-1]) mirror([0,1,0]) rotate([0,0,90]) {
                extruder_mount(solid=0, m_height=ind_height,  hotend_rad=ind_rad, wall=3);
            //offset the mount
                translate([0,0,ind_height-.1]) cylinder(r1=ind_rad, r2=ind_rad+2, h=ind_lift+.15);
            }
    }
}

module guide_wheel_helper(solid=0, span=1, cutout=true, gantry_spread = 0){
    min_rad=3;
    wall=5;
    
    eccentric_offset = wheel_rad+(eccentric_rad-m5_rad)/2-.25;
    
    if(solid >= 0){
        difference(){
            hull(){
                for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
                    translate([i*gantry_spread/2,span*beam/2+wheel_rad,0]) cylinder(r=wall/2, h=wall);
                    translate([0,-span*beam/2-eccentric_offset,0]) cylinder(r=wall/2, h=wall);
                }
            }
            
            %for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
                translate([0,span*beam/2+wheel_rad,-beam/2]) wheel();
                translate([0,-span*beam/2-eccentric_offset,-beam/2]) wheel();
            }
               
            if(cutout==true)
                for(i=[0,1]) mirror([i,0,0]) translate([gantry_length/2,0,-.1]){
					cylinder(r=beam/2, h=wall+.2);
            }
            
            for(i=[0,1]) mirror([0,i,0]) translate([0,span*beam/2+wheel_rad,-.1]){
                hull() for(j=[0,1]) mirror([j,0,0]) translate([gantry_length/2-m5_rad-wall-min_rad/2,wall,0]) 
                    cylinder(r=min_rad/2, h=wall+.2);
            }
        }
        
        for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
            translate([i*gantry_spread/2,span*beam/2+wheel_rad,0]) cylinder(r=m5_rad+wall, h=wall);
            translate([0,-span*beam/2-eccentric_offset,0]) cylinder(r=m5_rad+wall, h=wall);
        }
    }
    if(solid <= 0){
        for(i=[-1,1]) translate([i*gantry_length/2,0,-.1]){
            translate([0,span*beam/2+wheel_rad,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,span*beam/2+wheel_rad,-wall-.95]) cylinder(r=eccentric_rad+4, h=wall+1);
            
            translate([i*gantry_spread/2,-span*beam/2-eccentric_offset,0]) cylinder(r1=eccentric_rad+.5, r2=eccentric_rad, h=wall+1);
            translate([i*gantry_spread/2,-span*beam/2-eccentric_offset,-wall-.95]) cylinder(r=eccentric_rad+4, h=wall+1);
            
        }
    }
}



//mounting holes for the cyclops
module cyclops_holes(solid=0, jut=0){
    hole_sep = 9;
    hole_zsep = 10;
    ind_jut = 2;
    flat = 2;
    
    for(i=[0,1]) mirror([i,0,0]){
        translate([hole_sep/2,-wall,hole_zsep]) rotate([-90,0,0]){
            if(solid>=0){
                cylinder(r=m3_rad+flat, h=wall);
                if(jut==1){
                    translate([0,0,wall-.1]) cylinder(r1=m3_rad+flat, r2=m3_rad+flat/2, h=ind_jut+.1);
                }
            }
            if(solid<=0) translate([0,0,-.1]) {
                rotate([0,0,180]) cap_cylinder(r=m3_rad, h=wall*50, center=true);
                rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
            }
        }
    }
    
    translate([0,-wall,0]) rotate([-90,0,0]){
        if(solid>=0){
            cylinder(r=m3_rad+flat+1, h=wall);
            if(jut==1){
                translate([0,0,wall-.1]) cylinder(r1=m3_rad+flat, r2=m3_rad+flat/2, h=ind_jut+.1);
            }
        }
        if(solid<=0) translate([0,0,-.1]) {
            %translate([0,-wall,9+wall+ind_jut+.1]) cube([30,50,18], center=true);
            %translate([0,-wall,6+wall+ind_jut+.1]) rotate([90,0,0]) cylinder(r=1, h=50, center=true);
            rotate([0,0,180]) cap_cylinder(r=m3_rad, h=wall*50, center=true);
            rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height);
            
            //cutout above the block
        }
    }
}

//reusing this to make the induction mount :-)
module extruder_mount(solid = 1, m_height = 10, m_thickness=50, fillet = 8, tap_height=0, width=20){
	gap = 3;
	tap_dia = 9.1;
	tap_rad = tap_dia/2;
	
	clamp_offset = 1.5+1.5;
    nut_rad = 5;
    
    bolt_rad = m3_rad;

	if(solid){		
		//clamp material
		if(m_height > nut_rad*2){
			cylinder(r=(hotend_rad+wall)/cos(30), h=m_height, $fn=6);
			hull(){
                translate([hotend_rad+bolt_rad+clamp_offset,gap,m_height/2]) rotate([-90,0,0]) cylinder(r=m_height/2, h=wall+1);
                translate([hotend_rad+bolt_rad+clamp_offset,gap,m_height/2]) rotate([0,60,0]) translate([-ind_lift,0,0]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
            }
			hull(){
                translate([hotend_rad+bolt_rad+clamp_offset,-wall-1,m_height/2]) rotate([-90,0,0]) cylinder(r=m_height/2, h=wall+1);
                translate([hotend_rad+bolt_rad+clamp_offset,-wall-1,m_height/2]) rotate([0,60,0]) translate([-ind_lift,0,0]) rotate([-90,0,0]) cylinder(r=m_height/2/cos(30), h=wall+1, $fn=6);
            }
		}
	}else{
		union(){
			//hotend hole
			translate([0,0,-.05]) cylinder(r=hotend_rad/cos(180/18)+.1, h=m_height*3, $fn=36);
            //flare the underside
            translate([0,0,-16]) cylinder(r1=hotend_rad/cos(180/18)+2 , r2=hotend_rad/cos(180/18)+.1, h=16, $fn=36);

			//bolt slots
			if(m_height > nut_rad*2){
				render() translate([hotend_rad+bolt_rad+clamp_offset,-m_thickness-.05,m_height/2]) rotate([-90,0,0]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=m_thickness+10);
				translate([hotend_rad+bolt_rad+clamp_offset,-wall*3.5-1,m_height/2]) rotate([-90,0,0]) cylinder(r2=m3_nut_rad, r1=m3_nut_rad+2, h=wall*3, $fn=6);

				//mount tightener
				translate([hotend_rad+bolt_rad+clamp_offset,wall+gap,m_height/2]) rotate([-90,0,0]) rotate([0,0,180]) cap_cylinder(r=m3_cap_rad, h=10);
				translate([0,0,-m_height*2]) cube([wall*8, gap, m_height*10+.1]);
			}
		}
	}
}