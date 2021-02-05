difference() {
    cube([30,60,12]);

    translate([0,30,6]) {
        rotate(90,[0,1,0]) {
            cylinder(d=5.4,h=30, $fn=12);
        }
    };
    translate([7.5,7.5,0]) {
        cylinder(d=4, h=12, $fn=12);
    };
    translate([22.5,7.5,0]) {
        cylinder(d=4, h=12, $fn=12);
    };
    translate([7.5,52.5,0]) {
        cylinder(d=4, h=12, $fn=12);
    };
    translate([22.5,52.5,0]) {
        cylinder(d=4, h=12, $fn=12);
    };
    translate([0,0,3]) {
        cube([30,20,9]);
    };
    
    translate([0,40,3]) {
        cube([30,20,9]);
    };
};