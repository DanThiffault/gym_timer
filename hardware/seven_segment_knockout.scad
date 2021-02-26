
module hex (unit=20,height=15) {
    translate([unit + 2,3*unit + 2,0]) {
        linear_extrude(height) {        
            polygon(points=[
                [0,unit],//0
                [unit,0],
                [unit,-2*unit],
                [0,-3*unit],
                [-unit,-2*unit],
                [-unit,0]]);
        }
    }
}

//16mm on center
//250mm/digit inner
//140 max/digit. ~120mm /
u=12;
margin=5;
border=2;

difference() {
    cube([u*6+margin*2+border*2,u*10+margin*2+border*2,15]);
    translate([0,-1,0]) {
        translate([margin-1,margin+u,0]) { 
            hex(u);
        }
        
        translate([margin-1,margin+5*u+border,0]) { 
            hex(u);
        }
        
        translate([margin+4*u+1,margin+u,0]) { 
            hex(u);
        }
        
        translate([margin+4*u+1,margin+5*u+border,0]) { 
            hex(u);
        }
        
        translate([50+margin+border+u,margin-1,0]) { 
            rotate([0,0,90]) {
                hex(u);
            }
        }
        
        translate([50+margin+border+u,margin-1+4*u+border,0]) { 
            rotate([0,0,90]) {
                hex(u);
            }
        }
        
        translate([50+margin+border+u,margin-1+4*u+border+4*u+border,0]) { 
            rotate([0,0,90]) {
                hex(u);
            }
        }
    }
    
    // square cutouts
    translate([2*u+border*2+margin,2*u+border*2+margin-1,0]) {
        cube([u*2-4,u*2-4,15]);        
    }
    translate([2*u+border*2+margin,2*u+border*2+margin+4*u+1,0]) {
        cube([u*2-4,u*2-4,15]);         
    }
    
    // mounting holes
    translate([10,10,0]) {
        cylinder(h=15, d=3.4, $fn=12);
    }
    translate([u*6+margin*2+border*2-10,10,0]) {
        cylinder(h=15, d=3.4, $fn=12);
    }
    translate([10,u*10+margin*2+border*2-10,0]) {
        cylinder(h=15, d=3.4, $fn=12);
    }
    translate([u*6+margin*2+border*2-10,u*10+margin*2+border*2-10,0]) {
        cylinder(h=15, d=3.4, $fn=12);
    }
    
    // connection wire cutouts
    translate([0,62,0]) {
        cube([10,10,5]);
    };
    
    translate([86-10,62,0]) {
        cube([10,10,5]);
    };
    
    // vertical mounts
    translate([18,8,15/2]) {
        rotate(90,[1,0,0]) {
            cylinder(h=8, d=5);
        };
    };
    translate([86-18,8,15/2]) {
        rotate(90,[1,0,0]) {
            cylinder(h=8, d=5);
        };
    };
    translate([18,134,15/2]) {
        rotate(90,[1,0,0]) {
            cylinder(h=8, d=5);
        };
    };
    translate([86-18,134,15/2]) {
        rotate(90,[1,0,0]) {
            cylinder(h=8, d=5);
        };
    };
}

    