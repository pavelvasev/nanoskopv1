Item {
    OpacityParam {}

    property var htmlTagName: "canvas"
    id: rim

    property var input: [ [], [], [] ]
    
    onInputChanged: loadinput()
    
    property var imd
    function loadinput() {
      if (width <= 0 || height <= 0) return;
      rim.dom.width = width; rim.dom.height = height;

      var ctx = rim.dom.getContext('2d');
      if (!imd) imd = ctx.createImageData( width, height );
      
      var imddata = imd.data;
      var pr = input;

      var cnt = width*height;
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
