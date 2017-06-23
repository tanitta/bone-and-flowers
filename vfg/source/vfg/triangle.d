module vfg.triangle;

/++
+/
class Triangle(N) {
    import armos.math;
    private alias V3 = Vector!(N, 3);
    public{
        this(in V3[3] vertices, in V3 clearance = V3(0, 0, 0)){
            this.vertices = vertices;
            auto tmpMin = V3.zero;
            auto tmpMax = V3.zero;
            import std.math;
            for (int dim = 0; dim < 3; dim++) {
                tmpMin[dim] = fmin(vertices[0][dim], fmin(vertices[1][dim], vertices[2][dim]));
                tmpMax[dim] = fmax(vertices[0][dim], fmax(vertices[1][dim], vertices[2][dim]));
            }
            boundingBox = BoundingBox!N(tmpMin-clearance, tmpMax+clearance);

            normal = (vertices[1]-vertices[0]).vectorProduct(vertices[2]-vertices[0]).normalized;
        }

        import bvh.boundingbox;
        BoundingBox!N boundingBox;
        V3[3] vertices;
        V3 normal;
    }//public

    private{
    }//private
}//class Triangle
