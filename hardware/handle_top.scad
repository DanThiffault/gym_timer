
difference() {
    union() {
        rotate(22.5,[1,0,0]) {
            rotate(90,[0,1,0]) {
                difference() {        
                    linear_extrude(100) {
                        circle(d=9.75,$fn=8);
                    };
                };       
            };
        };
        translate([0,-4.5,1]) {
            cube([100,9,45]);  
        };
        translate([0,0,57]) {   
            rotate(22.5,[1,0,0]) {
                rotate(90,[0,1,0]) {
                   linear_extrude(100) {
                        circle(d=24,$fn=8);
                    };
                };
            };
        };
    };   

    rotate(22.5,[1,0,0]) {
        rotate(90,[0,1,0]) {
            cylinder(d=5.6, h=100);
        };
    };
    
    translate([5,-10,-5]) {
        cube([90,30,51]);
    }
};  

