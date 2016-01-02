wall=3;

top_w = 33;
bot_w = 40;

sponge_depth = 70;

depth = sponge_depth+wall*2;
height = 70;

sponge_thick = 25;
handles_thick = 25;

angle = 15;
flare = 10;

top_width = wall*4 + top_w+sponge_thick+handles_thick+flare*2;

bot_width = wall*4 + bot_w + sponge_thick + handles_thick + tan(angle)*height*2;

//sponge_holder();

sponge_holder_single(angle=5, handle=true);

//hangle sponge, with tab for magnetic attachment.
module sponge_holder_single(handle = false){
    top_width = wall*2 + top_w+handles_thick+flare*2-5;
    bot_width = top_width+height*tan(angle);
    
    mag_rad = 10;
    
    difference(){
        union(){
            translate([0,-depth/2,0]) hull(){
                translate([mag_rad+wall,mag_rad,0]) minkowski(){
                    cube([bot_width-mag_rad*2-wall*2, depth-mag_rad*2, .8]);
                    cylinder(r=mag_rad+wall, h=.1);
                }
                
                translate([mag_rad+wall,mag_rad,height-1]) minkowski(){
                    translate([0,0,.1]) cube([top_width-mag_rad*2-wall*2, depth-mag_rad*2, .8]);
                    cylinder(r=mag_rad+wall, h=.1);
                }
            }
        }
        
        //sink hollow
        translate([top_w/2,0,0]) hull(){
            cube([bot_w, depth+10, 1], center=true);
            translate([-wall/2,0,height-wall-wall-wall]) minkowski(){
                cube([top_w, depth+10, 1], center=true);
                sphere(r=wall, $fn=30);
            }
        }
        
        //mag pits
        translate([12.5,0,height-wall*2+2]) cylinder(r1=7, r2=8, h=wall*2);
        translate([17.5,25,height-wall*2+2]) cylinder(r1=7, r2=8, h=wall*2);
        translate([17.5,-25,height-wall*2+2]) cylinder(r1=7, r2=8, h=wall*2);
        
        //sponge/handle slot
        translate([top_w+sponge_thick/2+flare/2+2,0,height+wall*2.5+wall]) rotate([0,-angle,0]) translate([0,0,-height]) minkowski(){
            hull(){
                rotate([0,-15,0]) cube([handles_thick-wall*2, sponge_depth-wall*2, .1],center=true);
                translate([flare/2,0,height-wall]) cube([sponge_thick-wall*2-4+flare, sponge_depth-wall*2-4, .1],center=true);
            }
            sphere(r=wall+2);
        }
        
        //handle clearance
        translate([top_w+sponge_thick/2+flare/2,0,25/2*1.5+wall+23]) 
        scale([1.25,1,1]) hull(){
            sphere(r=handles_thick/2+wall);
            translate([0,0,40]) sphere(r=handles_thick);
        }
        
        //drainage
        for(i=[1]) mirror([i,0,0])
        difference(){
            union(){
            translate([-bot_width-bot_w-wall,-depth/2+wall,-.1]) rotate([0,2,0]) 
            for(i=[0:4]){
                translate([0,i*15,0]) cube([bot_width,10,height*2]);
            }
            
            //front and back holes
            translate([-top_w-sponge_thick/2-flare/2,0,height+wall*3]) rotate([0,angle,0]) translate([0,0,-height]) minkowski(){
            hull(){
                rotate([0,15,0]) cube([sponge_thick-wall*2, sponge_depth+wall*6, .1],center=true);
                translate([-flare/4,0,height-wall*6]) rotate([0,5,0]) cube([sponge_thick-wall*2+flare/2, sponge_depth+wall*6, .1],center=true);
            }
            sphere(r=wall);
        }
        }
            
            //base stiffener
            translate([-bot_width+wall,0,wall/2]) cube([wall*4, depth, wall], center=true);
            //mid stiffener
            translate([-bot_width-wall,0,wall/2]) rotate([0,10,0]) translate([0,0,height/2]) cube([wall*6, depth, wall], center=true);
            //top stiffener
            translate([-bot_width-wall,0,wall/2]) rotate([0,10,0]) translate([0,0,height]) cube([wall*2, depth, wall*2], center=true);
        }
        
    }
}

//normal sponge on one side, handle sponge on the other.
module sponge_holder(){
    difference(){
        union(){
            hull(){
                translate([0,0,.5]) cube([bot_width, depth, 1], center=true);
                translate([0,0,height-.5]) cube([top_width, depth, 1], center=true);
            }
        }
        
        //sink hollow
        hull(){
            cube([bot_w, depth+1, 1], center=true);
            translate([0,0,height-wall-wall]) minkowski(){
                cube([top_w, depth+1, 1], center=true);
                sphere(r=wall/2, $fn=30);
            }
        }
        
        //sponge slot
        translate([-31,0,height+wall*2]) rotate([0,angle,0]) translate([0,0,-height]) minkowski(){
            hull(){
                cube([sponge_thick-wall*2, sponge_depth-wall*2, .1],center=true);
                translate([-flare/2,0,height-wall]) cube([sponge_thick-wall*2+flare, sponge_depth-wall*2, .1],center=true);
            }
            sphere(r=wall);
        }
        
        //handle slot
        translate([31,0,height+wall*2]) rotate([0,-angle,0]) translate([0,0,-height]) minkowski(){
            hull(){
                cube([handles_thick-wall*2, sponge_depth-wall*2, .1],center=true);
                translate([flare/2,0,height-wall]) cube([sponge_thick-wall*2+flare, sponge_depth-wall*2, .1],center=true);
            }
            sphere(r=wall);
        }
        
        //handle clearance
        translate([32,0,45/2*1.5+wall+23]) 
        hull(){
            rotate([0,90-angle,0]) scale([1.5,1,1]) cylinder(r=40/2,h=50);
            translate([0,0,40]) rotate([0,90-angle,0]) scale([1.5,1,1]) cylinder(r=55/2,h=50);
        }
        
        //drainage
        for(i=[0,1]) mirror([i,0,0])
        difference(){
            union(){
            translate([-bot_width-bot_w/2-wall,-depth/2+wall,-.1]) rotate([0,2,0]) 
            for(i=[0:10]){
                translate([0,i*15,0]) cube([bot_width,10,height*2]);
            }
            
            //front and back holes
            translate([-30,0,height+wall*2]) rotate([0,angle,0]) translate([0,0,-height]) minkowski(){
            hull(){
                cube([sponge_thick-wall*2, sponge_depth+wall*2, .1],center=true);
                translate([-flare/4,0,height-wall*6]) cube([sponge_thick-wall*2+flare/2, sponge_depth+wall*2, .1],center=true);
            }
            sphere(r=wall);
        }
        }
            
            //base stiffener
            translate([-bot_width/2+wall/2,0,wall/2]) cube([wall*2, depth, wall], center=true);
            //mid stiffener
            translate([-bot_width/2+wall/2,0,wall/2]) rotate([0,10,0]) translate([0,0,height/2]) cube([wall*2, depth, wall], center=true);
            //top stiffener
            translate([-bot_width/2+wall/2,0,wall/2]) rotate([0,10,0]) translate([0,0,height]) cube([wall*2, depth, wall*2], center=true);
        }
        
    }
}