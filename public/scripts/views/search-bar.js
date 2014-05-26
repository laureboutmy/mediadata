// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', '../collections/topics', '../models/topic', 'text!templates/search-bar.html'], function($, _, Backbone, TopicsCollection, TopicModel, tplSearchbar) {
    'use strict';
    var SearchbarView;
    return SearchbarView = (function(_super) {
      __extends(SearchbarView, _super);

      function SearchbarView() {
        return SearchbarView.__super__.constructor.apply(this, arguments);
      }

      SearchbarView.prototype.el = '#search-bar';

      SearchbarView.prototype.collection = null;

      SearchbarView.prototype.template = _.template(tplSearchbar);

      SearchbarView.prototype.initialize = function(options) {
        return this.collection = new TopicsCollection();
      };

      SearchbarView.prototype.data = {
        topic1: null,
        topic2: null
      };

      SearchbarView.prototype.render = function(options) {
        var _this;
        _this = this;
        console.log('hey', options);
        this.collection.fetch({
          success: function() {
            _this.collection = _this.collection.models[0].attributes.results;
            _this.data.topic1 = _.where(_this.collection, {
              slug: 'segolene-royal'
            })[0];
            console.log(_this.data);
            _this.$el.html(_this.template(_this.data));
            return _this.bind();
          }
        });
        return this;
      };

      SearchbarView.prototype.inputs = 'form.search input';

      SearchbarView.prototype.events = {
        'click .compare': 'compare',
        'click div.name button.edit': 'edit',
        'blur form.search input': 'stopEditing',
        'click .delete': 'delete'
      };

      SearchbarView.prototype.bind = function() {
        var _this;
        _this = this;
        $(_this.inputs).on('keyup', {
          context: this
        }, _this.keyup);
        return $(_this.inputs).on('keydown', {
          context: this
        }, _this.keydown);
      };

      SearchbarView.prototype.compare = function(evt) {
        return this.$el.addClass('comparison').find('section.person').addClass('visible');
      };

      SearchbarView.prototype["delete"] = function(evt) {
        if (this.$el.hasClass('comparison')) {
          this.$el.removeClass('comparison');
          return $(evt.currentTarget).parent().parent().removeClass('visible');
        } else {
          return this.$el.addClass('search');
        }
      };

      SearchbarView.prototype.edit = function(evt) {
        $(evt.target).parent().find('form.search').addClass('visible').find('input').focus();
        return $(this).parent().find('form.search').addClass('visible').find('input').focus();
      };

      SearchbarView.prototype.stopEditing = function(evt) {};

      SearchbarView.prototype.onResize = function() {};

      SearchbarView.prototype.currentText = null;

      SearchbarView.prototype.hasChanged = function(keyword) {
        return this.current !== keyword;
      };

      SearchbarView.prototype.keyup = function(evt) {
        var keyword, _this;
        _this = evt.data.context;
        keyword = $(this).val();
        console.log(_this.collection);
        if (_this.hasChanged(keyword)) {
          _this.currentText = keyword;
          return _this.filter(keyword);
        }
      };

      SearchbarView.prototype.keydown = function(evt) {
        var _this;
        _this = evt.data.context;
        if (evt.keyCode === 38) {
          _this.move(-1, this);
        }
        if (evt.keyCode === 40) {
          _this.move(+1, this);
        }
        if (evt.keyCode === 13) {
          evt.preventDefault();
          _this.submit(this);
        }
        if (evt.keyCode === 27) {
          return _this.hide();
        }
      };

      SearchbarView.prototype.move = function(position, input) {
        var current, index, siblings;
        current = $(input).parent().find('ul').children('.active');
        siblings = $(input).parent().find('ul').children();
        index = current.index() + position;
        if (siblings.eq(index).length) {
          current.removeClass('active');
          return siblings.eq(index).addClass('active');
        }
      };

      SearchbarView.prototype.submit = function(input) {
        var selected;
        console.log(input);
        selected = $(input).parent().find('ul').children('.active');
        console.log(selected.data('slug'));
        return $(input).parent().parent().find('h1').html(selected.html());
      };

      SearchbarView.prototype.filter = function(keyword) {
        return keyword = keyword.toLowerCase();
      };

      return SearchbarView;

    })(Backbone.View);
  });

}).call(this);
