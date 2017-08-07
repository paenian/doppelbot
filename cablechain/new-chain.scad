// Remix the cable chain http://www.thingiverse.com/thing:11978 to
// remove the fixed bar across the top and replace it with slots
// where a separate springy piece can be added or removed to get
// to the cables.

// Make a trapezoid shaped slot for spring to click into.
//
module spring_slot(thick, high, wide) {
   rotate([0,0,90])
      linear_extrude(height=high, scale=[0.6,1.0])
         square([wide,thick], center=true);
}

// Make a springy clip to go in the 14.66mm wide gap in the chain pieces.
// stick spring_slot shaped trapezoids on either end to fit into the
// corresponding slots in the chain links.
//
module spring_clip() {
   gapsize=14.66;       // size of gap across chain link
   smallgap=gapsize-0.26; // slightly smaller size to leave slop
   travel=1.5+1.5+2;    // length of pins plus some slop
   oneslot=travel/3;    // I'm going to make 3 slots in the spring
   overlap=2;           // overlap the cylinders by this much
   cyldia=(smallgap+2*overlap)/3; // diameter of cylinders
   clipwidth=11;        // don't make the clips too wide to run into each other
   
   translate([8.83, 5, 0]) // move it into position x,y plane
   difference() {
      union() {
         // Start with a couple of trapezoid shaped pins to fit in the
         // slots in the chain links.
         difference() {
            // One long pin
            spring_slot(gapsize+1.5+1.5,2,2);
            // subtract off middle leaving 2 pins at either end.
            translate([-14.3/2, -14.3/2, -1])
               cube([14.3,14.3,4]);
         }

         // draw two cylinders at top and bottom right and one at middle left
         translate([(smallgap/2)-cyldia/2,(clipwidth/2)-cyldia/2,0])
            cylinder(h=2,r=cyldia/2,$fn=64);
         translate([-((smallgap/2)-cyldia/2),(clipwidth/2)-cyldia/2,0])
            cylinder(h=2,r=cyldia/2,$fn=64);
         translate([0,-((clipwidth/2)-cyldia/2),0])
            cylinder(h=2,r=cyldia/2,$fn=64);

         // Fill in the rectangle in the center of clip
         translate([-smallgap/2, -(clipwidth-cyldia)/2, 0])
            cube([smallgap,clipwidth-cyldia,2]);
      }
      // Subtract off smaller cylinders (springiness comes from these)
      translate([(smallgap/2)-cyldia/2,(clipwidth/2)-cyldia/2,-1])
         cylinder(h=4,r=(cyldia/2)-3*0.48,$fn=64);
      translate([-((smallgap/2)-cyldia/2),(clipwidth/2)-cyldia/2,-1])
         cylinder(h=4,r=(cyldia/2)-3*0.48,$fn=64);
      translate([0,-((clipwidth/2)-cyldia/2),-1])
         cylinder(h=4,r=(cyldia/2)-3*0.48,$fn=64);
      // Subtract off slots
      translate([-oneslot/2, -(2+clipwidth-cyldia)/2, -1])
         cube([oneslot,2+clipwidth-cyldia,4]);
      translate([(-oneslot/2)+(smallgap/2)-cyldia/2, -(2+clipwidth-cyldia)/2, -1])
         cube([oneslot,2+clipwidth-cyldia,4]);
      translate([(-oneslot/2)-((smallgap/2)-cyldia/2), -(2+clipwidth-cyldia)/2, -1])
         cube([oneslot,2+clipwidth-cyldia,4]);
   }
}

// Extract one end piece from the stl and translate to origin.
//
// The top bar is 11.38mm up, 1.89mm high
//             is 10.34mm to 13.52mm in Y direction (3.18mm thick)
//             is 4.78mm to 17.65mm in X direction (12.87mm long)
//
module extract_end1() {
   translate([23.78, 17.85, -0.01])
      difference() {
         import("CableChainEnds_fixed.stl");
         translate([0,-250,-1])
            cube([500,500,500]);
      }
}

// Fiddly things go wrong when I try to do some operations with the results
// of extract_end1(), so I run it just to generate an stl file, then feed
// that stl to the online netfabb repair service, and use this module instead.
//
module end1() {
   import("end1_fixed.stl");
}

// Extract other end piece from the stl.
//
// The top bar is 11.38mm up, 1.89mm high
//             is 12.75mm to 15.93mm in Y direction (3.18mm thick)
//             is 4.78mm to 17.65mm in X direction (12.87mm long)
//
module extract_end2() {
   translate([22.43, 38.81, 0])
      rotate([0,0,180])
         translate([-1.35, 19.41, 0])
            difference() {
               import("CableChainEnds_fixed.stl");
               translate([-500,-250,-1])
                  cube([500,500,500]);
            }
}

// Similar to end1(), but for part at other end.
//
module end2() {
   import("end2_fixed.stl");
}

// Translate one chain link to origin. The bar in this is at same position
// relative to origin as the bar in end1().
//
nobar_chain();
module chain() {
   translate([11.22, 13.13, 0])
      import("CableChain.stl");
}

// end1() with the top bar removed and slots for spring clip added
// Also need to extend the thick shoulder a bit to make it thick
// enough to allow me to subtract off the spring slot and not leave
// spots too think to print well.
//
module nobar_end1() {
   difference() {
      union() {
         end1();
         // slice of the thick shoulder shifted over and unioned in
         // to make the shoulder even thicker.
         translate([0,2,0])
            intersection() {
               end1();
                  translate([-5,11.5,-1])
                     cube([50,2,50]);
            }
      }
      // Subtract off the bar at the top
      translate([4.78, 10.34-1, 8])
         cube([12.87,10,50]);
      translate([-1,12.99,11.495])
         spring_slot(50,2,2.2);
   }
}

// end2() with the top bar removed and slots for spring clip added
// Same shoulder extension needed here.
//
module nobar_end2() {
   difference() {
      union() {
         end2();
         translate([0,2,0])
            intersection() {
               end2();
                  translate([-5,13.7,-1])
                     cube([50,2,50]);
            }
      }
      // Subtract off top bar
      translate([4.78, 12.75-1, 8])
         cube([12.87,10.18,50]);
      // subtract off slot for spring
      translate([-1,15.0,11.495])
         spring_slot(50,2,2.2);
   }
}

// chain() with the top bar removed and slots for spring clip added
//
module nobar_chain() {
   difference() {
      chain();
      translate([4.78, 10.34-1, 8])
         cube([12.87,5.18,50]);
      translate([-1,12.0,11.495])
         spring_slot(50,2,2.2);
   }
}

// Print 4 chain pieces rotated in 4 different directions
//
module nobar_four() {
   translate([26.76, 26.76, 0])
      union() {
         translate([0.5,0.5,0])
            nobar_chain();
         rotate([0,0,90])
            translate([0.5,0.5,0])
               nobar_chain();
         rotate([0,0,180])
            translate([0.5,0.5,0])
               nobar_chain();
         rotate([0,0,270])
            translate([0.5,0.5,0])
               nobar_chain();
      }
}

// Print 4 spring clips
module spring_four() {
   translate([18.16, 18.16, 0])
      union() {
         translate([0.5,0.5,0])
            spring_clip();
         rotate([0,0,90])
            translate([0.5,0.5,0])
               spring_clip();
         rotate([0,0,180])
            translate([0.5,0.5,0])
               spring_clip();
         rotate([0,0,270])
            translate([0.5,0.5,0])
               spring_clip();
      }
}

// Print 16 chain pieces
//
module nobar_sixteen() {
   union() {
      translate([0.5,0.5,0])
         nobar_four();
      rotate([0,0,90])
         translate([0.5,0.5,0])
            nobar_four();
      rotate([0,0,180])
         translate([0.5,0.5,0])
            nobar_four();
      rotate([0,0,270])
         translate([0.5,0.5,0])
            nobar_four();
   }
}

// Print 16 spring clips
//
module spring_sixteen() {
   union() {
      translate([0.5,0.5,0])
         spring_four();
      rotate([0,0,90])
         translate([0.5,0.5,0])
            spring_four();
      rotate([0,0,180])
         translate([0.5,0.5,0])
            spring_four();
      rotate([0,0,270])
         translate([0.5,0.5,0])
            spring_four();
   }
}

// Print both end pieces and clips for each one.
//
module end_two() {
   union() {
      translate([0.5,0.5,0])
         nobar_end1();
      translate([0,40,0])
         rotate([0,0,180])
            translate([0.5,0.5,0])
               nobar_end2();
      rotate([0,0,-90])
         translate([0.5,0.5,0])
            spring_clip();
      rotate([0,0,-180])
         translate([0.5,0.5,0])
            spring_clip();
   }
}
