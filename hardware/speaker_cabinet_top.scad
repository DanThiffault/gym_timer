difference() {
    translate([0,0,-12]) {
        include <speaker_cabinet.scad>;
    }
    translate([-1,-1,-12]) {
        cube([200,200,12]);
    };
}