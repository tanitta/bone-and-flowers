(function(){
  let BAF = {};
  BAF.MainApp = require('./baf/mainapp.js'); 

  let container;
  let config = {
    camera:{
      width : 600,
      height: 400,
      fov   : 60,
      near  : 0.1, 
      far   : 1000, 
      aspect: function(){return this.width/this.height}
    }
  }
  let mainApp;
  window.addEventListener( 'DOMContentLoaded', setup, false );

  function setup() {
    mainApp = new BAF.MainApp(config);

    container = document.createElement( 'div' );
    document.body.appendChild( container );
    mainApp.registerDom(container);
    window.addEventListener( 'resize', onWindowResize, false );

    mainApp.setup();

    update();
  };



  update = ()=>{
    mainApp.update();
    mainApp.draw();
    requestAnimationFrame(update);
  }

  onWindowResize = ()=>{
    mainApp.onWindowResize;
  }
})();
