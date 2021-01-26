difference() {
    include <speaker_cabinet.scad>;
    translate([-1,-1,12]) {
        cube(200);
    };
}

translate([0,15,6]) {
    cube([86,9.3,6]);
}