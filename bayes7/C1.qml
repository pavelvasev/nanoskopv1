import components.creative_points 1.0

Item {
  id: vc
  property var input: []

  property bool enabled: true;

  function compute( channels, f1, farg ) {
    if (!channels || channels.length == 0 || !enabled) return [ input[0] || [],0,0 ];
   
    var min = 10e10;
    var max = 0;
    var res = [];
    var len = channels[0].length;

    var acc = {};
    for (var i=0; i<len; i++) {
      var value = f1( channels, i, farg, acc );
      res.push( value );
      if (min > value) min = value;
      if (max < value) max = value;
    }

    return [res,min,max];
  }

  property var q: compute( input, func, farg );
  property var func
  property var farg

  property var output: q[0]
  property var min: q[1]
  property var max: q[2]

}
