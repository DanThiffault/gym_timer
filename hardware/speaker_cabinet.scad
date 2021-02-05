u=12;
margin=5;
border=2;

difference() {
    union() {
        cube([u*6+margin*2+border*2,u*10+margin*2+border*2,55]);
    };
    
    //main cutout
    translate([3,3,22]) {
        cube([u*6+margin*2+border*2-6,u*10+margin*2+border*2-6,33]);
    };
    
    //speaker stands
    translate([(87-58)/2,(134-58)/2,17]) {
        cylinder(h=8, d=5);
    }
    translate([(87-58)/2+58,(134-58)/2,17]) {
        cylinder(h=8, d=5);
    }
    translate([(87-58)/2,(134-58)/2+58,17]) {
        cylinder(h=8, d=5);
    }
    translate([(87-58)/2+58,(134-58)/2+58,17]) {
        cylinder(h=8, d=5);
    }    
    
    //back mounting bracket
    translate([10,10,0]) {
        cylinder(h=8, d=5);
    }
    translate([u*6+margin*2+border*2-10,10,0]) {
        cylinder(h=8, d=5);
    }
    translate([10,u*10+margin*2+border*2-10,0]) {
        cylinder(h=8, d=5);
    }
    translate([u*6+margin*2+border*2-10,u*10+margin*2+border*2-10,0]) {
        cylinder(h=8, d=5);
    }
    
    //power cutout
    translate([0,15,10]) {
        cube([15,9.3,11.2]);        
    }    
    //power cutout pins
    translate([6,15,6]) {
        cube([9,9.3,4]);
    }    
    //power cable run
    translate([15,15,10]) {
        cube([86-14.5,9.3,2]);        
    }    
    
    //speaker magnet
    translate([87/2-33/2+16,134/2-33/2+16,12]) {
        cylinder(h=10,d=33);
    }
    
    //speaker wire conduit
    translate([u*6+margin*2+border*2-5,134/2,30]) {
        rotate(90,[0,1,0]) {
            cylinder(h=15,d=4);
        }
    }
};

// speaker stand 4mm diameter, 58mm apart
//87x134mm
