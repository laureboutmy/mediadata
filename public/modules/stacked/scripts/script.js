// Generated by CoffeeScript 1.7.1
(function() {
  var drawContent, draw_axis, draw_tooltip, getScale, height, margin, marginRect, person1, person2, stacked_data, svg, width, x, y;

  person1 = 'anne-hidalgo';

  person2 = 'christiane-taubira';

  margin = {
    top: 60,
    right: 20,
    bottom: 60,
    left: 40
  };

  width = 1020;

  height = 355;

  marginRect = 25;

  stacked_data = void 0;

  x = d3.scale.ordinal().rangeRoundBands([0, width]);

  y = d3.scale.linear().range([0, height]);

  svg = function() {
    return d3.select('body').append('svg').attr('id', 'stacked').attr('width', width).attr('height', height + margin.top + margin.bottom);
  };

  getScale = function(data) {
    stacked_data = d3.layout.stack()(data.channelMap.map(function(data_nd) {
      return data.channelDatas.map(function(d) {
        return {
          x: d.channelName,
          y: +d[data_nd]
        };
      });
    }));
    x.domain(stacked_data[0].map(function(d) {
      return d.x;
    }));
    return y.domain([
      0, d3.max(stacked_data[stacked_data.length - 1], function(d) {
        return d.y0 + d.y;
      })
    ]);
  };

  drawContent = function(data) {
    d3.select('#stacked').selectAll('g.stacked-g').data(stacked_data).enter().append('g').attr('class', function(d, i) {
      return 'stacked-g person' + (i + 1) + " " + data.channelMap[i];
    }).attr('transform', 'translate(0,' + (height + margin.top) + ')');
    d3.select('#stacked').selectAll('g.stacked-g').selectAll('g').data(Object).enter().append('g').append('rect').attr('x', function(d) {
      return x(d.x) + 33;
    }).attr('y', function(d) {
      return -y(d.y0) - y(d.y);
    }).attr('height', function(d) {
      return y(d.y);
    }).attr('width', 35);
    return d3.select('#stacked').select('g.person1').selectAll('image').data(data.channelDatas).enter().append('image').attr('xlink:href', function(d) {
      return d.channelLogo;
    }).data(Object).attr('height', 80).attr('width', 70).attr('x', function(d) {
      return x(d.x) + 15;
    }).attr('y', 0);
  };

  draw_tooltip = function(data) {
    var i, total_height;
    total_height = [];
    i = 0;
    while (i < stacked_data[0].length) {
      total_height[i] = y(stacked_data[0][i].y) + y(stacked_data[1][i].y);
      ++i;
    }
    d3.select('#stacked').append('filter').attr('id', 'f1').attr('width', '150%').attr('height', '150%').append('feOffset').attr('result', 'offOut').attr('in', 'SourceAlpha').attr('dx', 0).attr('dy', 3);
    d3.select('#stacked').select('filter').append('feGaussianBlur').attr('stdDeviation', 1).attr('result', 'blur');
    d3.select('#stacked').selectAll('g.stacked-g g').append('rect').attr('filter', 'url(#f1)').attr('class', 'tooltip shadow').attr('height', 45).attr('width', 100).attr('x', function(d) {
      return x(d.x);
    }).attr('y', function(d, i) {
      return -y(d.y0) - (typeof total_height[i] === 'undefined' ? y(d.y) : total_height[i]) - 55;
    }).attr('rx', 20).attr('ry', 25);
    console.log('total_height -->', total_height);
    d3.select('#stacked').selectAll('g.stacked-g g').append('rect').attr('class', 'tooltip').attr('height', 45).attr('width', 100).attr('x', function(d) {
      return x(d.x);
    }).attr('y', function(d, i) {
      return -y(d.y0) - (typeof total_height[i] === 'undefined' ? y(d.y) : total_height[i]) - 55;
    }).attr('rx', 20).attr('ry', 25);
    d3.select('#stacked').selectAll('g.stacked-g g').append('text').attr('text-anchor', 'middle').attr('x', function(d) {
      return x(d.x) + 45;
    }).attr('y', function(d, i) {
      return -y(d.y0) - (typeof total_height[i] === 'undefined' ? y(d.y) : total_height[i]) - 33;
    }).text(function(d) {
      return d.x;
    });
    return d3.select('#stacked').selectAll('g.stacked-g g').append('text').attr('text-anchor', 'middle').attr('x', function(d) {
      return x(d.x) + 45;
    }).attr('y', function(d, i) {
      return -y(d.y0) - (typeof total_height[i] === 'undefined' ? y(d.y) : total_height[i]) - 18;
    }).text(function(d) {
      return d.y;
    });
  };

  draw_axis = function() {
    var yAxis;
    yAxis = d3.svg.axis().scale(y).orient('left').ticks(4).tickSize(-width, 0, 0);
    return d3.select('#stacked').append('g').attr('class', 'grid').attr("transform", "translate(0,60)").call(yAxis);
  };

  d3.json('person-' + person1 + "-" + person2 + '.json', function(error, data) {
    if (error) {
      return console.warn(error);
    }
    svg();
    draw_axis();
    getScale(data);
    drawContent(data);
    return draw_tooltip(data);
  });

}).call(this);
