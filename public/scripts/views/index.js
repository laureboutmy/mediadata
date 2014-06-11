// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'mediadata', '../collections/topics', 'text!templates/index.html'], function($, _, Backbone, md, TopicsCollection, tplIndex) {
    'use strict';
    var IndexView;
    return IndexView = (function(_super) {
      __extends(IndexView, _super);

      function IndexView() {
        return IndexView.__super__.constructor.apply(this, arguments);
      }

      IndexView.prototype.el = '#main';

      IndexView.prototype.collection = null;

      IndexView.prototype.template = _.template(tplIndex);

      IndexView.prototype.name = null;

      IndexView.prototype.initialize = function() {
        this.collection = new TopicsCollection('http://api.mediadata.fr/alphabetical-index.php');
        return this.collection.fetch({
          success: (function(_this) {
            return function() {
              _this.collection = _this.collection.models[0].attributes;
              _this.render();
              _this.bind();
              return _this.onResize();
            };
          })(this)
        });
      };

      IndexView.prototype.bind = function() {
        $(window).on('scroll', this.stickNavigation).on('resize', this.onResize);
        return $('nav.alphabet li').on('click', this.scrollToLetter);
      };

      IndexView.prototype.unbind = function() {
        $(window).off('scroll', this.stickNavigation).off('resize', this.onResize);
        return $('nav.alphabet li').off('click', this.scrollToLetter);
      };

      IndexView.prototype.render = function() {
        document.body.scrollTop = document.documentElement.scrollTop = 0;
        this.$el.html(this.template(this.collection));
        md.Router.hideLoader();
        return this;
      };

      IndexView.prototype.destroy = function() {
        return this.unbind();
      };

      IndexView.prototype.scrollToLetter = function(e) {
        e.preventDefault();
        console.log($(this).data('letter'));
        $('nav.alphabet li.active').removeClass('active');
        $(this).addClass('active');
        return $('html, body').animate({
          scrollTop: $('h3[data-letter=' + $(this).data('letter') + ']').offset().top - 70 + 'px'
        });
      };

      IndexView.prototype.stickNavigation = function() {
        var letter;
        if ($(window).scrollTop() > $('header.introduction').outerHeight()) {
          $('nav.alphabet').addClass('fixed');
        } else {
          $('nav.alphabet').removeClass('fixed');
        }
        letter = null;
        _.each($('h3[data-letter]'), function(el) {
          if ($(el).offset().top - 200 < $(window).scrollTop()) {
            return letter = $(el).data('letter');
          }
        });
        if (letter) {
          $('nav.alphabet li.active').removeClass('active');
          return $('li[data-letter=' + letter + ']').addClass('active');
        }
      };

      IndexView.prototype.onResize = function() {
        return $('nav.alphabet').width($(window).width() - 80);
      };

      return IndexView;

    })(Backbone.View);
  });

}).call(this);
