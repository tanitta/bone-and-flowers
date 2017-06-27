import std.stdio;
import armos.app;


import bvh.boundingbox;
import vfg.ray;
import vfg.intersects;

/++
+/
struct VfgConfig {
    bool isFill = true;
    bool isInverse = false;
}//struct VfgConfig

/++
+/
class Vfg : BaseApp{
    import armos.graphics.model;
    import armos.graphics.camera;
    import vfg.scaledgrid;
    import std.conv:to;

    private{
        alias N = double;
        import armos.math.vector;
        alias V3 = Vector!(N, 3);
    }

    public{
        override void setup(){
            _camera = (new DefaultCamera).position(V3(0, 0, -5).to!Vector3f)
                                         .target(Vector3f.zero);
            _radian = 0f;
            _model = (new Model()).load("monkey.fbx");

            import vfg.voxelgenerator;
            VoxelGeneratorConfig!N voxelGeneratorConfig = {
                scale : V3(1, 1, 1)*0.1,
                isInverse : _config.isInverse
            };

             _scaledGrid = generateVoxel(_model, voxelGeneratorConfig).setBufferNormal;

            if(_config.isFill){
                import vfg.filler;
                auto fillerConfig  = FillerConfig!N();
                _scaledGrid.fillGrid(fillerConfig);
            }
        }

        override void update(){
            import std.math;
            _camera.position = V3(cos(_radian)*-5, sin(_radian)*-5, sin(_radian)*-5).to!Vector3f;
            _radian += 0.01f;
        }

        override void draw(){
            _camera.begin;scope(exit)_camera.end;
            _model.drawWireFrame;
            _scaledGrid.drawNormal;
        }

        override void exit(){
            import vfg.jsonexporter;
            _scaledGrid.exportJSON("data/normals.json");
        }
    }//public

    private{
        VfgConfig _config;
        Model _model;
        Camera _camera;
        ScaledGrid!V3 _scaledGrid;
        float _radian;
    }//private
}//class Vfg

void main(){
    run(new Vfg);
}
