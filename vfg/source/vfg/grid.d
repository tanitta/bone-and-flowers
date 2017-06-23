module vfg.grid;

import vfg.cell;

///
class Grid(V3) {
    public{
        this(in Vi3 indices){
            import std.conv:to;
            cells = new Cell!V3[](indices.x*indices.y*indices.z);
            this.indices= indices;
        }

        ref auto index(in Vi3 iv){
            size_t i = iv.x + iv.y*indices.x + iv.z*indices.x*indices.y;
            return cells[i];
        }

        Vi3 indices;

        alias cells this;
    }

    Cell!V3[] cells;
    import armos.math:Vector;
    private alias Vi3 = Vector!(size_t, 3);
}

unittest{
    import armos.math;
    alias V3 = Vector3d;
    alias Vi3 = Vector!(size_t, 3);
    immutable size = Vi3(2, 2, 2);
    auto grid = new Grid!V3(size);
    assert(grid.length == size.x*size.y*size.z);
}
