module vfg.voxelgenerator;

struct Config(N){
    import armos.math;
    private alias V3 = Vector!(N, 3);
    V3 scale = V3(0.1, 0.1, 0.1);
}


import armos.graphics.model;
import vfg.scaledgrid;
/++
+/
class VoxelGenerator(N) {
    import bvh;
    import armos.math: Vector;
    import vfg.triangle;
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
                    triangles ~= new Triangle!(N)(vertices, V3(0, 0, 0));
                }
            }

            _node = Node!(N, Triangle!N)(triangles);
        };

        ScaledGrid!(V3) generate()const{
            V3 size = _node.boundingBox.max-_node.boundingBox.min;
            import std.algorithm:map;
            import std.conv:to;
            import std.range;
            import std.math;
            Vul3 indices = _node.boundingBox.indicesFromBoundingBox!Vul3(_config.scale);
            V3 origin = _node.boundingBox.min;
            auto scaledGrid = generateScaledGrid(indices, _config.scale, origin);
            packFromPerspectiveInto(scaledGrid, V3(1, 0, 0));
            packFromPerspectiveInto(scaledGrid, V3(0, 1, 0));
            packFromPerspectiveInto(scaledGrid, V3(0, 0, 1));
            normalizeNormals(scaledGrid);
            attachNbhd(scaledGrid);
            return scaledGrid;
        }
    }//public

    private{
        alias V3 = Vector!(N, 3);
        alias Vul3 = Vector!(ulong, 3);
        alias Vl3 = Vector!(long, 3);
        Node!(N, Triangle!N)  _node;
        Config!N _config;

        ScaledGrid!(V3) packFromPerspectiveInto(ScaledGrid!(V3) scaledGrid, in V3 rayDirection)const{
            import std.range;
            import std.conv:to;

            foreach (ix; (scaledGrid.indices.x*(Vl3(1, 1, 1)-rayDirection.to!Vl3).x+1).iota) {
                foreach (iy; (scaledGrid.indices.y*(Vl3(1, 1, 1)-rayDirection.to!Vl3).y+1).iota) {
                    foreach (iz; (scaledGrid.indices.z*(Vl3(1, 1, 1)-rayDirection.to!Vl3).z+1).iota) {
                        auto rayOrigin = (Vl3(ix, iy, iz)-rayDirection.to!Vl3).gridToModel(scaledGrid.scale, _node.boundingBox.min);

                        import vfg.ray;
                        Ray!N ray = Ray!N(rayOrigin, rayDirection);

                        import std.algorithm:map, filter;
                        import std.typecons;
                        import vfg.intersects;
                        auto collidingTrianglesWithDistance = _node.detectCollidables(ray)
                            .map!(triangle => tuple(triangle, ray.intersect(triangle)))
                            .filter!(t => t[1]>0)
                            .array;

                        foreach (t; collidingTrianglesWithDistance) {
                            import std.math:lround;
                            import std.range;
                            auto hitPoint = (rayDirection*t[1]+rayOrigin);
                            auto index = hitPoint.modelToGrid!(Vul3)(scaledGrid.scale, _node.boundingBox.min);

                            import vfg.cell;
                            scaledGrid.index(index).normals ~= t[0].normal;
                        }
                    }
                }
            }
            return scaledGrid;
        }

        auto normalizeNormals(ScaledGrid!(V3) scaledGrid)const{
            foreach (ref cell; scaledGrid.cells) {
                if(cell.normals.length > 0){
                    import std.algorithm;
                    cell.normal = cell.normals.fold!"a+b"(V3.zero)/cell.normals.length;
                    if(cell.normal.norm != 0){
                        cell.normal.normalize;
                    }
                }else{
                    cell.normal = V3.zero;
                }
            }
            return scaledGrid;
        }

        auto attachNbhd(ScaledGrid!(V3) scaledGrid)const{
            alias Vul3 = Vector!(ulong, 3);


            import std.range;
            foreach (ix; scaledGrid.indices.x.iota) {
                foreach (iy; scaledGrid.indices.y.iota) {
                    foreach (iz; scaledGrid.indices.z.iota) {
                        auto iv = Vl3(ix, iy, iz);
                        scaledGrid.setNbhd(iv, Vl3(1, 0, 0))
                                  .setNbhd(iv, Vl3(-1, 0, 0))
                                  .setNbhd(iv, Vl3(0, 1, 0))
                                  .setNbhd(iv, Vl3(0, -1, 0))
                                  .setNbhd(iv, Vl3(0, 0, 1))
                                  .setNbhd(iv, Vl3(0, 0, -1));
                    }
                }
            }
            return scaledGrid;
        }
    }//private
}//class VoxelGenerator

unittest{
    alias N = double;
    import armos.math.vector;
    alias V3 = Vector!(N, 3);
    import armos.graphics.camera;

    import armos.app;
    import std.conv:to;

    /++
    +/
    class TestApp : BaseApp{
        public{
            override void setup(){
                auto config = Config!N();
                _camera = (new DefaultCamera).position(V3(0, 0, -5).to!Vector3f)
                                             .target(Vector3f.zero);
                _model = (new Model()).load("monkey.fbx");
                auto voxelGenerator = new VoxelGenerator!N(_model, config);
                _scaledGrid = voxelGenerator.generate;
                _radian = 0f;
                // exitApp;
            }

            override void update(){
                import std.math;
                _camera.position = V3(cos(_radian)*-5, 0, sin(_radian)*-5).to!Vector3f;
                _radian += 0.01f;
            }

            override void draw(){
                _camera.begin;scope(exit)_camera.end;
                _model.drawWireFrame;
                _scaledGrid.drawNormal;
            }
        }//public

        private{
            Model _model;
            Camera _camera;
            ScaledGrid!V3 _scaledGrid;
            float _radian;
        }//private
    }//class TestApp

    (new TestApp).run;
}

V3 gridToModel(V3, Vul3)(Vul3 i, V3 gridScale, V3 gridOrigin){
    import std.conv:to;
    return i.to!V3 * gridScale + gridOrigin;
}


Vl3 modelToGrid(Vl3, V3)(V3 v, V3 gridScale, V3 gridOrigin){
    import std.algorithm:map;
    import std.conv:to;
    import std.math;
    import std.range:array;
    auto arr = ((v-gridOrigin)/gridScale).elements[].map!(e => e.lround.to!(Vl3.elementType)).array;
    return Vl3(arr);
}

Vul3 indicesFromBoundingBox(Vul3, V3, BoundingBox)(in BoundingBox box, in V3 scale){
    return (box.max-box.min).modelToGrid!Vul3(scale, V3.zero) + Vul3(1, 1, 1);
}

unittest{
    import armos.math;
    alias N = double;
    alias V3 = Vector!(N, 3);
    alias Vul3 = Vector!(size_t, 3);
    V3 scale = V3(0.5, 0.5, 0.5);
    import bvh.boundingbox;
    auto boundingBox = BoundingBox!N(V3(-1, -1, -1), V3(1, 1, 1));
    auto indices = boundingBox.indicesFromBoundingBox!Vul3(scale);
    assert(indices == Vul3(5, 5, 5));
}

bool exist(Vul3, Grid)(in Vul3 i, in Grid scaledGrid){
    return 0 <= i.x && i.x < scaledGrid.indices.x &&
           0 <= i.y && i.y < scaledGrid.indices.y &&
           0 <= i.z && i.z < scaledGrid.indices.z;
}

auto setNbhd(Grid, Vl3)(Grid grid, in Vl3 targetIndex, in Vl3 nbhdDirection){
    immutable nbhdIndex = targetIndex+nbhdDirection;
    if((nbhdIndex).exist(grid)){
        import std.conv:to;
        import armos.math:Vector;
        grid.index(targetIndex.to!(Vector!(ulong, 3))).nbhd[nbhdIndex] = grid.index(nbhdIndex.to!(Vector!(ulong, 3)));
    }
    return grid;
}
