u=12;
margin=5;
border=2;

difference() {
    union() {
        cube([u*6+margin*2+border*2,u*10+margin*2+border*2,56.3]);
        translate([u*6+margin*2+border*2,1.3,1.3]) {
          cube([5,u*10+margin*2+border*2-2.6,40-1.3]);
        };
    };
    
    //main cutout
    difference() {
        translate([4,4,5]) {
            cube([u*6+margin*2+border*2-8,u*10+margin*2+border*2-8,51.3]);
        };
        translate([((87-58)/2)-5,((134-58)/2)-5,0]) {
          cube([68,68,30]);
        };
    }
    
    //speaker stands
    translate([(87-58)/2,(134-58)/2,0]) {
        cylinder(h=30,d=5.2);
    }
    translate([(87-58)/2+58,(134-58)/2,0]) {
        cylinder(h=30,d=5.2);
    }
    translate([(87-58)/2,(134-58)/2+58,0]) {
        cylinder(h=30,d=5.2);
    }
    translate([(87-58)/2+58,(134-58)/2+58,0]) {
        cylinder(h=30,d=5.2);
    }    
    
    //speaker magnet
    translate([(87-58)/2+(58-33)/2+16,(134-58)/2+(58-33)/2+16,20]) {
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
