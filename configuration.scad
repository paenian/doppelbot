wall = 5;

screw_slop = .2;
slop = .2;

//these can't change - measured values.
beam = 20;
bed_screw_sep = 209;
bed = 214;

layer_height=.15;


//frame lengths - may be dependent on wall above.
long_frame = 500;
short_frame = 250;  //leaves 25+wall on either side of bed; printer is short_frame+wall+wall+rail+rail = 300mm deep by default.
height_frame = 250;
echo("BOM: 2, v-rail, 2020", long_frame, "Frame");
echo("BOM: 2, reg rail, 2020", long_frame, "Frame");  //could be v-rail too, check price
echo("BOM: 4, reg rail, 2020", short_frame, "Frame");
echo("BOM: 4, reg rail, 2020", height_frame, "Frame");

//gantry - might want to make it bigger
echo("BOM: 1, v-rail, 2020", short_frame, "Gantry");

//bed lengths
long_bed = bed_screw_sep+bed_screw_sep+(bed-bed_screw_sep)+beam;  //should allow center screws in the short_bed_beams to line up, leave a nice rim around the bed
short_bed = bed_screw_sep-wall-wall-beam/2-beam/2;  //the screwholes on the bed should line up with the long_bed rails.
echo("BOM: 2, reg rail, 2020", long_bed, "Bed mount");
echo("BOM: 3, reg rail, 2020", short_bed, "Bed mount");  //might want more than three - to hold insulation well.

//standard screw variables
m3_nut_rad = 6.01/2+slop;
m3_nut_height = 2.4;
m3_rad = 3/2+slop;
m3_cap_rad = 3.25;
m3_cap_height = 2;

m4_nut_rad = 7.66/2+slop;
m4_nut_height = 3.2;
m4_rad = 4/2+slop;
m4_cap_rad = 7/2+slop;
m4_cap_height = 2.5;

m5_nut_rad = 8.79/2+slop;
m5_nut_height = 4.7;
m5_rad = 5/2+slop;
m5_cap_rad = 8/2+slop;
m5_cap_height = 3;


//makes all the holes have lots of segments
$fs=.5;
$fa=.1;