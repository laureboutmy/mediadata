// Generated by CoffeeScript 1.7.1
(function() {
  define(['jquery', 'underscore', 'backbone', 'mediadata', 'text!templates/home.html'], function($, _, Backbone, md, tplHome) {
    'use strict';
    var HomeView;
    return HomeView = Backbone.View.extend({
      el: '#main',
      template: _.template(tplHome),
      initialize: function() {
        md.Status['currentView'] = 'home';
        return this.render();
      },
      bind: function() {
        $('a.discover').on('click', this.scrollToTutorial);
        return $('ul.slider li').on('click', this.updateSlider);
      },
      scrollToTutorial: function(e) {
        e.preventDefault();
        return $('html, body').animate({
          scrollTop: $('.tutorial').offset().top + 'px'
        });
      },
      destroy: function() {
        return this.unbind();
      },
      unbind: function() {
        $('a.discover').off('click', this.scrollToTutorial);
        return $('ul.slider li').off('click', this.updateSlider);
      },
      render: function() {
        ga('send', 'pageview', '/');
        document.body.scrollTop = document.documentElement.scrollTop = 0;
        this.$el.html(this.template());
        this.bind();
        md.Router.hideLoader();
        return this;
      },
      updateSlider: function() {
        var index;
        index = $(this).index();
        $('div.slider').find('.visible').removeClass('visible');
        $('ul.slider').find('.visible').removeClass('visible');
        $(this).addClass('visible');
        return $('div.slider').find('img').eq(index).addClass('visible');
      }
    });
  });

}).call(this);
