difference() {
    cylinder(d1=4.2,d2=4.8,h=4.9);
    cube([5,0.75,6],center=true);  
    cube([0.75,5,6],center=true);  
};
translate([0,0,2.9]) {    
    difference() {
        sphere(d=9);
        translate([0,0,-4.5]){
            cube([9,9,9],center=true);
        };
        translate([0,0,7]){
            cube([9,9,9],center=true);
        };
    };
};
