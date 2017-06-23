module vfg.filler;
import armos.math:Vector;

/++
+/
struct FillerConfig(N) {
    N delta = 0.01;
    private{
        alias V3 = Vector!(N, 3);
    }//private
}//struct FillerConfig

import vfg.scaledgrid;

auto fillGrid(Grid, N)(Grid grid, FillerConfig!N config){
    auto filler = new Filler!N(config);
    return filler.fill(grid);
}

/++
+/
class Filler(N) {
    private{
        alias V3 = Vector!(N, 3);
    }

    public{
        this(FillerConfig!N config){
            _config = config;
        }

        ScaledGrid!V3 fill(ScaledGrid!V3 scaledGrid){
            foreach (ref cell; scaledGrid.cells) {
                cell.bufferNormal = cell.normal;
            }
            calc(scaledGrid);
            foreach (ref cell; scaledGrid.cells) {
                if(cell.bufferNormal != V3.zero)cell.normal = cell.bufferNormal;
            }
            return scaledGrid;
        }

        ScaledGrid!V3  calc(ScaledGrid!V3 grid){
            foreach (ref cell; grid.cells) {
                if(cell.bufferNormal != V3.zero)cell.normal = cell.bufferNormal;
                if(cell.normal != V3.zero)continue;
                cell.normals ~= cell.normal;
                import std.typecons;
                import std.conv;
                import std.algorithm:map, filter, each;
                import std.range;
                auto tuples = cell.nbhd.keys.map!(key => tuple!("nbhd", "direction")(cell.nbhd[key], key))
                                            .filter!(t => t.direction.to!V3.dotProduct(t.nbhd.normal) > N(0)).array;
                if(tuples.length>=3)tuples.each!(t => cell.normals ~= t.nbhd.normal*_config.delta);
            }
            grid.normalizeNormals
                .deleteNormalsFromCells;
            return grid;
        }
    }//public

    private{
        FillerConfig!N _config;
    }//private
}//class Filler
