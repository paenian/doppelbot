openscad camera_enclosure.scad -D part=0 -D facets=180 -o body.stl &
openscad camera_enclosure.scad -D part=1 -D facets=180 -o body_cap.stl &
openscad camera_enclosure.scad -D part=2 -D facets=180 -o clamp.stl &
openscad camera_enclosure.scad -D part=2 -D lift=6.35 -D facets=180 -o clamp_25.stl &
openscad camera_enclosure.scad -D part=2 -D lift=12.7 -D facets=180 -o clamp_50.stl &

openscad camera_enclosure.scad -D part=2 -D angle=30 -D vert_scale=2 -D facets=180 -o clamp_a30.stl &
openscad camera_enclosure.scad -D part=2 -D angle=45 -D vert_scale=2 -D facets=180 -o clamp_a45.stl &
openscad camera_enclosure.scad -D part=2 -D angle=60 -D vert_scale=2 -D facets=180 -o clamp_a60.stl &
