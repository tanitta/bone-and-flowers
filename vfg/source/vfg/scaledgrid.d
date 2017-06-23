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


ScaledGrid!(V3) drawNormal(V3)(ScaledGrid!(V3) scaledGrid){
    import armos.math;
    alias Vul3 = Vector!(ulong, 3);
    import std.range;

    import std.stdio;
    scaledGrid.origin.writeln;

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
