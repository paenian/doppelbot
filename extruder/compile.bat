openscad bed.scad -D part=0 -o dxf/bed_double_end_top.dxf >/dev/null 2>/dev/null &
openscad bed.scad -D part=1 -o dxf/bed_inside_support.dxf >/dev/null 2>/dev/null &
openscad bed.scad -D part=2 -o dxf/bed_end_support.dxf >/dev/null 2>/dev/null &
openscad bed.scad -D part=3 -o dxf/bed_brace_top.dxf >/dev/null 2>/dev/null &
openscad bed.scad -D part=4 -o stl/bed_clamp.stl >/dev/null 2>/dev/null &
openscad bed.scad -D part=5 -o dxf/bed_single_end_top.dxf >/dev/null 2>/dev/null &
openscad bed.scad -D part=6 -o dxf/bed_long_clamp.stl >/dev/null 2>/dev/null &
