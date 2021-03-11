
//16mm on center
//250mm/digit inner
//140 max/digit. ~120mm /
u=12;
margin=5;
border=2;

difference() {
    cube([u*6+margin*2+border*2,20,15]);


    // mounting holes
    translate([10,10,7]) {
        cylinder(h=8, d=5, $fn=12);        
    }
    translate([u*6+margin*2+border*2-10,10,7]) {
        cylinder(h=8, d=5, $fn=12);
    }


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


}

    