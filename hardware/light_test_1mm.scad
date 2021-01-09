//12x50mm
difference() {
    cube([22,60,15]);
    
    translate([5,5,1]) {
        cube([12,50,15]);
    }
    
    translate([5,0,10]) {
        cube([12,10,15]);
    }
        
    translate([5,55,10]) {
        cube([12,10,15]);
    }
}