module vfg.filler;
import armos.math:Vector;

/++
+/
struct FillerConfig(N) {
    N delta = 1.0;
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

            while(true){
                calc(scaledGrid);
                foreach (ref cell; scaledGrid.cells) {
                    if(cell.bufferNormal != V3.zero)cell.normal = cell.bufferNormal;
                }

                //calc condition
                N preNormSumTmp = 0;
                foreach (cell; scaledGrid) {
                    preNormSumTmp += cell.normal.norm;
                }
                import std.math;
                N preNormSumDivTmp = abs(preNormSumTmp - _preNormSum);
                if(preNormSumDivTmp == _preNormSumDiv)break;
                _preNormSumDiv = abs(preNormSumTmp - _preNormSum);
                _preNormSum = preNormSumTmp;
            }

            return scaledGrid;
        }

        ScaledGrid!V3  calc(ScaledGrid!V3 grid){
            foreach (ref cell; grid.cells) {
                if(cell.bufferNormal != V3.zero)cell.normal = cell.bufferNormal;
                import std.stdio;
                // cell.normal.norm.writeln;
                if(cell.normal.norm > 0.5)continue;
                // cell.normals ~= cell.normal;
                import std.typecons;
                import std.conv;
                import std.algorithm:map, filter, each;
                import std.range;
                auto tuples = cell.nbhd.keys.map!(key => tuple!("nbhd", "direction")(cell.nbhd[key], key))
                                            .filter!(t => t.nbhd.normal.dotProduct(t.direction.to!V3) > N(0))
                                            .array;
                tuples.each!(t => t.nbhd.normal.dotProduct(t.direction.to!V3).writeln);

                if(tuples.length>=2)tuples.each!(t => cell.normals ~= t.nbhd.normal*_config.delta);
            }
            grid.normalizeNormals
                .deleteNormalsFromCells;
            return grid;
        }
    }//public

    private{
        FillerConfig!N _config;
        N _preNormSum = 0;
        N _preNormSumDiv = 0;

    }//private
}//class Filler
