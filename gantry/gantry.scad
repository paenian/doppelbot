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
idler_extension_x = beam/2+idler_flange_rad+1;

idler_extension_y = -mdf_wall/2+idler_rad+pulley_rad*2-2;

carriage_thick = 6;

stretcher_mount_sep = 40;

//render everything
part=888;

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
    rotate([0,90,0]) gantry_carriage();
if(part == 4){
    translate([0,0,belt_thick/2]) rotate([0,90,0]) belt_tensioner_clamp();
}

if(part == 5){
    hotend_mount();
}

if(part == 6){
    rotate([0,90,0]) vertical_gantry_carriage();
}

if(part == 9){
    rotate([0,0,90]) attachment_base();
}

if(part == 91){
    rotate([0,0,90]) attachment_base_aero();
}

if(part == 92){
    rotate([0,0,90]) attachment_base_chimaera();
}

if(part == 7){
    vertical_gantry_carriage_rear();
}

if(part == 77){
    rotate([0,90,0]) vertical_gantry_carriage_rear_flat();
    %translate([0,-100,0]) vertical_gantry_carriage_rear();
}

if(part == 88){
    translate([0,0,belt_thick/2+1]) rotate([0,90,0]) belt_tensioner_clamp();
}

if(part == 888){
    translate([0,0,belt_thick/2+1.5]) rotate([0,-90,0]) belt_tensioner_double_clamp();
}

if(part == 8){
    belt_stretcher_2(solid=1, mount_sep=stretcher_mount_sep);
}

if(part == 10) translate([0,0,0]) {
//flip for printing
    *translate([frame_y/2-76,0,0]) rotate([0,0,0]) 
    hotend_carriage2();

    *translate([frame_y/2,-60,0]) gantry_end();

    *translate([frame_y/2,-60,-beam*2]) mirror([0,0,1]) gantry_clamp();
    
    translate([frame_y/2-beam,0,-beam]) gantry_carriage();
    
    translate([frame_y/2-beam-80,beam/2+1,-beam]) rotate([0,0,-90]) vertical_gantry_carriage();
    
    translate([frame_y/2-beam-80,beam/2+1+carriage_thick+1,-beam]) rotate([0,0,-90]) translate([1,-10,10]) 
    rotate([0,-90,0]) belt_tensioner_clamp();
    
    translate([frame_y/2-beam-80,-beam/2-1,-beam]) rotate([0,0,90]) vertical_gantry_carriage_rear();
    
    *translate([frame_y/2-77.5,0,0]) belt_stretcher();
    
    //the endcap, for reference
    *translate([0,225,-frame_z/2]) rotate([90,0,0]) assembled_endcap(); 
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
                    translate([-ridge_length/2-beam/2-(m5_rad+wall),0,wall/2]) cube([ridge_length,beam,wall], center=true);
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
    for(i=[0:1]) mirror([0,0,i]) translate([0,0,-wheel_height/2]) cylinder(r1=wheel_inner_rad, r2=wheel_rad, h=(wheel_height-wheel_inner_height)/2);
    cylinder(r=wheel_rad, h=wheel_inner_height, center=true);
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
                    translate([0,0,-m5_nut_height-wall-wheel_height/2+m5_nut_height+wall-2.1]) cylinder(r1=m5_nut_rad+wall/2, r2=8/2, h=2.1);
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
                translate([0,0,beam/4+wall/2]) cube([beam+wall*2, beam+wall*2, beam/2], center=true);
                translate([0,beam/4+wall/2,beam/2+wall]) cube([beam+wall*2, beam/2+wall, beam], center=true);
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
            translate([0,0,beam-wall]) rotate([0,90,0]) cylinder(r=m5_rad, h=beam*5, center=true);
            translate([0,0,beam]) rotate([90,0,0]) cylinder(r=m5_rad, h=beam*5, center=true);
        }
        
    }
}

module gantry_carriage(){
    wall=5;
    min_rad = 2;
    carriage_len = 50;
    carriage_spread = 25;
    spring_inset = -1;
    rotate([0,0,90]) rotate([-90,0,0]) {
    %translate([0,0,-beam/2-1]) cube([120,beam*2,beam],center=true);
    %translate([0,0,mdf_wall/2+30]) cube([beam,beam*2,60],center=true);
    difference(){
        union(){
            //idler mounts
            translate([0,0,mdf_wall/2]) idler_mounts(solid=1);
            
            //guide wheels
            difference(){
                guide_wheel_helper(solid=1, span=2, gantry_length=carriage_len, gantry_spread = carriage_spread, cutout=false, spring_inset = spring_inset);
                
                
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
        //translate([0,0,mdf_wall-1]) rotate([0,0,180]) mirror([0,0,1])
        guide_wheel_helper(solid=-1, span=2, gantry_spread = carriage_spread, gantry_length=carriage_len, spring_inset = spring_inset);
        
        //idler screws
        translate([0,0,mdf_wall/2]) idler_mounts(solid=0);
        
        //holes for the beam
        //for(i=[-beam/2, beam/2]) translate([0,i,-1]) cap_cylinder(r=m5_rad, h=20);
        
        //belt path - deprecated.
        translate([0,-beam/2,0]) cube([100,belt_thick+4,wall/2], center=true);
        
        //flatten the bottom
        translate([0,0,-50]) cube([100,100,100],center=true);
        
    }
}
}

//holes for the motor
module motor_holes(screw_rad = m3_rad+slop/2, screw_w = 31, slot=2, height = wall*3){
    bump_rad = 12;
    
    cylinder(r=bump_rad, h=height, center=true);
    %translate([0,0,-20]) cylinder(r=pulley_flange_rad, h=height*2);
    for(i=[0:90:359]) rotate([0,0,i]) translate([screw_w/2, screw_w/2, 0]){
        hull(){
            translate([-slot/2,-slot/2,0]) cylinder(r=screw_rad, h=height, center=true);
            translate([slot/2,slot/2,0]) cylinder(r=screw_rad, h=height, center=true);
        }
    }
}

module chimaera_helper(solid = 1, jut = 1, height = 5, proud = 2){
    hole_sep = 9;
    hole_zsep = 10;
    wall =5;
    ind_jut = proud;
    flat = 1;
    
    for(i=[-1,0,1]) {
        translate([hole_sep/2*i,-height,abs(hole_zsep * i)]) rotate([-90,0,0]){
            if(solid>=0){
                cylinder(r=m3_rad+wall, h=height);
                if(jut==1){
                    translate([0,0,height-.1]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=ind_jut+.1);
                }
            }
            
            if(solid<=0) translate([0,0,-.1]) {
                translate([0,0,ind_jut+.25]) cap_cylinder(r=m3_rad, h=wall*2);
                translate([0,0,-height]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height+wall);
            }
        }
    }
}

module attachment_base_chimaera(){
    thick = 4;
    bot_width = 10;
    
    drop = 33;
    
    %translate([0,18,5]) cube([10,10,10], center=true);
    
    difference(){
        union(){
            attachment_base();
            
            intersection(){
                union(){
                    translate([0,7.3,thick-.1]) scale([.725,.725,1]) attachment_mount(solid=0, extra_top = 0, wall=0, cutout = false);
                    cube([bot_width-slop*2,100,50], center=true);
                }
                
                translate([0,drop,thick]) rotate([90,0,0]) chimaera_helper(solid = 1, height=thick);
            }
        }
        
        translate([0,drop,thick]) rotate([90,0,0]) chimaera_helper(solid = -1, height=thick);
    }
}

module attachment_base_aero(){
    wall = 5;
    slot_len = 5;
    base_height = 4;
    
    motor_w = 42;
    
    motor_drop = 42/2+slot_len*1.5+5+1;
    motor_extra_drop = 2;
    
    brace_width = motor_w/3;
    brace_height = motor_w/2;
    
    extra_jut = 13;
    
    difference(){
        union(){
            attachment_base();
            
            //motor plate
            hull() {
                translate([0,motor_drop+motor_extra_drop,base_height+31/2+5+extra_jut]) rotate([0,90,0]) motor_holes(screw_rad = 5, slot = 0, height = wall);
                translate([0,motor_drop-wall/2,base_height+31/2+1])rotate([0,90,0]) motor_holes(screw_rad = 5, slot = 0, height = wall);
            }
            
            //top brace
            hull(){
                #translate([0,motor_drop-motor_w/2-wall/2-.25,base_height+wall/2]) cube([brace_width,wall,wall+.1],center=true);
                translate([0,motor_drop-motor_w/2-wall/2-.25,base_height+wall/2+brace_height]) cube([wall,wall,wall+.1],center=true);
            }
        }
        
        //motor holes
        translate([0,motor_drop+motor_extra_drop,base_height+31/2+5+extra_jut]) rotate([0,90,0]) motor_holes(slot = .5, height = wall+1);
        
        //clear the screwheadhole
        translate([0,slot_len*1.5,base_height]) cylinder(r=5, h=50);
    }
}

module attachment_base(){
    wall = 6;
    slot_len = 5;
    
    
    translate([0,0,-wall]) 
    difference(){
        union(){
            attachment_mount(solid=0, extra_top = 0, wall=wall, cutout = false);
            
            //extra top bump
            translate([0,0,.25]) scale([.95,.95,1]) attachment_mount(solid=0, extra_top = 0, wall=wall, cutout = false);
            
            translate([0,slot_len*1.5,wall]) cylinder(r=m5_cap_rad+slop, h=4);
        }
        
        translate([0,slot_len*1.5,0]) cylinder(r=m5_rad+slop, h=wall*5.1, center=true);
    }
}

//this is a v-groove attachment mount.
module attachment_mount(solid = 1, jut = 0, wall=wall, extra_top = 1, cutout = true, rad = 3){
    bot_width = 10;
    height = 20;
    
    drop = beam/2;
    
    side_angle = 20; //the angle of the V
    cut_angle = 30; //the angle of the inside of the V-groove
    
    slot_len = 5;
    
    thick = 4;
    
    base = thick * tan(cut_angle);
    echo(base);
    bot_rad = rad + thick * tan(cut_angle) + solid*rad;
    
    //%cube([bot_width, 90, 15], center=true);
    
    //if(solid == 1){
        translate([0,drop,0]) hull(){
            for(i=[0,1]) mirror([i,0,0]) translate([(bot_width-rad*2)/2+thick/2*solid,height,0]){
                //lower sides
                translate([0,0,wall]) cylinder(r1=bot_rad, r2=rad, h=thick);
                if(solid == 1) cylinder(r=bot_rad, h=wall+.1);
                    
                //upper sides
                translate([0,0,wall]) rotate([0,0,side_angle]) translate([0,-height+(solid-extra_top)*bot_rad,0]) cylinder(r1=bot_rad, r2=rad, h=thick);
                if(solid == 1) rotate([0,0,side_angle]) translate([0,-height,0]) cylinder(r1=bot_rad, r2=rad, h=wall+.1);
            }
        }
    //}
    echo(solid);
        echo(base);
    translate([0,slot_len/2,0]) {
    if(solid == 0 && cutout == true){
        //open up the bottom
        translate([0,0,wall*1.5]) cube([bot_width, 90, wall], center=true);
        
        //slot for the locking screw
        hull(){
            for(i=[0,1]) translate([0,i*slot_len,0]) cylinder(r=m5_rad-slop*(i-1), h=wall*2.1, center=true);
        }
        
        //slot for the locking nut
        hull(){
            for(i=[0,1]) translate([0,i*slot_len,-.1]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad+slop-slop*(i-1), h=wall/2, $fn=4);
        }
        
        //hole to insert the locking nut
        hull(){
            for(i=[0,1]) translate([0,-slot_len/2,0]) rotate([0,0,45]) cylinder(r=m5_sq_nut_rad+slop*2, h=wall*2.1, $fn=4, center=true);
        }
    }
}
}

module attachment_mount_screws(solid=1, jut=1){
    wall=carriage_thick;
    hole_sep = 15;
    translate([0,beam/4,0]) {
        //upper holes
        for(i=[-1.5:1:1.5]) translate([hole_sep*i,0,0]){
            if(solid == 1){
                cylinder(r=m5_cap_rad+2, h=wall+.05);
                translate([0,0,wall]) cylinder(r1=m5_cap_rad+2, r2=m5_rad+2, h=jut);
            }else{
                translate([0,0,-.1]){
                    cylinder(r1=m5_nut_rad+slop, r2=m5_nut_rad, h=m5_nut_height, $fn=6);
                    translate([0,0,m5_nut_height+slop]) cylinder(r=m5_rad+slop, h=wall*5);
                }
            }
        }
        //lower holes
        for(i=[-.5:1:.5]) translate([hole_sep*i,hole_sep,0]){
            if(solid == 1){
                cylinder(r=m5_cap_rad+2, h=wall+.05);
                translate([0,0,wall]) cylinder(r1=m5_cap_rad+2, r2=m5_rad+2, h=jut);
            }else{
                translate([0,0,-.1]){
                    cylinder(r1=m5_nut_rad+slop, r2=m5_nut_rad, h=m5_nut_height, $fn=6);
                    translate([0,0,m5_nut_height+slop]) cylinder(r=m5_rad+slop, h=wall*5);
                }
            }
        }
    }
}

//mounting holes for the cyclops
module chimaera_holder(solid=0, jut=0){
    hole_sep = 9;
    hole_zsep = 10;
    ind_jut = 4;
    wall =5;
    
    for(i=[0,1]) mirror([i,0,0]){
        translate([hole_sep/2,-wall,hole_zsep]) rotate([-90,0,0]){
            if(solid>=0){
                cylinder(r=m3_rad+wall, h=wall);
                if(jut==1){
                    translate([0,0,wall-.1]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=ind_jut+.1);
                }
            }
            if(solid<=0) translate([0,0,-.1]) {
                translate([0,0,ind_jut+.25]) cap_cylinder(r=m3_rad, h=wall*2);
                translate([0,0,-wall]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height+wall);
            }
        }
    }
    
    translate([0,-wall,0]) rotate([-90,0,0]){
        if(solid>=0){
            cylinder(r=m3_rad+wall, h=wall);
            if(jut==1){
                translate([0,0,wall-.1]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=ind_jut+.1);
            }
        }
        if(solid<=0) translate([0,0,-.1]) {
            translate([0,-5,9+wall+ind_jut+.1]) cube([30+1,200,18], center=true);
            %translate([0,-5,9+wall+ind_jut+.1]) cube([30,30,18], center=true);
            translate([0,-5,6+wall+ind_jut+.1]) rotate([90,0,0]) cylinder(r=1, h=50, center=true);
            translate([0,0,ind_jut+.25]) cap_cylinder(r=m3_rad, h=wall*2);
            translate([0,0,-wall]) cap_cylinder(r=m3_cap_rad, h=m3_cap_height+wall);
        }
    }
}

module belt_tensioner_mount(carriage_len=60){
    thick = belt_thick+2;
    base_thick = carriage_thick;
    screw_jut = base_thick+m3_cap_rad+belt_width*2+1;
    
    width = 5;
    
    translate([-carriage_len/2+carriage_thick*3, -beam/2, 0]) difference(){
        hull(){
            translate([-width/2,0,0]) cube([width,thick,screw_jut*2+base_thick], center=true);
            translate([-width,0,carriage_thick/2]) cube([width*2,thick,carriage_thick], center=true);
        }
        
        translate([-width,0,screw_jut]) rotate([0,90,0]) screw_hole_m3(height = wall*3);
    }
}

module belt_tensioner_clamp(carriage_len=60){
    thick = belt_thick;
    extra_thick = 2;
    base_thick = belt_width*4;
    screw_jut = base_thick+m3_cap_rad-2;
    
    height = screw_jut+m3_nut_rad-.5;
    
    clamp_len = 15;
    
    pitch = 2;
    
    belt_width = 2;
    
    rotate([0,0,-90]) 
    difference(){
        union(){
            hull(){
                translate([-wall/2,0,height/2]) cube([wall,thick+extra_thick,height], center=true);
                translate([-wall,0,base_thick/2]) cube([wall*2,thick+extra_thick,base_thick], center=true);
            }
            
            //meat for the belt clamp
            translate([-wall-clamp_len/2,0,base_thick/2]) cube([wall*2+clamp_len,thick+extra_thick,base_thick], center=true);
        }
        
        //nut hole
        #translate([-wall,-extra_thick,screw_jut]) rotate([0,-90,0]) nut_hole_m3(height = wall*3);
        
        //belt clamp
        translate([-wall*2-clamp_len/2,-extra_thick,base_thick/2]) 
        difference(){
            cube([clamp_len+1,thick+1,belt_width+slop], center=true);
            for(i=[.5:pitch:clamp_len+1]) translate([i-clamp_len/2,0,-belt_width/2-.2])
                cube([(pitch/2)*.8,thick+1, belt_width],center=true);
        }
    }
}

module belt_tensioner_double_clamp(carriage_len=60){
    thick = belt_thick+3;
    base_thick = belt_width*6;
    screw_jut = base_thick+m3_cap_rad-2;
    
    height = screw_jut+m3_nut_rad-.5;
    
    clamp_len = 18;
    
    pitch = 2;
    
    belt_width = 2;
    
    rotate([0,0,-90]) 
    difference(){
        union(){
            
            //meat for the belt clamp
            translate([0,0,base_thick/2]) cube([clamp_len,thick,base_thick], center=true);
        }
        
        //belt clamp
        translate([0,wall,base_thick/2]) 
        difference(){
            cube([clamp_len+1,thick+1,belt_width*2-slop*2], center=true);
            for(j=[-1,1])
            for(i=[pitch/2:pitch:clamp_len+1]) translate([i-clamp_len/2,0,(belt_width-slop)*j])
                cube([(pitch/2)*.8,thick+1, belt_width],center=true);
        }
    }
}

module belt_attach_holes(carriage_len = 60){
    wall = 6;
    thick = belt_thick+3;
    translate([0,-beam/2,0])
    for(i=[0:1]) mirror([i,0,0]) translate([carriage_len/2+.25,0,0]){
        hull(){
            #cube([belt_width*2,thick,belt_width], center=true);
            translate([-wall*1.5,0,wall]) cube([belt_width*2,thick,.1], center=true);
        }
        
        *cube([belt_width*2,thick,30], center=true);
        translate([-wall*1.5,0,15+wall]) cube([belt_width*2,thick,30], center=true);
        
        //cut out the backside a smidge
        *translate([25-wall*2-belt_width,0,0]) cube([50,thick,belt_width*2], center=true);
    }
}

module vertical_gantry_carriage(){
    wall=6;
    min_rad = 2;
    carriage_len = 60;
    carriage_spread = -15;
    
    hotend_drop = 15;
    
    mount_standoff = 2;
    
    idler_spread = 20;
    idler_jut = idler_extension_y+(m5_rad-idler_rad);
    
    rotate([0,0,90]) rotate([-90,0,0]) {
    %translate([0,0,-beam/2-1]) cube([120,beam*2,beam],center=true);
    difference(){
        union(){
            
            
            //guide wheels
            difference(){
                guide_wheel_helper(solid=1, span=2, gantry_length=carriage_len, gantry_spread = carriage_spread, cutout=false, spring_material=false, spring_compression=1);
                
                
                //round the front corners
                *for(i=[0,1]) mirror([i,0,0]) translate([cyclops_width/2+min_rad,beam/2+m5_rad+wall+1,0]) difference(){
                    translate([-min_rad-1,0,-wall]) cube([min_rad+1, min_rad+1, wall*5]);
                    cylinder(r=min_rad, h=wall*11, center=true);
                }
            }
            
            //mount for the attachments
            attachment_mount(solid=1, jut=mount_standoff, wall=wall);
            
            %translate([0,0,wall]) attachment_base();

            
        } //Holes below here
        
        //slots to loop the belt around & clamp in place
        belt_attach_holes();
        
        //attachment holes
        //mount for the attachments
        attachment_mount(solid=0, jut=mount_standoff, wall=wall+.1);
        
        //guide wheels
        //translate([0,0,mdf_wall-1]) rotate([0,0,180]) mirror([0,0,1])
        guide_wheel_helper(solid=-1, span=2, gantry_spread = carriage_spread, gantry_length=carriage_len, spring_compression=1);
        
        //belt path
        //todo
        
        //holes for the beam
        //for(i=[-beam/2, beam/2]) translate([0,i,-1]) cap_cylinder(r=m5_rad, h=20);
        
        //belt path
        //translate([0,-beam/2,0]) cube([100,belt_thick*2,wall], center=true);
        
        //flatten the bottom
        translate([0,0,-50]) cube([100,100,100],center=true);
        
    }
}
}

module vertical_gantry_carriage_rear(){
    wall=6;
    min_rad = 2;
    carriage_len = 60;
    carriage_spread = -15;
    
    idler_spread = idler_flange_rad*2+belt_width*2;
    idler_jut = idler_extension_y+(m5_rad-idler_rad);
    
    induction_rear = 4;
    idler_front = -18;
    induction_jut = 6;
    
    rotate([0,0,90]) rotate([-90,0,0]) {
    %translate([0,0,-beam/2-1]) cube([120,beam*2,beam],center=true);
    difference(){
        union(){
            //idler mounts
            *for(i=[-1,1]) translate([idler_front,0,0]) hull(){
                translate([idler_spread*i/2,-4,idler_extension_y+1]) rotate([90,0,0]) cylinder(r=m5_rad+wall/2+1, h=5, center=true);
                %translate([idler_spread*i/2,-6,idler_extension_y+1]) rotate([90,0,0]) cylinder(r=idler_flange_rad, h=8);
                
                translate([idler_spread*i/2,-4,1]) rotate([90,0,0]) cylinder(r=m5_rad+wall/2, h=2, center=true);                
            
                translate([idler_spread*i*0,20,-m5_rad]) rotate([90,0,0]) cylinder(r=m5_rad+wall, h=2, center=true);
            }
            
            //belt tensioner mount
            belt_tensioner_mount();
            
            //mount for the attachments
            attachment_mount(solid=1, jut=mount_standoff, wall=wall);
            
            //belt stretcher bumps
            *translate([idler_front,-10,idler_extension_y+10]) rotate([90,0,0]) belt_stretcher_2(mount_sep = stretcher_mount_sep);
            *translate([idler_front,-10,wall-.1]) belt_stretcher_2_bumps(mount_sep = stretcher_mount_sep, solid=1);
            
            //guide wheels
            guide_wheel_helper(solid=1, span=2, gantry_length=carriage_len, gantry_spread = carriage_spread, cutout=false, spring_material=false, spring_compression=1);

            //induction sensor mount
            *translate([induction_rear,15,15+induction_jut]) hull(){
                rotate([90,0,0]) rotate([0,0,90]) mirror([0,1,0]) mirror([0,0,1]) extruder_mount(solid=1, m_height=ind_height+6,  hotend_rad=ind_rad, wall=3);
                translate([0,18,-15-induction_jut]) rotate([90,0,0]) cylinder(r=ind_rad-2, h=ind_height+6+wall+4);
            }
            
        } //Holes below here
        
        *translate([idler_front,-10,wall-.1]) belt_stretcher_2_bumps(mount_sep = stretcher_mount_sep, solid = -1);
        
        //mount for the attachments
        attachment_mount(solid=0, jut=mount_standoff, wall=wall+.1);
        
        //induction sensor holes
        *translate([induction_rear,16,15+induction_jut]) rotate([90,0,0]) rotate([0,0,90]) mirror([0,1,0]) mirror([0,0,1]) extruder_mount(solid=0, m_height=ind_height+6,  hotend_rad=ind_rad, wall=3);
        
        //guide wheels
        //translate([0,0,mdf_wall-1]) rotate([0,0,180]) mirror([0,0,1])
        guide_wheel_helper(solid=-1, span=2, gantry_spread = carriage_spread, gantry_length=carriage_len, spring_compression=1);
        
        //idler screws
        *translate([idler_front,0,0]) translate([0,0,mdf_wall/2]) idler_mounts(solid=0, idler_extension_x = idler_spread/2, idler_extension_y = idler_jut, m5_rad=m5_rad-slop);
        
        //holes for the beam
        *for(i=[-1,1]) translate([idler_front,0,0]) translate([idler_spread*i/2,0,idler_extension_y+1]) rotate([90,0,0]) cylinder(r=m5_rad-slop, h=20, center=true);
        
        //flatten the bottom
        translate([0,0,-50]) cube([100,100,100],center=true);
        
        //slots to loop the belt around & clamp in place
        //these are used here to fix the belt in place, after tensioning it.
        //todo: better belt clamp.
        belt_attach_holes();
    }
}
}

module belt_stretcher_2_bumps(mount_sep = 20, solid = 1, height=10){
    for(i=[-1,1]) translate([0,mount_sep/2*i,0]){
        if(solid == 1){
            hull(){
                translate([0,0,-wall*2]) cylinder(r1=m3_rad+wall, r2=m3_rad+wall/2, h=height+wall*2);
                translate([0,10,0]) cylinder(r=m3_rad+wall/2, h=.1);
            }
        }
    
        if(solid == -1){
            translate([0,0,wall]) cap_cylinder(r=m3_rad+slop/2, h=height+10);
        }
    }
}

module belt_stretcher_3(mount_sep = 20){
    unit = m5_cap_rad*3;
    m5_lift = unit/2-m5_sq_nut_rad*sqrt(2)/2;
    difference(){
        union(){
            cube([unit, unit, unit], center=true);
        }
        
        //m5 screw hole
        translate([0,unit,m5_lift]) rotate([-90,0,0]) mirror([0,0,1]) screw_hole_m5(height = unit*2, cap=true);
        
        translate([0,-m5_cap_height,m5_lift]) rotate([-90,0,0]) rotate([0,0,45]) cylinder(r1=m5_sq_nut_rad, r2=m5_sq_nut_rad+1, h=unit, $fn=4);
        
        hull() translate([0,-m5_cap_height,m5_lift]) {
             rotate([-90,0,0]) rotate([0,0,45]) cylinder(r1=8.7/2, r2 = 9.7/2, h=unit);
             *translate([0,0,unit]) rotate([-90,0,0]) cylinder(r=m3_cap_rad, h=unit);
        }
        
        //m3 screw hole
        translate([0,unit/2-m3_cap_rad,0]){
            mirror([0,0,1]) screw_hole_m3(height = unit/2-2-.25, onion=true);
            translate([0,0,-unit/2]) rotate([0,0,45]) cylinder(r=m3_sq_nut_rad, h=4, center=true, $fn=4);
        }
    }
}

module belt_stretcher_2(mount_sep = 20){
    difference(){
        union(){
            cylinder(r=m5_rad, h=mount_sep+m3_rad*2+wall*2, center=true);
        }
        
        for(i=[-1,1]) translate([0,0,mount_sep/2*i]){
            //mounting screws
            rotate([90,0,0]) cylinder(r=m3_rad+slop/2, h=m5_rad*3, center=true);
            
            //tension nuts
            translate([0,-1,0]) rotate([90,0,0]) rotate([0,0,45]) cylinder(r=m3_sq_nut_rad, h=wall, $fn=4);
            
        }
        
        //flatten the front
        translate([0,50+m5_rad-.75,0]) cube([100,100,100], center=true);
    }
}


module idler_mounts(solid=1){
    wall=5;
    bump_height = 2;
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
                hull(){
                    cylinder(r=idler_flange_rad+1, h=idler_thick+bump_height*2, center=true);
                    translate([20,0,0]) cylinder(r=idler_flange_rad+1, h=idler_thick+bump_height*2, center=true);
                }
                
                //belt paths
                for(j=[0,-90]) rotate([0,0,j]) translate([0,-idler_rad,0]) 
                    %cube([100, belt_width*1.5, belt_thick], center=true);
                
                //bumps
                for(i=[0,1]) mirror([0,0,i]) translate([0,0,idler_thick/2]) cylinder(r1=m5_rad+1, r2=idler_rad, h=bump_height+.1);
                
            }
        
            translate([idler_extension_x,0,idler_extension_y]) rotate([90,0,0]) cylinder(r=m5_rad, h=idler_thick*3, center=true);
            
            //nut and screw flats
            for(i=[0,1]) mirror([0,i,0]) translate([idler_extension_x,-idler_thick/2-wall/2-bump_height,idler_extension_y]) rotate([90,0,0]) cylinder(r=m5_cap_rad, h=idler_thick*3);
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
            //translate([0,0,-wall+1]) cylinder(r2=m5_nut_rad, r1=m5_nut_rad+slop, h=wall, $fn=6);
            cylinder(r=m5_cap_rad, h=wall+1);
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

module chimaera_top_holes(){
    tube_rad = 4;
    wall=5;
    %cube([30,28,50], center=true);
    
    //center rear mounting hole
    translate([0,4.5,-wall/2-1]) cylinder(r=m3_rad, h=wall+2);
    //translate([0,4.5,0]) cylinder(r=m3_cap_rad, h=wall+2);
    
    //front left and right holes
    for(i=[-1,1]) translate([i*8.5,4.5-12,-wall/2-1]) {
        cylinder(r=m3_rad, h=wall+2);
        //translate([0,0,wall/2+1]) cylinder(r=m3_cap_rad, h=wall+2);
    }
    
    //tube holes
    for(i=[-1,1]) translate([i*9,1.5,-wall/2-1]) {
        cylinder(r=tube_rad+slop, h=wall+2);
        translate([0,0,2]) cylinder(r1=tube_rad, r2=tube_rad*2, h=wall+2);
    }
}

module hotend_mount(){
    gantry_length = 50;
    wall=5;
    mount_x = gantry_length+m5_rad*2+wall*2;
    mount_y = 32+10;
    
    cutout = 12;
    
    y_offset = 5;
    
    
    translate([0,0,wall/2+1+5]) 
    difference(){
        translate([0,beam/2+1,0]) union(){
            hull(){
                translate([0,mount_y/2-cutout/2,0]) cube([mount_x,mount_y-cutout,wall],center=true);
                
                for(i=[17,-10]) translate([i,mount_y-1, 0]) scale([1,.5,1]) rotate([0,0,45]) cylinder(r=4, h =wall, center=true, $fn=4);
            }
            
            //pull in the other screwholes
            for(i=[0:1]) mirror([i,0,0]) hull(){
                translate([gantry_length/2,-28,0]) cylinder(r=m5_cap_rad+2, h=wall, center=true);
                translate([gantry_length/2,5,0]) cylinder(r=m5_cap_rad+2, h=wall, center=true);
            }
        }
        
        //holes for the hotend mount - this is the chimera version
        translate([y_offset,beam/2+4+mount_y/2,0]) rotate([0,0,-90]) chimaera_top_holes();
        
        //holes for mounting
        belt_left_screwholes(solid=0, screw_sep = gantry_length, cap_rad = 5);
        //translate([0,0,-wall/2]) mirror([0,1,0])
        guide_wheel_helper(solid=-1,gantry_length=gantry_length, cutout=false, cap_rad=5);
        
        //some zip tie holes
        for(i=[17,-10]) translate([i,beam/2+mount_y-2, 0]) scale([1,.5,1]) rotate([0,0,45]) cylinder(r=4, h =wall*5, center=true, $fn=4);
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
            
            //hotend mount
            %hotend_mount();
            
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

module guide_wheel_helper(solid=0, span=1, cutout=true, gantry_spread = 0, cap_rad = 0, eccentric=false, spring_inset = 2, spring_compression=.5, spring_material=true){
    min_rad=3;
    wall=carriage_thick;
    
    eccentric_offset = (eccentric==true)?.25:0;
    spring_offset = (eccentric==false)?spring_inset:0;
    
    //total distance between the wheels
    wheel_vert_sep = span*beam + wheel_inner_rad*2 - eccentric_offset - spring_compression;
    spring_vert_sep = wheel_vert_sep/2 - m5_cap_rad-3.5;
    
    if(solid >= 0){
        //sketch in the wheels
        %for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
            translate([0,-wheel_vert_sep/2,-beam/2]) wheel();
            translate([i*gantry_spread/2,wheel_vert_sep/2,-beam/2]) wheel();
        }
        
        //main body
        hull(){
            for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
                translate([0,-wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall);
                translate([i*gantry_spread/2,wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall);
            }
        }
        
        //the rounded corners
        for(i=[-1,1]) translate([i*gantry_length/2,0,0]){
            //top
            translate([0,-wheel_vert_sep/2,0]) cylinder(r=wheel_inner_rad, h=wall);
            
            //bottom
            translate([i*gantry_spread/2,wheel_vert_sep/2,0]) cylinder(r=wheel_inner_rad, h=wall);
            
            //extra material for the springs
            if(eccentric == false && spring_material == true){
                intersection(){
                    union(){
                        translate([i*(gantry_spread/2+spring_inset),spring_vert_sep,0]) scale([7,1.25,1]) rotate([0,0,30*(i-1)]) cylinder(r=eccentric_rad, h=wall*1.6, $fn=3);
                        translate([i*(gantry_spread/2+spring_inset),spring_vert_sep,0]) scale([7,1.25,1]) rotate([0,0,30*(i-1)]) cylinder(r1=eccentric_rad+2, r2=eccentric_rad, h=wall*1.6, $fn=3);
                    }
                    
                    //intersect with the base
                    hull() {
                        translate([i*gantry_spread/2,wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall*3);
                        translate([0,-wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall*3);
                        
                        translate([-i*gantry_length/2,wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall*3);
                        translate([-i*gantry_length/2,-wheel_vert_sep/2,0]) cylinder(r=wall/2, h=wall*3);
                    }
                }
            }
        }
    }
    
    if(solid <= 0){
        for(i=[-1,1]) translate([i*gantry_length/2,0,-.1]){
            //upper wheels
            translate([0,-wheel_vert_sep/2,0]) cylinder(r=m5_rad, h=wall+1);
            translate([0,-wheel_vert_sep/2,wall+.1]) cylinder(r=m5_cap_rad+.25, h=wall+1);
            
            //lower wheels
            translate([i*gantry_spread/2,wheel_vert_sep/2,0]) cylinder(r=m5_rad, h=wall+1);
            translate([i*gantry_spread/2,wheel_vert_sep/2,wall+.1]) cylinder(r=m5_cap_rad+.25, h=wall+1);
            
            //a little plastic spring
            if(eccentric == false){
                translate([i*(gantry_spread/2+spring_inset),spring_vert_sep,0]) scale([6,.5,1]) rotate([0,0,30*(i-1)]) cylinder(r=eccentric_rad, h=wall*2+1, $fn=3);
            }
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
			translate([0,0,-.05]) cylinder(r=hotend_rad/cos(180/18)+.1, h=m_height*3, $fn=36, center=true);
            //flare the underside
            translate([0,0,-25]) cylinder(r1=hotend_rad/cos(180/18)+2 , r2=hotend_rad/cos(180/18)+.1, h=25, $fn=36);
            
            //flare the topside, too, because why not
            translate([0,0,m_height-1.5]) cylinder(r2=hotend_rad/cos(180/18)+2 , r1=hotend_rad/cos(180/18)+.1, h=25, $fn=36);

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