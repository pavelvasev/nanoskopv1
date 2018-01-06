Item {

    property var htmlTagName: "canvas"
    id: rim

    property var w: 0
    property var h: 0
    width: w*scale
    height: h*scale
    property var scale: 1

    onScaleChanged: {
      rim.dom.style.transform = "scale("+scale+","+scale+")";
      rim.dom.style.transformOrigin = "0 0"
    }

    // три канала
    property var input: [ [], [], [] ]
    
    onInputChanged: loadinput()
    
    property var imd
    function loadinput() {
      if (w <= 0 || h <= 0 || isNaN(w) || isNaN(h)) return;
      rim.dom.width = w; rim.dom.height = h;

      var ctx = rim.dom.getContext('2d');
      if (!imd) imd = ctx.createImageData( w, h );
      
      var imddata = imd.data;
      var pr = input;

      var cnt = w*h;
      for (var i=0,q=0; i<cnt; i++) {
        imddata[4*i]   = pr[0][i]   || 0;
        imddata[4*i+1] = pr[1][i] || 0;
        imddata[4*i+2] = pr[2][i] || 0;
        imddata[4*i+3] = 255;
      }
      
      ctx.putImageData( imd,0,0 );
     
      //dataurl = rim.dom.toDataURL();
    }

    property var dataurl
  }
