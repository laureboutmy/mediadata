// Generated by CoffeeScript 1.7.1
(function() {
  $(document).ready(function() {
    var fillGauges, fillPercent, getFillPercent, totalAppearances;
    totalAppearances = 0;
    fillPercent = 0;
    getFillPercent = function(bar, type) {
      totalAppearances = 0;
      fillPercent = 0;
      $('#' + type + ' .gauge span').each(function() {
        return totalAppearances += parseInt($(this).data('appearances'));
      });
      return fillPercent = bar.data('appearances') * 100 / totalAppearances;
    };
    fillGauges = function(type) {
      return $('#' + type + ' .gauge span').each(function() {
        getFillPercent($(this), type);
        $('#' + type + ' span.total').html('/' + totalAppearances);
        $(this).css('width', 0);
        return $(this).animate({
          width: fillPercent + '%'
        }, {
          duration: 500
        });
      });
    };
    fillGauges('channels');
    fillGauges('shows');
    return $('.tab').on('click', function() {
      var tabclicked;
      if (!$(this).hasClass('active')) {
        $('.tab').removeClass('active');
        $(this).addClass('active');
        tabclicked = $(this).data('tab');
        $('section').addClass('hidden');
        $('section#' + tabclicked).removeClass('hidden');
        fillGauges('channels');
        return fillGauges('shows');
      }
    });
  });

}).call(this);