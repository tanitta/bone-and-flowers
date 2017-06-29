(function(){
  let THREE           = require('three'); 
  THREE.OrbitControls = require('three-orbit-controls')(THREE);

  let EMITTER         = require('./emitter.js'); 

  module.exports = 
    class MainApp {
      constructor(config) {
        this._config = config;

        this._scene = new THREE.Scene();
        this._camera = new THREE.PerspectiveCamera( config.camera.fov, config.camera.aspect(), config.camera.near, config.camera.far );
        this._camera.position.set( 0, 1, 4 );
        this._controls = new THREE.OrbitControls(this._camera);
        this._controls.rotateSpeed = 0.1;
        this._controls.autoRotate = true;
        this._controls.enableDamping = true;
        this._controls.dampingFactor = 0.05;
        this._controls.autoRotateSpeed = 0.1;

        this._light = new THREE.DirectionalLight(0xffffff, 1.0);
        this._renderer = new THREE.WebGLRenderer( { antialias: false} );


        this._emitter = new EMITTER.Emitter(this._scene, 1000, new THREE.Vector3(0, 0, 0), 1.0/60.0);
      }

      setup(){
        // this.setupBone();
        // this.setupScaleGrid();
        // this.setupGrid();
        this.setupRenderer();
        this.setupEmitters();
        this._light.position.set(0, 1, 0);
        this._scene.add(this._light);
      }

      setupScaleGrid(){
        let SCALEDGRID = require('./scaledgrid.js'); 
        this._scaledGrid = new SCALEDGRID.ScaledGrid( "data/normals.json", this._scene);
      }

      update(){
        this._emitter.update();
        this._controls.update();
      }

      draw(){
        this._renderer.render(this._scene, this._camera);
      }

      registerDom(container){
        container.appendChild( this._renderer.domElement );
      }

      setupEmitters(){
      }

      setupGrid(){
        var gridHelper = new THREE.GridHelper( 28, 28, 0x303030, 0x303030 );
        gridHelper.position.set( 0, - 0.04, 0 );
        this._scene.add( gridHelper );
      }

      setupRenderer(){
        this._renderer.setSize( this._config.camera.width, this._config.camera.height );
        this._renderer.setClearColor( 0x000000 );
      }

      setupBone(){
        let loader = new THREE.JSONLoader();

        let onProgress = function( xhr ) {
          if ( xhr.lengthComputable ) {
            let percentComplete = xhr.loaded / xhr.total * 100;
            console.log( Math.round( percentComplete, 2 ) + '% downloaded' );
          }
        };
        let onError = function( xhr ) {
          console.error( xhr );
        };
        loader.load('data/bone.json', (geo)=>{
          var material = new THREE.MeshLambertMaterial( {
            color: 0xffffff
          } );
          var model = new THREE.Mesh(geo, material);　　　
          model.position.set(0, 0, 0);
          this._scene.add(model);　　
          this._renderer.render(this._scene, this._camera);
        }, onProgress, onError);
      }

      onWindowResize(){
        this._camera.aspect = window.innerWidth / window.innerHeight;
        this._camera.updateProjectionMatrix();
        this._renderer.setSize( window.innerWidth, window.innerHeight );
        console.log("resize!");
      }
    };
})();
