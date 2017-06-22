import std.stdio;
import armos.app;


import bvh.boundingbox;
struct Ray(N){
    import armos.math;
    private alias V3 = Vector!(N, 3);

    public{
        this(in V3 origin, in V3 direction){
            this.origin = origin;
            this.direction = direction;
        }

        V3 origin;
        V3 direction;

        bool intersectBoundingBox(in BoundingBox!N box)const{
            V3 dirFrac;
            dirFrac.x = 1.0f / direction.x;
            dirFrac.y = 1.0f / direction.y;
            dirFrac.z = 1.0f / direction.z;

            N t1 = (box.min.x - origin.x)*dirFrac.x;
            N t2 = (box.max.x - origin.x)*dirFrac.x;
            N t3 = (box.min.y - origin.y)*dirFrac.y;
            N t4 = (box.max.y - origin.y)*dirFrac.y;
            N t5 = (box.min.z - origin.z)*dirFrac.z;
            N t6 = (box.max.z - origin.z)*dirFrac.z;

            import std.math;
            N tmin = fmax(fmax(fmin(t1, t2), fmin(t3, t4)), fmin(t5, t6));
            N tmax = fmin(fmin(fmax(t1, t2), fmax(t3, t4)), fmax(t5, t6));

            if (tmax < 0)
            {
                return false;
            }

            if (tmin > tmax)
            {
                return false;
            }

            return true;
        }
    }
}

N intersect(N)(in Ray!N ray, in Triangle!N triangle){
    import armos.math;
    alias V3 = Vector!(N, 3);
    V3 ab = triangle.vertices[1] - triangle.vertices[0];
    V3 ac = triangle.vertices[2] - triangle.vertices[0];
    V3 n = ray.direction.vectorProduct(ac);

    N det = ab.dotProduct(n);

    if(-N.epsilon <= det && det <= N.epsilon){
        return 0;
    }

    V3 ao = ray.origin - triangle.vertices[0];
    N u = ao.dotProduct(n)/det;
    if(u < 0.0 || u > 1.0){
        return 0;
    }

    V3 e = ao.vectorProduct(ab);
    N v = ray.direction.dotProduct(e)/det;
    if(v < 0.0 || u+v > 1.0){
        return 0;
    }

    return  ac.dotProduct(e)/det;
}

unittest{
    alias N = double;
    import armos.math;
    alias V3 = Vector!(N, 3);
    auto ray = Ray!N(V3(1, 1, 2), V3(0, 0, -1));
    auto triangle = new Triangle!N([V3(0, 0, 1), V3(2, 0, -1), V3(1, 2, 0)]);
    assert(ray.intersect(triangle)>0);
}

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
        }

        import bvh.boundingbox;
        BoundingBox!N boundingBox;
        V3[3] vertices;
    }//public

    private{
    }//private
}//class Triangle


struct Config(N){
    import armos.math;
    private alias V3 = Vector!(N, 3);
    V3 scale = V3(1, 1, 1);
}


import armos.graphics.model;
/++
+/
class VoxelGenerator(N) {
    import bvh;
    import armos.math;
    public{
        this(Model model, in Config!N config){
            _config = config;
            Triangle!N[] triangles;
            foreach (mesh; model.meshes) {
                for (int i = 0; i < mesh.numIndices; i+=3) {
                    V3[3] vertices;
                    for (int j = 0; j < 3; j++) {
                        int indicesIndex = mesh.indices[i+j];
                        vertices[j] = V3(mesh.vertices[indicesIndex][0], mesh.vertices[indicesIndex][1], mesh.vertices[indicesIndex][2]);
                    }
                    triangles ~= new Triangle!(N)(vertices, V3(0.1, 0.1, 0.1));
                }
            }

            _node = Node!(N, Triangle!N)(triangles);
        };

        ScaledGrid!(V3) generate()const{
            V3 size = _node.boundingBox.max-_node.boundingBox.min;
            V3 indices = size/_config.scale;
            V3 origin = (_node.boundingBox.max+_node.boundingBox.min) * N(0.5);
            auto scaledGrid = generateScaledGrid(indices, _config.scale, origin);
            packInto(scaledGrid);
            return scaledGrid;
        }
    }//public

    private{
        alias V3 = Vector!(N, 3);
        Node!(N, Triangle!N)  _node;
        Config!N _config;

        ScaledGrid!(V3) packInto(ScaledGrid!(V3) scaledGrid)const{
            //X direction
            V3 rayDirection = V3(1, 0, 0);
            // foreach (i; scaledGrid) {
            //    
            // }
            //TODO
            //Y direction
            //TODO
            //Z direction
            //TODO

            return scaledGrid;
        }
    }//private
}//class VoxelGenerator

unittest{
    alias N = double;
    /++
        +/
    class TestApp : BaseApp{
        public{
            override void setup(){
                auto config = Config!N();
                auto model = (new Model()).load("icosahedron.fbx");
                auto voxelGenerator = new VoxelGenerator!N(model, config);
                exitApp;
            }
        }//public

        private{
        }//private
    }//class TestApp

    (new TestApp).run;
}

/++
+/
struct Cell(V3) {
    public{
        V3 position;
        V3 normal;
        Cell[] nbhd;
    }//public

    private{
    }//private
}//struct Cell

///
class Grid(V3) {
    public{
        this(in V3 size){
            import std.conv:to;
            cells = new Cell!V3[]((size.x*size.y*size.z).to!size_t);
            this.size = size;
        }

        V3 size;

        alias cells this;
    }
    private Cell!V3[] cells;
}
    
///
Grid!V3 generateGrid(V3)(in V3 size){
    import std.conv;
    return new Grid!V3(V3(size.x, size.y, size.z));
};

unittest{
    import armos.math;
    alias V3 = Vector3d;
    immutable size = V3(2, 2, 2);
    auto grid = generateGrid(size);
    assert(grid.length == size.x*size.y*size.z);
}

/++
+/
class ScaledGrid(V3) {
    public{
        alias grid this;
        this(in V3 indices, in V3 scale, in V3 origin = V3.zero){
            import std.conv:to;
            grid = new Grid!V3(indices);
            this.scale = scale;
            this.origin = origin;
        }

        V3 scale;
        V3 origin;

    }//public
    private Grid!V3 grid;
}//class ScaledGrid

///
ScaledGrid!(V3) generateScaledGrid(V3)(in V3 size, in V3 scale, in V3 origin){
    import std.conv;
    return new ScaledGrid!V3(size, scale);
};

unittest{
    import armos.math;
    alias V3 = Vector3d;
    immutable size = V3(2, 2, 2);
    immutable scale = V3(2, 2, 2);
    immutable origin = V3.zero;

    auto grid = generateScaledGrid(size, scale, origin);
    assert(grid.length ==size.x*size.y*size.z);
    assert(grid.scale == scale);
}

/++
+/
class Vfg : BaseApp{
    public{
        override void setup(){

        }

        override void update(){
            version(unittest){
                exitApp();
            }else{
            }
        }

        override void draw(){

        }
    }//public

    private{
        int counter = 0;
    }//private
}//class Vfg

unittest{
    run(new Vfg);
}

void main(){}
