module vfg.intersects;

import vfg.ray;
import vfg.triangle;

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
