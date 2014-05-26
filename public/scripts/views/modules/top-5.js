// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'text!templates/modules/top-5.html'], function($, _, Backbone, tplTop5) {
    'use strict';
    var Top5View;
    return Top5View = (function(_super) {
      __extends(Top5View, _super);

      function Top5View() {
        return Top5View.__super__.constructor.apply(this, arguments);
      }

      Top5View.prototype.el = '.module.top-5';

      Top5View.prototype.template = _.template(tplTop5);

      Top5View.prototype.initialize = function() {};

      Top5View.prototype.render = function() {
        this.$el.html(this.template());
        this.bind();
        this.fillGauges('shows');
        return this;
      };

      Top5View.prototype.totalAppearances = 0;

      Top5View.prototype.fillPercent = 0;

      Top5View.prototype.events = {
        'click .tabs li': 'onClick'
      };

      Top5View.prototype.onClick = function(evt) {
        var currentTab;
        if (!$(evt.currentTarget).hasClass('active')) {
          this.$el.find('li.active').removeClass('active');
          $(evt.currentTarget).addClass('active');
          currentTab = $(evt.currentTarget).data('tab');
          this.$el.find('section').removeClass('visible');
          this.$el.find('section#' + currentTab).addClass('visible');
          return this.fillGauges(currentTab);
        }
      };

      Top5View.prototype.getFillPercent = function(bar, type) {
        var _this;
        _this = this;
        this.totalAppearances = 0;
        this.fillPercent = 0;
        $('#' + type + ' .gauge span').each(function() {
          return _this.totalAppearances += parseInt($(this).data('appearances'));
        });
        return this.fillPercent = bar.data('appearances') * 100 / this.totalAppearances;
      };

      Top5View.prototype.fillGauges = function(type) {
        var _this;
        _this = this;
        return $('#' + type + ' .gauge span').each(function() {
          _this.getFillPercent($(this), type);
          $('#' + type + ' span.total').html('/' + _this.totalAppearances);
          $(this).css('width', 0);
          return $(this).animate({
            width: _this.fillPercent + '%'
          }, {
            duration: 500
          });
        });
      };

      return Top5View;

    })(Backbone.View);
  });

}).call(this);
