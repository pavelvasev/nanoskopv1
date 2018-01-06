Image {
  // input
  property var file

  // output
  property var w:0
  property var h:0
  property var pixels: []

  // internal
  id: qimg
  visible: false
  onStatusChanged: if (status == Image.Ready) { setup( ) }

  onFileChanged: {
      if (file instanceof File) {
        var fr = new FileReader();
        fr.onload = function () {
            source = fr.result;
        }
        fr.readAsDataURL(file);
      }
      else source = file;
    }


  function setup()
  {
    var img = qimg.dom.firstChild;
    if (!img) return;

    w=img.naturalWidth;
    h=img.naturalHeight;
    if (w==0 ) return;
    console.log("imagetoarray: setting up..");

    var canvas = document.createElement('canvas');
    canvas.width = w; canvas.height = h;
    var ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0, w, h);

    var imd = ctx.getImageData(0, 0, w, h);

    var acc = [];
    var len = w*h*4;
    for (var i=0; i<len; i+=4)
       acc.push( Math.max( imd.data[ i ], Math.max( imd.data[ i+1 ], imd.data[ i+2 ] ) ) );

    pixels = acc;
    console.log("pixels len=",pixels.length );
  }

}