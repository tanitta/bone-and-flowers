module vfg.scaledgrid;

import vfg.grid;

/++
+/
class ScaledGrid(V3) {
    public{
        alias grid this;
        this(in Vi3 indices, in V3 scale, in V3 origin = V3.zero){
            import std.conv:to;
            grid = new Grid!V3(indices);
            this.scale = scale;
            this.origin = origin;
        }

        V3 scale;
        V3 origin;

    }//public
    Grid!V3 grid;
    import armos.math:Vector;
    private alias Vi3 = Vector!(size_t, 3);
}//class ScaledGrid

///
ScaledGrid!(V3) generateScaledGrid(Vi3, V3)(in Vi3 indices, in V3 scale, in V3 origin){
    import std.conv;
    return new ScaledGrid!V3(indices, scale, origin);
};

unittest{
    import armos.math;
    alias V3 = Vector3d;
    alias Vi3 = Vector!(size_t, 3);
    immutable size = Vi3(2, 2, 2);
    immutable scale = V3(2, 2, 2);
    immutable origin = V3.zero;

    auto grid = new ScaledGrid!V3(size, scale, origin);
    assert(grid.length ==size.x*size.y*size.z);
    assert(grid.scale == scale);
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

ScaledGrid!(V3) drawNormal(V3)(ScaledGrid!(V3) scaledGrid){
    import armos.math;
    alias Vul3 = Vector!(ulong, 3);
    import std.range;

    foreach (ix; scaledGrid.indices.x.iota) {
        foreach (iy; scaledGrid.indices.y.iota) {
            foreach (iz; scaledGrid.indices.z.iota) {
                auto iv = Vul3(ix, iy, iz);
                auto targetCell = scaledGrid.index(iv);
                if(targetCell.normal.norm == 0)continue;
                import armos.graphics;
                import std.conv:to;
                import vfg.voxelgenerator;
                V3 normalOrigin = iv.gridToModel(scaledGrid.scale, scaledGrid.origin);
                drawLine(normalOrigin, normalOrigin+targetCell.normal*0.1);
            }
        }
    }
    return scaledGrid;
}

auto normalizeNormals(V3)(ScaledGrid!(V3) scaledGrid){
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

auto deleteNormalsFromCells(V3)(ScaledGrid!(V3) scaledGrid){
    foreach (ref cell; scaledGrid.cells) {
        cell.normals = [];
    }
    return scaledGrid;
}

auto setBufferNormal(V3)(ScaledGrid!(V3) scaledGrid){
    foreach (ref cell; scaledGrid.cells) {
        cell.bufferNormal = cell.normal;
    }
    return scaledGrid;
}

auto invertNormals(V3)(ScaledGrid!(V3) scaledGrid){
    foreach (ref cell; scaledGrid.cells) {

        if(cell.normal.norm > 0){
            cell.normal = -cell.normal;
        }
    }
    return scaledGrid;
}
