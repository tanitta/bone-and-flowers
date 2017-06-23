module vfg.ray;

import bvh.boundingbox;

struct Ray(N){
    import armos.math;
    private alias V3 = Vector!(N, 3);

    public{
        this(in V3 origin, in V3 direction){
            this.origin = origin;
            this.direction = direction;
        }

        V3 origin;
        V3 direction;

        bool intersectBoundingBox(in BoundingBox!N box)const{
            V3 dirFrac;
            dirFrac.x = 1.0f / direction.x;
            dirFrac.y = 1.0f / direction.y;
            dirFrac.z = 1.0f / direction.z;

            N t1 = (box.min.x - origin.x)*dirFrac.x;
            N t2 = (box.max.x - origin.x)*dirFrac.x;
            N t3 = (box.min.y - origin.y)*dirFrac.y;
            N t4 = (box.max.y - origin.y)*dirFrac.y;
            N t5 = (box.min.z - origin.z)*dirFrac.z;
            N t6 = (box.max.z - origin.z)*dirFrac.z;

            import std.math;
            N tmin = fmax(fmax(fmin(t1, t2), fmin(t3, t4)), fmin(t5, t6));
            N tmax = fmin(fmin(fmax(t1, t2), fmax(t3, t4)), fmax(t5, t6));

            if (tmax < 0)
            {
                return false;
            }

            if (tmin > tmax)
            {
                return false;
            }

            return true;
        }
    }
}
