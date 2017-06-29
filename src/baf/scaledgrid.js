(()=>{
  let THREE = require('three'); 

  function modelToGrid(coordinate, gridScale, gridOrigin){
    return ((coordinate-gridorigin)/gridscale).round();
  }

  function gridToModel(coordinate, gridScale, gridOrigin){
    return coordinate.multiply(gridScale).add(gridOrigin);
  }

  class ScaledGrid {
    constructor(path, scene) {
      this.geometry = new THREE.BufferGeometry();
      this.loadRampVectorField(path, scene);
    }

    loadRampVectorField(path, scene){

      let grid;
      var req = new XMLHttpRequest();
      req.onreadystatechange = () =>{
        if(req.readyState == 4 && req.status == 200){
          grid = JSON.parse(req.responseText);
          this.normals = grid.normals.map(e=>new THREE.Vector3(e.x, e.y, e.z));
          this.indices = new THREE.Vector3(grid.indices.x, grid.indices.y, grid.indices.z);
          this.scale   = new THREE.Vector3(grid.scale.x, grid.scale.y, grid.scale.z);
          this.origin  = new THREE.Vector3(grid.origin.x, grid.origin.y, grid.origin.z);

          let positions = new Float32Array(this.normals.length*6);
          let colors = new Float32Array(this.normals.length*6);
          let indices   = new Uint32Array(this.normals.length*2);

          for (var ix = 0; ix < this.indices.x; ix++) {
            for (var iy = 0; iy < this.indices.y; iy++) {
              for (var iz = 0; iz < this.indices.z; iz++) {
                let fv = new THREE.Vector3(ix, iy, iz);
                let iv = {x:ix, y:iy, z:iz};
                let normal = this.normal(fv);
                if(normal.length()> 0.5){
                  colors[this.index(iv)*6+0] = (normal.x+1)*0.5;
                  colors[this.index(iv)*6+1] = (normal.y+1)*0.5;
                  colors[this.index(iv)*6+2] = (normal.z+1)*0.5;

                  colors[this.index(iv)*6+3] = (normal.x+1)*0.5;
                  colors[this.index(iv)*6+4] = (normal.y+1)*0.5;
                  colors[this.index(iv)*6+5] = (normal.z+1)*0.5;

                  let mv = gridToModel(fv, this.scale, this.origin);
                  positions[this.index(iv)*6+0] = mv.x;
                  positions[this.index(iv)*6+1] = mv.y;
                  positions[this.index(iv)*6+2] = mv.z;
                  let to = mv.add(normal.multiplyScalar(0.1))
                  positions[this.index(iv)*6+3] = to.x;
                  positions[this.index(iv)*6+4] = to.y;
                  positions[this.index(iv)*6+5] = to.z;
                  indices[this.index(iv)*2+0] = this.index(iv)*2+0;
                  indices[this.index(iv)*2+1] = this.index(iv)*2+1
                }
              }
            }
          }
          this.geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
          this.geometry.addAttribute('color', new THREE.BufferAttribute(colors, 3));

          this.geometry.computeBoundingSphere();
          let material = new THREE.LineBasicMaterial( {
            color: 0xffffff, 
            vertexColors: THREE.VertexColors
          } );
          let line = new THREE.LineSegments(this.geometry, material);
          scene.add(line);
        }
      };
      req.open("GET", path, false);
      req.send(null);  
    }

    sampler3d(){
      //TODO
    }

    draw(){
      // this.normals.map(v=>{});
    }

    normal(v){
      return this.normals[this.index(v)];
    }

    index(v){
      return v.x + v.y*this.indices.x + v.z*this.indices.x*this.indices.y;
    }

  }
  module.exports.ScaledGrid = ScaledGrid;


})();
