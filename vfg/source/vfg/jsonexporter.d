module vfg.jsonexporter;

import std.json;
import vfg.scaledgrid;;

void exportJSON(V3)(ScaledGrid!(V3) grid, in string path){
    import std.file;
    auto json = grid.toJSONValue;
    write(path, toJSON(json, true));
}

auto toJSONValue(V3)(ScaledGrid!(V3) grid){
    JSONValue jsonStruct = parseJSON("{}");
    import std.algorithm;
    import std.array;
    auto normals = grid.cells.map!(cell => cell.normal.toJSONValue).array;
    jsonStruct.object["normals"] = JSONValue(normals);
    jsonStruct.object["indices"] = grid.indices.toJSONValue;
    jsonStruct.object["scale"] = grid.scale.toJSONValue;
    jsonStruct.object["origin"] = grid.origin.toJSONValue;
    return jsonStruct;
}

auto toJSONValue(V3)(in V3 v){
    JSONValue jv = ["x":v.x, "y":v.y, "z":v.z];
    return jv;
}
unittest{
    alias N = double;
    import armos.math;
    alias V3 = Vector!(N, 3);
    assert(V3(1, 2, 3).toJSONValue.toString == `{"x":1,"y":2,"z":3}`);
}
