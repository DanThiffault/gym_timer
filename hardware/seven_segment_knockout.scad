
module hex (unit=20,height=10) {
    translate([unit,3*unit,0]) {
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

module hex_with_holes(unit, height) {
    translate([2,2,0]) {
        hex(unit,10);    
        translate([unit,unit/2-1,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }
        translate([unit,3*unit+4,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }
    };
}

//hex(25,10);
//16mm on center
//250mm/digit inner
//140 max/digit. ~120mm /
u=12;
margin=5;
border=2;

difference() {
    cube([u*6+margin*2+border*2,u*10+margin*2+border*2,15]);
    translate([0,-1,0]) {
        translate([margin-1,margin+u,5]) { 
            hex_with_holes(u);
        }
        
        translate([margin-1,margin+5*u+border,5]) { 
            hex_with_holes(u);
        }
        
        translate([margin+4*u+1,margin+u,5]) { 
            hex_with_holes(u);
        }
        
        translate([margin+4*u+1,margin+5*u+border,5]) { 
            hex_with_holes(u);
        }
        
        translate([50+margin+border+u,margin-1,5]) { 
            rotate([0,0,90]) {
                hex_with_holes(u);
            }
        }
        
        translate([50+margin+border+u,margin-1+4*u+border,5]) { 
            rotate([0,0,90]) {
                hex_with_holes(u);
            }
        }
        
        translate([50+margin+border+u,margin-1+4*u+border+4*u+border,5]) { 
            rotate([0,0,90]) {
                hex_with_holes(u);
            }
        }
    }
    
    // square cutouts
    translate([2*u+border*2+margin,2*u+border*2+margin-1,5]) {
        cube([u*2-4,u*2-4,10]);        
        translate([u*2-8,4,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }   
        translate([4,u*2-8,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }   
    }
    translate([2*u+border*2+margin,2*u+border*2+margin+4*u+1,5]) {
        cube([u*2-4,u*2-4,10]);        
        translate([u*2-8,4,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }   
        translate([4,u*2-8,-5]) {
            linear_extrude(5) {
                circle(d=4);
            }
        }   
    }
    
    // border
    translate([margin/2-1,margin/2-1, 11]) {
        cube([u*6+border*2+margin/2+1+border,2,4]);
    }
    
    translate([margin/2-1, margin/2-1, 11]) {
        cube([2,u*10+border*2+margin/2+1+border,4]);
    }
    
    translate([margin/2-1,u*10+margin*2+border*2 -(margin/2+1), 11]) {
        cube([u*6+border*2+margin/2+1+border,2,4]);
    }
    
    translate([(u*6+margin*2+border*2)-(margin/2+1), margin/2-1, 11]) {
        cube([2,u*10+border*2+margin/2+1+border+1.5,4]);
    }

}

    