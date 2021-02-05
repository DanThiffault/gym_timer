
module hex (unit=20,height=10) {    
          
    polyhedron(points=[
        [0,unit,0],//0
        [unit,0,0],
        [unit,-2*unit,0],
        [0,-3*unit,0],
        [-unit,-2*unit,0],
        [-unit,0,0],//end old 
        [0,unit-2,height],//6
        [unit-1,0-1,height],
        [unit-1,-2*unit+1,height],
        [0,-3*unit+2,height],
        [-unit+1,-2*unit+1,height],
        [-unit+1,0-1,height]],
    faces=[
    //[0,1,2,3,4,5],
    [0,5,4,3,2,1],
    [0,1,7,6],
    [1,2,8,7],
    [2,3,9,8],
    [3,4,10,9],
    [4,5,11,10],
    [5,0,6,11],
    [6,7,8,9,10,11]
    ]);

}

//hex(25,10);
//16mm on center
//250mm/digit inner
//140 max/digit. ~120mm /
u=12;
margin=5;
border=2;

radius=2;

difference() {
    union() {
        difference() {
            hex(u,5);
            translate([-20,-40,1.5]) {
                cube(60);
            };

        }

        translate([0,-4,0.5]) { 
            sphere(radius);
        };
        
        translate([0,-18,0.5]) { 
            sphere(radius);
        };
    };
    translate([-20,-40,-5])  {
        cube([40,60,5]);
    };
};