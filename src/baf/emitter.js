(()=>{
  let THREE        = require('three'); 
  let PARTICLE     = require('./particle.js'); 
  let SimplexNoise = require('simplex-noise'); 

  class Emitter {
    constructor(scene, numParticles, position, deltaT) {
      this.simplex = new SimplexNoise();
      let randomVector = new THREE.Vector3(0, 0, 0);
      this.particles = (new Array(numParticles));
      for (var p = 0; p < this.particles.length; ++p) {
        randomVector.set((Math.random()*2.0)-1.0,
                         (Math.random()*2.0)-1.0,
                         (Math.random()*2.0)-1.0);
        randomVector.multiplyScalar(0.1);

        this.timer = 0;
        this.particles[p] = new PARTICLE.Particle(deltaT,
                                                  1.0,
                                                  position.clone().add(randomVector),
                                                  null);

        this.randomOffset = {
          x:new THREE.Vector3(Math.random(), Math.random(), Math.random()), 
          y:new THREE.Vector3(Math.random(), Math.random(), Math.random()), 
          z:new THREE.Vector3(Math.random(), Math.random(), Math.random()), 
        };
      }
      console.log(this.particles);
      this.position = position;

      this.setupMesh(scene);

      for (var p = 0; p < this.particles.length; ++p) {
        this.particles[p].setupBufferArray(this.vertices, this.colors, p);
      }
    }

    setupMesh(scene){
      this.vertices = new Float32Array(PARTICLE.Particle.vertices*this.particles.length*3);
      this.colors   = new Float32Array(PARTICLE.Particle.vertices*this.particles.length*3);
      this.indices  = new Uint32Array (PARTICLE.Particle.indices*this.particles.length);

      this.geometry = new THREE.BufferGeometry();
      this.geometry.addAttribute('position', new THREE.BufferAttribute(this.vertices, 3).setDynamic(true));
      this.geometry.addAttribute('color', new THREE.BufferAttribute(this.colors, 3).setDynamic(true));
      let material = new THREE.LineBasicMaterial( {
        color: 0xffffff, 
        transparent:true, 
        opacity:0.2, 
        blending: THREE.AdditiveBlending
        // vertexColors: THREE.VertexColors
      } );
      this.mesh = new THREE.LineSegments(this.geometry, material);

      scene.add(this.mesh);
    }

    update(){
      for (var particleIndex = 0; particleIndex < this.particles.length; ++particleIndex) {
        PARTICLE.addForceFromCurlNoise(this.particles[particleIndex],
                                       this.randomOffset,
                                       this.simplex,
                                       this.timer,  
                                       null);
        this.particles[particleIndex].integrate();
        this.particles[particleIndex].updateBufferArray(this.vertices,
                                                        this.colors,
                                                        this.indices,
                                                        particleIndex
                                                       );
      }
      this.geometry.attributes.position.needsUpdate = true;
      this.geometry.attributes.color.needsUpdate = true;
      this.timer += 0.01;
    }
  }
  module.exports.Emitter = Emitter;
})();
