// Generated by CoffeeScript 1.7.1
(function() {
  var height, margin, person, width, x, y;

  person = 'anne-hidalgo';

  margin = {
    top: 60,
    right: 20,
    bottom: 60,
    left: 40
  };

  width = 1020;

  height = 355;

  x = d3.scale.ordinal().rangeRoundBands([0, width], .1);

  y = d3.scale.linear().range([height, 0]);

  d3.json('person-' + person + '.json', function(error, data) {
    var bar_svg, d, i, yAxis, _i, _len, _ref;
    if (error) {
      return console.warn(error);
    }
    _ref = data.channels;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      d = _ref[i];
      d.channelCount = +d.channelCount;
    }
    x.domain(data.channels.map(function(d) {
      return d.channelName;
    }));
    y.domain([
      0, d3.max(data.channels, function(d) {
        return d.channelCount;
      })
    ]);
    yAxis = d3.svg.axis().scale(y).orient('left').ticks(4).tickSize(-width, 0, 0);
    bar_svg = d3.select('body').append('svg').attr('id', 'barchart').attr('width', width).attr('height', height + margin.top + margin.bottom);
    bar_svg.append('g').attr('class', 'grid').attr("transform", "translate(0,60)").call(yAxis);
    bar_svg.selectAll('g.bar-g').data(data.channels).enter().append('g').attr('class', 'bar-g').attr('transform', 'translate(0,' + margin.top + ')').append('rect').attr('class', 'bar').attr('x', function(d, i) {
      return x(d.channelName) + 27;
    }).attr('width', 35).attr('y', function(d) {
      return y(d.channelCount);
    }).attr('height', function(d, i) {
      return height - y(d.channelCount);
    });
    bar_svg.selectAll('g.bar-g').data(data.channels).append('image').attr('xlink:href', function(d) {
      return d.channelLogo;
    }).attr('height', 80).attr('width', 70).attr('x', function(d, i) {
      return x(d.channelName) + 10;
    }).attr('y', height);
    bar_svg.append('filter').attr('id', 'f1').attr('width', '150%').attr('height', '150%').append('feOffset').attr('result', 'offOut').attr('in', 'SourceAlpha').attr('dx', 0).attr('dy', 3);
    bar_svg.select('filter').append('feGaussianBlur').attr('stdDeviation', 1).attr('result', 'blur');
    bar_svg.selectAll('g.bar-g').append('rect').data(data.channels).attr('filter', 'url(#f1)').attr('class', 'tooltip shadow').attr('height', 45).attr('width', 76).attr('x', function(d, i) {
      return x(d.channelName) + 5;
    }).attr('y', function(d) {
      return y(d.channelCount) - 55;
    }).attr('rx', 20).attr('ry', 25);
    bar_svg.selectAll('g.bar-g').append('rect').data(data.channels).attr('class', 'tooltip').attr('height', 45).attr('width', 76).attr('x', function(d, i) {
      return x(d.channelName) + 5;
    }).attr('y', function(d) {
      return y(d.channelCount) - 55;
    }).attr('rx', 20).attr('ry', 25);
    bar_svg.selectAll('g.bar-g').append('text').data(data.channels).attr('text-anchor', 'middle').attr('class', 'tooltip name').attr('x', function(d, i) {
      return x(d.channelName) + (x.rangeBand() / 2) - 3;
    }).attr('y', function(d) {
      return y(d.channelCount) - 35;
    }).text(function(d) {
      return d.channelName;
    });
    bar_svg.selectAll('g.bar-g').append('text').data(data.channels).attr('text-anchor', 'middle').attr('class', 'tooltip count').attr('x', function(d, i) {
      return x(d.channelName) + (x.rangeBand() / 2) - 3;
    }).attr('y', function(d) {
      return y(d.channelCount) - 20;
    }).html(function(d) {
      return d.channelCount;
    });
  });

}).call(this);
