function worker_function() {

  function gauss1( sigma, i,j, ic ) {
    if (sigma < 0.0001) return 1; // без гаусса попробуем тоже
    return (1.0 / (2 * Math.PI * sigma * sigma )) * Math.exp( (-1.0 / 2) * ( (i-ic)*(i-ic) + (j-ic)*(j-ic) ) / (sigma * sigma ) );
  }

  var gausstable;

  function gauss( sigma, i1,j1, ic ) {
    if (!gausstable) {
       gausstable = [];
       var nn = ic*2+1;
       for (var i=0; i<nn; i++) {
          var jline = [];
          for (var j=0; j<nn; j++) jline.push( gauss1( sigma,i,j,ic ) );
          gausstable.push( jline );
       }
//       console.log("computed gaustable",gausstable);
    }
    return gausstable[i1][j1];
  }


 function computeline( y, x0,x1, pixels, w,h,n,stat, sigma) // возвращает массив w признаков для пикселей pixels только для строки y
  {
     gausstable = 0;

     var nn = 2*n+1;

     var res = [ [], [], [] ];

//     console.log("computeline called. y=",y);

     if (stat.length == 0) {
//       console.log("stat empty - exiting");
       for (var x=0; x<w; x++) { res[0].push( undefined );res[1].push( undefined );res[2].push( undefined ); }
       return res;
     }

     if (y < n || y >= h-n) {
//       console.log("y not in compute range - exiting");
       for (var x=0; x<w; x++) res.push( -1 );
       return res;
     }

     for (var x=0; x<w; x++) {
       if (x < n || x >= w-n || x<x0 || x>=x1) {
         res[0].push(undefined);res[1].push(undefined);res[2].push(undefined);
         continue;
       }
//       res.push( x % 3 );

       var getpix = function( i,j ) {
         return pixels[ (y+j-n)*w+(x+i-n) ];
       }

       var square_types = [0,0,0];

       for (var i=0; i<nn; i++)
       for (var j=0; j<nn; j++) {

         var getstat = function(grey,t) {
           return stat[ j*nn +i ][ grey*3 +t ];
         }

         var bright = getpix( i,j );
         var t = [getstat( bright,0),getstat( bright,1),getstat( bright,2) ];
         var sumstat = t[0]+t[1]+t[2];  // var sumstat = getstat( bright,0 ) + getstat( bright,1 ) + getstat( bright,2 );

         var gaussval = gauss( sigma, i, j, n );
         for (var k=0; k<3; k++) {
           var estimate_type = t[k] / sumstat;  // var estimate_type = getstat( bright, k ) / sumstat;
           square_types[k] += estimate_type * gaussval; // gauss( sigma, i, j, n );
         }
       }
       res[0].push( square_types[0] );
       res[1].push( square_types[1] );
       res[2].push( square_types[2] );
     } // x

     //console.log("RES=",res);
     return res;
  }



onmessage = function(e) {
//  console.log('Message received from main script');
  var res;
  for (var i=0; i<e.data.tasks; i++) {
    with (e.data) res = computeline( y+i,  x0, x1, pixels, w, h, n, stat, sigma);
  //var workerResult = 'Result: ' + (e.data[0] * e.data[1]);
  //console.log('Posting message back to main script');
    postMessage({ res: res, x0: e.data.x0, x1: e.data.x1, y: e.data.y+i });
  }
}

}

// This is in case of normal worker start
// "window" is not defined in web worker
// so if you load this file directly using `new Worker`
// the worker code will still execute properly
if(window!=self)
  worker_function();