Item {
  id: bc

  property var greypixels // 1d array
  property var w
  property var h

  property var n: 16
  property var stat: [] // массив (2n+1)^2 строк (цикл j,j), каждая строка есть массив в упаковке [0..255][3] для соотв i,j

  //// output
  property var output: [] // массив из 3 элементов, каждый элемент есть одномерный массив w*h чисел

  //// internal

  property var sigma: sigp.value

  Param {
    text: "sigma"
    min: 0
    max: 20
    step: 0.1
    value: 10
    id: sigp
    Text {
      text: "<a target='_blank' href='http://viewlang.ru/code/scene.html?s=" + Qt.resolvedUrl( "../gauss.vl")+ "#{\"params\":{\"sigma\":" + sigp.value.toString() + "}}'>справка по сигме</a>"
    }
  }

  property var workers
  property var wpath: Qt.resolvedUrl("worker.js")

  Component.onCompleted: {
    console.log("writing script..");
    document.write("<script src='"+wpath+"'></script>");
  }

  // output
  function comp( y, callback ) {
    var cc =  navigator.hardwareConcurrency;

    if (!workers) {
      if (typeof(worker_function) == "undefined") { console.error("worker_function is not defined, exiting"); return []; }
      var acc = [];
      var urla = URL.createObjectURL(new Blob(["("+worker_function.toString()+")()"], {type: 'text/javascript'}));
      // https://stackoverflow.com/questions/21408510/chrome-cant-load-web-worker/33432215#33432215
      for (var i=0; i<cc; i++) acc.push( new Worker(urla) );
      workers = acc;
    }

    var finished = 0;
    //var res = new Array( w );
    var ttt = 20;

    for (var i=0; i<cc; i++) {
      var worker = workers[i];
      //console.log("sending task to worker",i,y);
      worker.postMessage( { y:y+i*ttt, pixels: greypixels, w: w, h: h, n: n, stat: stat, sigma: sigma, x0: 0, x1: w, tasks: ttt });
      worker.onmessage = function(e) {
        finished++;
        callback( e.data.res, e.data.y );
        if (finished == cc*ttt) callback( undefined, cc*ttt );
      }
    }
  }

  Param {
     id: yp
     min: 0
     max: bc.h -1
     text: "y-compute"

     onValueChanged: {
       var yy = value;
       var w = bc.w;
       bc.comp( yy, function(line,y) {
         //console.log("ckb");
         if (line) { // пришли данные
           var r = output;
           for (var x=0; x<w; x++) {
              r[0][ y*w+x ] = line[0][x];
              r[1][ y*w+x ] = line[1][x];
              r[2][ y*w+x ] = line[2][x];
           }
         } else { // заказ выполнен
           //console.log("bayes signal outputchanged",y);
           setTimeout( function() {             
             //bc.outputChanged();

             if (cbcompute.value == 1 && value < bc.h+y) value = value+y;
             bc.output = bc.output;
           }, 50 );
         }
       });
     }
   }

  onWChanged: clearprizn();
  onHChanged: clearprizn();

  function clearprizn() {
    output = [new Array( bc.h * bc.w ),new Array( bc.h * bc.w ),new Array( bc.h * bc.w )];
  }

   CheckBoxParam {
      text: "Вычислять"
      id: cbcompute
      onValueChanged: if (value == 1) yp.valueChanged();
   }

   Button {
     property var tag: 'left'
     text: "ВЫЧИСЛИТЬ"
     onClicked: { yp.value=0; cbcompute.value=0; cbcompute.value=1;}
     enabled: greypixels.length > 0
   }


}