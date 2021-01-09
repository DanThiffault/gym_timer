
module segment (unit=20) {
    difference() {        
        polyhedron(points=[
            [0,unit,0],//0
            [unit,0,0],//1
            [-unit,0,0],//2
            [0,0,unit],//3
            [unit,-2*unit,0],//4
            [-unit,-2*unit,0],//5
            [0,-2*unit,unit],//6
            [0,-3*unit,0]],//7
        faces=[
            [0,2,1],[0,1,3],[1,2,3],[0,3,2],
            [1,4,6,3],[3,6,5,2],[2,5,4,1],
            [4,7,6],[5,6,7],[4,5,7]]);
        translate([-unit/2,-2*unit,0]) {
//            cube([unit,2*unit,5]);
        };
    }
}

segment(20);
