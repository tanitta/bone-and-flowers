module vfg.cell;

import armos.math:Vector;
/++
+/
struct Cell(V3) {
    public{
        V3 position;
        V3[] normals;
        Cell*[Vi3] nbhd;
        V3 normal;
        V3 bufferNormal;
    }//public

    private{
        alias Vi3 = Vector!(long, 3);
    }//private
}//struct Cell
