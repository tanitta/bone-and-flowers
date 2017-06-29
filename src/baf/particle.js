(()=>{
  let THREE = require('three'); 
  class Particle {
    constructor(deltaT, mass, position, velocity) {
      this.mass = mass|| 1.0;
      this.position = position || new THREE.Vector3(0, 0, 0);
      this.velocity = velocity || new THREE.Vector3(0, 0, 0);
      this.deltaT = deltaT || 1.0/60.0;
      this.counter = 0;
    }
    static get vertices(){
      return 100;
    };

    static get indices(){
      return 100;
    };

    setupBufferArray(vertices, colors, particleIndex){
      let verticesIndex  = particleIndex * Particle.vertices*3;
      for (var i = 0; i < Particle.vertices; ++i) {
        vertices[verticesIndex+3*i+0] = this.position.x;
        vertices[verticesIndex+3*i+1] = this.position.y;
        vertices[verticesIndex+3*i+2] = this.position.z;
      }

      let colorsIndex  = particleIndex * Particle.vertices*3;
      for (var i = 0; i < Particle.vertices; ++i) {
        colors[colorsIndex+3*i+0] = 1.0;
        colors[colorsIndex+3*i+1] = 1.0;
        colors[colorsIndex+3*i+2] = 1.0;
      }
    }

    updateBufferArray(vertices, colors, indices, particleIndex){
      let verticesIndex  = particleIndex * Particle.vertices*3;
      vertices[verticesIndex+3*(Particle.vertices-1)+0] = this.position.x;
      vertices[verticesIndex+3*(Particle.vertices-1)+1] = this.position.y;
      vertices[verticesIndex+3*(Particle.vertices-1)+2] = this.position.z;
      for (var i = 0; i < Particle.vertices-1; ++i) {
        vertices[verticesIndex+3*i+0] = vertices[verticesIndex+3*(i+1)+0];
        vertices[verticesIndex+3*i+1] = vertices[verticesIndex+3*(i+1)+1];
        vertices[verticesIndex+3*i+2] = vertices[verticesIndex+3*(i+1)+2];
      }

      if(colors){
        let colorsIndex = particleIndex * Particle.vertices*3;
        // colors[colorsIndex+3*(Particle.vertices-1)+0] = this.position.x;
        // colors[colorsIndex+3*(Particle.vertices-1)+1] = this.position.y;
        // colors[colorsIndex+3*(Particle.vertices-1)+2] = this.position.z;

        for (var i = 0; i < Particle.vertices; ++i) {
          let c = i/Particle.vertices;
          // colors[colorsIndex+3*i+0] = colors[colorsIndex+3*(i+1)+0];
          // colors[colorsIndex+3*i+1] = colors[colorsIndex+3*(i+1)+1];
          // colors[colorsIndex+3*i+2] = colors[colorsIndex+3*(i+1)+2];
          // colors[colorsIndex+3*i+0] = 1-c;
          // colors[colorsIndex+3*i+1] = 1-c;
          // colors[colorsIndex+3*i+2] = 1;
        }
      }

      if(indices){
        let indicesIndex = particleIndex * this.indices;
        indices[indicesIndex+0] = verticesIndex+0;
        indices[indicesIndex+1] = verticesIndex+1;
      }
    }

    integrate(){
      // this.velocity.add(this.velocity.clone().multiplyScalar(this.deltaT));
      this.position.add(this.velocity.clone().multiplyScalar(this.deltaT));
      // console.log(this.position);
    }

    addForce(f){
      this.velocity.add(f.clone().multiplyScalar(this.deltaT/this.mass));
    }
  }

  let addForceFromCurlNoise = (particle, randomOffset, simplex, timer,  scaledGrid)=>{
    // let x = simplex.noise3D(particle.position.x+randomOffset.x.x, particle.position.y+randomOffset.x.y, particle.position.z+randomOffset.x.z);
    // let y = simplex.noise3D(particle.position.x+randomOffset.y.x, particle.position.y+randomOffset.y.y, particle.position.z+randomOffset.y.z);
    // let z = simplex.noise3D(particle.position.x+randomOffset.z.x, particle.position.y+randomOffset.z.y, particle.position.z+randomOffset.z.z);
    let e = 0.0009765625;
    // let e = 0.01
    let e2 = 2.0 * e;

    let dx = new THREE.Vector3( e   , 0.0 , 0.0 );
    let dy = new THREE.Vector3( 0.0 , e   , 0.0 );
    let dz = new THREE.Vector3( 0.0 , 0.0 , e   );

    let p = particle.position;
    let p_x0 = simplexVector3( p.clone().sub(dx) , simplex, randomOffset, timer);
    let p_x1 = simplexVector3( p.clone().add(dx) , simplex, randomOffset, timer);
    let p_y0 = simplexVector3( p.clone().sub(dy) , simplex, randomOffset, timer);
    let p_y1 = simplexVector3( p.clone().add(dy) , simplex, randomOffset, timer);
    let p_z0 = simplexVector3( p.clone().sub(dz) , simplex, randomOffset, timer);
    let p_z1 = simplexVector3( p.clone().add(dz) , simplex, randomOffset, timer);

    let x = (p_y1.z - p_y0.z) - (p_z1.y - p_z0.y);
    let y = (p_z1.x - p_z0.x) - (p_x1.z - p_x0.z);
    let z = (p_x1.y - p_x0.y) - (p_y1.x - p_y0.x);
    let force = (new THREE.Vector3(x, y, z))
    force.multiplyScalar(1.0/e2).normalize().multiplyScalar(4.0);

    let clamp = new THREE.Vector3(0, 0, 0);
    let distance = 1;
    // if(p.length() > distance){
    //   // clamp = p.clone().normalize().multiplyScalar((distance-p.length())*1);
    //   clamp = p.clone().normalize().multiplyScalar(-2);
    //   force.add(clamp);
    // }

    let normal = p.clone().normalize();
    let r = 0;
    r +=  - force.clone().dot(normal)*0.9;
    r += (distance - p.length())*1;
    force.add(normal.multiplyScalar(r));


    // {
    //   let forceDir = force.clone().normalize().round();
    //   let forceNorm    = force.clone().length();
    //   particle.velocity= forceDir.multiplyScalar(forceNorm);
    // }

    particle.velocity = force;

  }

  let simplexVector3 = (v, simplex, randomOffset, t)=>{
    let v1 = v.clone().multiplyScalar(0.3);
    let v2 = v.clone().multiplyScalar(1);
    let weight1 = 0.5;
    let weight2 = 0.2;
    let x = simplex.noise4D(v1.x+randomOffset.x.x, v1.y+randomOffset.x.y, v1.z+randomOffset.x.z, t)*weight1;
    let y = simplex.noise4D(v1.x+randomOffset.y.x, v1.y+randomOffset.y.y, v1.z+randomOffset.y.z, t)*weight1;
    let z = simplex.noise4D(v1.x+randomOffset.z.x, v1.y+randomOffset.z.y, v1.z+randomOffset.z.z, t)*weight1;

    x += simplex.noise4D(v2.x+randomOffset.x.x, v2.y+randomOffset.x.y, v2.z+randomOffset.x.z, t)*weight2;
    y += simplex.noise4D(v2.x+randomOffset.y.x, v2.y+randomOffset.y.y, v2.z+randomOffset.y.z, t)*weight2;
    z += simplex.noise4D(v2.x+randomOffset.z.x, v2.y+randomOffset.z.y, v2.z+randomOffset.z.z, t)*weight2;
    return new THREE.Vector3(x, y, z);

  }

  module.exports.Particle = Particle;
  module.exports.addForceFromCurlNoise = addForceFromCurlNoise;
})();
