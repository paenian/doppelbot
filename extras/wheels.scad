slop = .2;

m5_nut_rad = 8.79/2+slop;
m5_nut_height = 4.7;
m5_rad = 5/2+slop;
m5_dia = 5+slop;
m5_cap_rad = 9/2+slop;
m5_washer_rad = 11/2;

wall = 6;

//%cylinder(r=m8_washer_rad,h=20);
//%rotate([90,0,0])translate([-34.5,13,-2]) cylinder(r=m8_rad, h=30, center=true);

//the wheel
translate([-31,T/2,9]) rotate([90,0,0]) //this puts the wheel in the carrier
!wheel();

//the carrier
//rotated for printing
difference(){
	translate([0,0,17.5]) rotate([0,-12,0])
	carrier();
	translate([0,0,-50]) cube([100,100,100], center=true);
    
    translate([0,0,-18]) rotate([0,-24,0])
    translate([0,0,100]) cube([100,100,100], center=true);
}

module carrier(){
    bump_height = 1.5;
    
	thickness = wall+wall+bump_height*2+T;
	difference(){
		union(){
            //extra base clearance
            translate([6.25,0,0]) cube([6.5, 19.5, 39.5], center=true);
            
			hull(){
				cube([wall, thickness, 40], center=true);
				
				translate([-D/2-wall,0,0]) rotate([90,0,0]) cylinder(r=m5_washer_rad+wall, h=thickness, center=true);
			}
		}

		//mount the wheel
		translate([-D/2-wall,0,0]) rotate([-90,0,0]) {
			rotate([0,0,25]) cap_cylinder(r=m5_rad, h=50, center=true);
			difference(){
				scale([1,1.25,1]) intersection(){
					cylinder(r=D/2+wall,h=T+2,center=true,$fn=100);
					scale([1,1,.5]) sphere(r=D/2+wall, $fn=90);
				}
                
				//bumps to hold the wheel centered
				for(i=[0,1]) mirror([0,0,i]) translate([0,0,-T/2-1.1]) cylinder(r1=m5_washer_rad+1, r2=m5_washer_rad-1, h=bump_height);
			}
		}
		
		//bolt indent
		translate([-D/2-wall,0,0])rotate([-90,0,0]) translate([0,0,-T/2-1.05-wall]) cylinder(r=m5_washer_rad+.25, h=2);
		//nut indent
		mirror([0,1,0]) translate([-D/2-wall,0,0])rotate([-90,0,0]) translate([0,0,-T/2-1.05-wall]) cylinder(r=m5_nut_rad+.1, h=2, $fn=6);

		//mount the carrier
		for(i=[-10,10]) translate([0,0,i]) rotate([0,90,0]){
			rotate([0,0,-90]) cap_cylinder(r=m5_rad, h=30, center=true);
			translate([0,0,-30]) rotate([0,0,-90]) cap_cylinder(r=m5_cap_rad+.25, h=35);
		}
	}
}

// outer diameter of ring
D=65;
// thickness
T=18;
// clearance
tol=.3;
number_of_planets=8;
number_of_teeth_on_planets=6;
approximate_number_of_teeth_on_sun=13;
// pressure angle
P=40;//[30:60]
// number of teeth to twist across
nTwist=1;
// width of center hole
w=m5_dia+1  ;

DR=0.5*1;// maximum depth ratio of teeth

m=round(number_of_planets);
np=round(number_of_teeth_on_planets);
ns1=approximate_number_of_teeth_on_sun;
k1=round(2/m*(ns1+np));
k= k1*m%2!=0 ? k1+1 : k1;
ns=k*m/2-np;
echo(ns);
nr=ns+2*np;
pitchD=0.9*D/(1+min(PI/(2*nr*tan(P)),PI*DR/nr));
pitch=pitchD*PI/nr;
echo(pitch);
helix_angle=atan(2*nTwist*pitch/T);
echo(helix_angle);

phi=$t*360/m;
module wheel(){
	translate([0,0,T/2]){
		difference(){
			intersection(){
				cylinder(r=D/2+1,h=T,center=true,$fn=100);
				scale([1,1,1.25]) sphere(r=D/2+1, $fn=90);
			}
			render() herringbone(nr,pitch,P,DR,-tol,helix_angle,T+0.2);
		}
		rotate([0,0,(np+1)*180/ns+phi*(ns+np)*2/ns])
		difference(){
			mirror([0,1,0])
				render() herringbone(ns,pitch,P,DR,tol,helix_angle,T);
			cylinder(r=w/2,h=T+1,center=true);
		}
		for(i=[1:m])rotate([0,0,i*360/m+phi])translate([pitchD/2*(ns+np)/nr,0,0])
			render() rotate([0,0,i*ns/m*360/np-phi*(ns+np)/np-phi])
				herringbone(np,pitch,P,DR,tol,helix_angle,T);
	}
}

module rack(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	helix_angle=0,
	clearance=0,
	gear_thickness=5,
	flat=false){
addendum=circular_pitch/(4*tan(pressure_angle));

flat_extrude(h=gear_thickness,flat=flat)translate([0,-clearance*cos(pressure_angle)/2])
	union(){
		translate([0,-0.5-addendum])square([number_of_teeth*circular_pitch,1],center=true);
		for(i=[1:number_of_teeth])
			translate([circular_pitch*(i-number_of_teeth/2-0.5),0])
			polygon(points=[[-circular_pitch/2,-addendum],[circular_pitch/2,-addendum],[0,addendum]]);
	}
}

module herringbone(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5){
union(){
	gear(number_of_teeth,
		circular_pitch,
		pressure_angle,
		depth_ratio,
		clearance,
		helix_angle,
		gear_thickness/2);
	mirror([0,0,1])
		gear(number_of_teeth,
			circular_pitch,
			pressure_angle,
			depth_ratio,
			clearance,
			helix_angle,
			gear_thickness/2);
}}

module gear (
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5,
	flat=false){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
twist=tan(helix_angle)*gear_thickness/pitch_radius*180/PI;

flat_extrude(h=gear_thickness,twist=twist,flat=flat)
	gear2D (
		number_of_teeth,
		circular_pitch,
		pressure_angle,
		depth_ratio,
		clearance);
}

module flat_extrude(h,twist,flat){
	if(flat==false)
		linear_extrude(height=h,twist=twist,slices=twist/6)child(0);
	else
		child(0);
}

module gear2D (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
	clearance){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
base_radius = pitch_radius*cos(pressure_angle);
depth=circular_pitch/(2*tan(pressure_angle));
outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
root_radius1 = pitch_radius-depth/2-clearance/2;
root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
half_thick_angle = 90/number_of_teeth - backlash_angle/2;
pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
min_radius = max (base_radius,root_radius);

intersection(){
	rotate(90/number_of_teeth)
		circle($fn=number_of_teeth*3,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
	union(){
		rotate(90/number_of_teeth)
			circle($fn=number_of_teeth*2,r=max(root_radius,pitch_radius-depth_ratio*circular_pitch/2-clearance/2));
		for (i = [1:number_of_teeth])rotate(i*360/number_of_teeth){
			halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);		
			mirror([0,1])halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);
		}
	}
}}

module halftooth (
	pitch_angle,
	base_radius,
	min_radius,
	outer_radius,
	half_thick_angle){
index=[0,1,2,3,4,5];
start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
stop_angle = involute_intersect_angle (base_radius, outer_radius);
angle=index*(stop_angle-start_angle)/index[len(index)-1];
p=[[0,0],
	involute(base_radius,angle[0]+start_angle),
	involute(base_radius,angle[1]+start_angle),
	involute(base_radius,angle[2]+start_angle),
	involute(base_radius,angle[3]+start_angle),
	involute(base_radius,angle[4]+start_angle),
	involute(base_radius,angle[5]+start_angle)];

difference(){
	rotate(-pitch_angle-half_thick_angle)polygon(points=p);
	square(2*outer_radius);
}}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];

module cap_cylinder(r=1, h=1, center=false){
	render() union() {
		cylinder(r=r, h=h, center=center);
		intersection(){
			rotate([0,0,22.5]) cylinder(r=r/cos(180/8), h=h, $fn=8, center=center);
			translate([0,-r/cos(180/4),0]) rotate([0,0,0]) cylinder(r=r/cos(180/4), h=h, $fn=4, center=center);
		}
	}
}
