// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'mediadata', '../collections/topics', '../models/topic', 'text!templates/search-bar.html'], function($, _, Backbone, md, TopicsCollection, TopicModel, tplSearchbar) {
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
        md.Collections['topics'] = new TopicsCollection();
        return md.Collections['topics'].fetch({
          success: (function(_this) {
            return function() {
              md.Collections['topics'] = md.Collections['topics'].models[0].attributes.searchResults;
              _this.render(options);
              return _this.bind();
            };
          })(this)
        });
      };

      SearchbarView.prototype.topics = {
        topic1: null,
        topic2: null
      };

      SearchbarView.prototype.inputs = 'form.search input';

      SearchbarView.prototype.currentText = null;

      SearchbarView.prototype.render = function(options) {
        if (options.name1) {
          this.topics.topic1 = _.where(md.Collections['topics'], {
            slug: options.name1
          })[0];
        }
        if (options.name2) {
          this.topics.topic2 = _.where(md.Collections['topics'], {
            slug: options.name2
          })[0];
        }
        this.$el.html(this.template(this.topics));
        if (this.topics.topic1 && this.topics.topic2) {
          this.$el.addClass('comparison').find('section.person').addClass('visible');
        }
        return this;
      };

      SearchbarView.prototype.events = {
        'click .compare': 'compare',
        'click .delete': 'delete',
        'click ul.topics li': 'submit',
        'click div.name button.edit': 'edit'
      };

      SearchbarView.prototype.bind = function() {
        var _this;
        _this = this;
        $(_this.inputs).on('keyup', {
          context: this
        }, _this.keyup);
        $(_this.inputs).on('keydown', {
          context: this
        }, _this.keydown);
        return $(_this.inputs).on('blur', {
          context: this
        }, _this.stop);
      };

      SearchbarView.prototype.update = function(name, nb) {
        var el;
        if (nb = 1) {
          this.topics.topic1 = _.where(md.Collections['topics'], {
            slug: name
          })[0];
          el = $('#name-1').parent().parent().find('h1');
          el.find('span.name').html(this.topics.topic1.name);
          el.find('span.role').html(this.topics.topic1.role);
          return el.find('.img img').attr('src', this.topics.topic1.picture);
        } else {
          this.topics.topic2 = _.where(md.Collections['topics'], {
            slug: name
          })[0];
          el = $('#name-2').parent().parent().find('h1');
          el.find('span.name').html(this.topics.topic2.name);
          el.find('span.role').html(this.topics.topic2.role);
          return el.find('.img img').attr('src', this.topics.topic2.picture);
        }
      };

      SearchbarView.prototype.compare = function() {
        return this.$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus();
      };

      SearchbarView.prototype["delete"] = function(evt) {
        console.log(Backbone.history.fragment);
        if (this.$el.hasClass('comparison')) {
          this.$el.removeClass('comparison');
          $(evt.currentTarget).parent().parent().removeClass('visible');
        } else {
          this.$el.addClass('search');
        }
        return $(evt.currentTarget).parent().find('h1').html('Cliquez pour rechercher');
      };

      SearchbarView.prototype.edit = function(evt) {
        return $(evt.currentTarget).parent().find('form.search').addClass('visible').find('input').focus();
      };

      SearchbarView.prototype.stop = function(evt) {
        if (evt) {
          return evt.data.context.$el.find('form.search.visible').removeClass('visible');
        } else {
          return this.$el.find('form.search.visible').removeClass('visible');
        }
      };

      SearchbarView.prototype.onResize = function() {};

      SearchbarView.prototype.hasChanged = function(keyword) {
        return this.currentText !== keyword;
      };

      SearchbarView.prototype.keyup = function(evt) {
        var keyword, _this;
        console.log('KEYUP');
        _this = evt.data.context;
        keyword = $(this).val();
        if (_this.hasChanged(keyword) && keyword.length !== 0) {
          _this.currentText = keyword;
          return _this.renderResults($(this), _this.filter(keyword));
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
          _this.submit(null, this);
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

      SearchbarView.prototype.submit = function(evt, input) {
        var selected;
        if (evt) {
          selected = $(evt.currentTarget);
          input = selected.parent().parent().find('input');
        } else {
          selected = $(input).parent().find('ul').children('.active');
        }
        $(input).parent().parent().find('h1').html(selected.html());
        if (this.$el.hasClass('comparison')) {
          if ($(input).has('#name-2')) {
            this.update(selected.data('slug'), 2);
            md.Router.navigate(this.topics.topic1.slug + '/' + selected.data('slug'));
            md.Router.getComparison(this.topics.topic1.slug, selected.data('slug'));
          } else if ($(input).has('#name-1')) {
            this.update(selected.data('slug'), 1);
            md.Router.navigate(selected.data('slug') + '/' + this.topics.topic2.slug);
            md.Router.getComparison(selected.data('slug'), this.topics.topic2.slug);
          }
        } else {
          if (this.$el.hasClass('search')) {
            this.$el.removeClass('search');
          }
          this.update(selected.data('slug'), $(input).attr('id').substring(5, 6));
          md.Router.navigate(selected.data('slug'));
          md.Router.getPerson(selected.data('slug'));
        }
        this.stop();
        return this.bind();
      };

      SearchbarView.prototype.filter = function(keyword) {
        keyword = keyword;
        return _.filter(md.Collections['topics'], function(topic) {
          return topic.name.toLowerCase().substring(0, keyword.length) === keyword;
        });
      };

      SearchbarView.prototype.renderResults = function(input, results) {
        var ul;
        ul = input.parent().find('ul').html('');
        return _.each(results, function(result) {
          var el;
          el = $('<li>').data('slug', result.slug).append($('<div>').attr('class', 'img').append($('<img>').attr('src', 'images/topic--damien-cornu.jpg')), result.name);
          return ul.append(el);
        });
      };

      return SearchbarView;

    })(Backbone.View);
  });

}).call(this);
