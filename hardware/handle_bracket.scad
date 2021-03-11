difference() {
    cube([25,12,15]);
    // handle holder
    translate([0,5.7,10]) {
        rotate(90,[0,1,0]) {
            cylinder(d=5.4,h=25, $fn=12);
        }
    };
    // bottom connections
    translate([5,6,0]) {
        cylinder(d=4, h=5, $fn=12);
    };
    translate([20,6,0]) {
        cylinder(d=4, h=5, $fn=12);
    };
    // cut outs
    translate([9,0,5]) {
        cube([7,12,12]);
    };
}