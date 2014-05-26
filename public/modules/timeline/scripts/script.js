// Generated by CoffeeScript 1.7.1

/* Setup */

(function() {
  var area, chart, height, margin, maxXValues, maxYValues, minMaxX, minMaxY, minXValues, minYValues, parseDate, person1, person2, svg, valueline, width, x, xAxis, y, yAxis, yGrid;

  person1 = 'segolene-royal';

  person2 = 'christiane-taubira';

  minXValues = [];

  minYValues = [];

  maxXValues = [];

  maxYValues = [];

  minMaxX = [];

  minMaxY = [];

  parseDate = d3.time.format('%Y-%m').parse;

  margin = {
    top: 20,
    right: 20,
    bottom: 30,
    left: 50
  };

  width = 960;

  height = 300;

  svg = d3.select('body').append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  x = d3.time.scale().range([0, width]);

  y = d3.scale.linear().range([height, 0]);

  xAxis = d3.svg.axis().scale(x).orient('bottom').ticks(d3.time.year, 2);

  yAxis = d3.svg.axis().scale(y).orient('left').ticks(5);

  area = d3.svg.area().x(function(d) {
    return x(d.mentionDate);
  }).y0(height).y1(function(d) {
    return y(d.mentionCount);
  });

  valueline = d3.svg.line().x(function(d) {
    return x(d.mentionDate);
  }).y(function(d) {
    return y(d.mentionCount);
  });

  yGrid = function() {
    return d3.svg.axis().scale(y).orient('left').ticks(5);
  };


  /* Make the chart */

  chart = {
    findMinMaxValues: function(person) {
      d3.json('person-' + person + '.json', function(error, data) {
        var d, i, _i, _len, _ref;
        _ref = data.person.timelineMentions;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          d = _ref[i];
          d.index = i;
          d.mentionDate = parseDate(d.mentionDate);
          d.mentionCount = +d.mentionCount;
        }
        minXValues.push(d3.min(data.person.timelineMentions, function(d) {
          return d.mentionDate;
        }));
        maxXValues.push(d3.max(data.person.timelineMentions, function(d) {
          return d.mentionDate;
        }));
        minYValues.push(d3.min(data.person.timelineMentions, function(d) {
          return d.mentionCount;
        }));
        return maxYValues.push(d3.max(data.person.timelineMentions, function(d) {
          return d.mentionCount;
        }));
      });
      return console.log(person + ' loaded!');
    },
    appendChart: function(person, datasetnumber) {
      return d3.json('person-' + person + '.json', function(error, data) {
        var d, i, _i, _len, _ref;
        _ref = data.person.timelineMentions;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          d = _ref[i];
          d.index = i;
          d.mentionDate = parseDate(d.mentionDate);
          d.mentionCount = +d.mentionCount;
        }
        if (datasetnumber === 1) {
          svg.append('g').attr('class', 'grid').call(yGrid().tickSize(-width, 0, 0).tickFormat(''));
        }
        svg.append('path').attr('class', 'line' + datasetnumber).attr('d', valueline(data.person.timelineMentions));
        svg.append('path').datum(data.person.timelineMentions).attr('class', 'area' + datasetnumber).attr('d', area);
        svg.selectAll('circle' + datasetnumber).data(data.person.timelineMentions).enter().append('circle').attr('class', 'circle' + datasetnumber).attr('r', 3.5).attr('cx', function(d) {
          return x(d.mentionDate);
        }).attr('cy', function(d) {
          return y(d.mentionCount);
        });
        if (datasetnumber === 1) {
          svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').call(xAxis);
          svg.append('g').attr('class', 'y axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end');
        }
        return console.log(person + ' drawn!');
      });
    },
    drawChart: function(person1, person2) {
      return d3.json('person-' + person1 + '.json', function(error, data) {
        var d, i, maxXValue, maxYValue, minXValue, minYValue, _i, _len, _ref;
        _ref = data.person.timelineMentions;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          d = _ref[i];
          d.index = i;
          d.mentionDate = parseDate(d.mentionDate);
          d.mentionCount = +d.mentionCount;
        }
        minXValue = d3.min(minXValues);
        maxXValue = d3.max(maxXValues);
        minMaxX.push(minXValue, maxXValue);
        minYValue = d3.max(minYValues);
        maxYValue = d3.max(maxYValues);
        minMaxY.push(minYValue, maxYValue);
        x.domain(minMaxX);
        y.domain(minMaxY);
        chart.appendChart(person1, 1);
        if (person2) {
          return chart.appendChart(person2, 2);
        }
      });
    },
    exec: function() {
      if (person2) {
        chart.findMinMaxValues(person2);
        chart.findMinMaxValues(person1);
        return chart.drawChart(person1, person2);
      } else {
        chart.findMinMaxValues(person1);
        return chart.drawChart(person1);
      }
    }
  };


  /* sloppy ? */

  queue().defer(d3.json, 'person-' + person1 + '.json').defer(d3.json, 'person-' + person2 + '.json').await(chart.exec());

}).call(this);
