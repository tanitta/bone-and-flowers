import std.stdio;
import armos.app;


import bvh.boundingbox;
import vfg.ray;
import vfg.intersects;
import vfg.voxelgenerator;

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
