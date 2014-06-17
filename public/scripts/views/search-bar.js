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

      SearchbarView.prototype.topics = {
        topic1: null,
        topic2: null
      };

      SearchbarView.prototype.inputs = 'form.search input';

      SearchbarView.prototype.currentText = null;

      SearchbarView.prototype.bool = false;

      SearchbarView.prototype.initialize = function(options) {
        console.log('yohoho');
        this.collection = new TopicsCollection();
        return this.collection.fetch({
          success: (function(_this) {
            return function() {
              _this.collection = _this.collection.models[0].attributes.searchResults;
              return _this.render(options);
            };
          })(this)
        });
      };

      SearchbarView.prototype.render = function(options) {
        if (options.name1) {
          this.topics.topic1 = _.where(this.collection, {
            slug: options.name1
          })[0];
        }
        if (options.name2) {
          this.topics.topic2 = _.where(this.collection, {
            slug: options.name2
          })[0];
        }
        if (options.name1 && !options.name2) {
          this.topics.topic2 = null;
        }
        if (options.name2 && !options.name1) {
          this.topics.topic1 = null;
        }
        if (!options.name2 && !options.name1) {
          this.topics.topic1 = null;
          this.topics.topic2 = null;
        }
        if (options.isSearch) {
          this.topics['isSearch'] = true;
        } else {
          this.topics['isSearch'] = false;
        }
        this.$el.find('#search').html(this.template(this.topics));
        if (this.topics.topic1 && this.topics.topic2) {
          this.$el.addClass('comparison').find('section.person').addClass('visible');
        } else if (this.topics['isSearch']) {
          this.$el.removeClass('comparison').addClass('search');
        } else {
          this.$el.removeClass('search');
          this.$el.removeClass('comparison');
        }
        this.bind();
        return this;
        return {
          'click ul.topics li': 'submit'
        };
      };

      SearchbarView.prototype.bind = function() {
        var _this;
        _this = this;
        $('.compare').on('click', {
          context: this
        }, this.compare);
        $('.delete').on('click', {
          context: this
        }, this["delete"]);
        $(window).on('click', {
          context: this
        }, _this.stop);
        $('div.name button.edit').on('click', this.edit);
        $(_this.inputs).on('keyup', {
          context: this
        }, this.keyup);
        $(_this.inputs).on('keydown', {
          context: this
        }, this.keydown);
        return $('ul.topics').on('click', 'li', {
          context: this
        }, this.submit);
      };

      SearchbarView.prototype.update = function(name, nb) {
        var el;
        this.topics['topic' + nb] = _.where(this.collection, {
          slug: name
        })[0];
        el = $('#name' + nb).parent().parent().find('h1');
        el.find('span.name').html(this.topics['topic' + nb].name);
        el.find('span.role').html(this.topics['topic' + nb].role);
        return el.find('.img img').attr('src', this.topics['topic' + nb].picture);
      };

      SearchbarView.prototype.compare = function(evt) {
        evt.stopPropagation();
        return evt.data.context.$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus();
      };

      SearchbarView.prototype["delete"] = function(evt) {
        var btn, ctxt, slug;
        evt.stopPropagation();
        btn = $(this);
        ctxt = evt.data.context;
        if (ctxt.$el.hasClass('comparison')) {
          ctxt.$el.removeClass('comparison');
          btn.parent().parent().removeClass('visible');
          slug = btn.parent().parent().data('slug');
          slug = Backbone.history.fragment.replace(slug, '').replace('/', '');
          md.Router.getPerson(slug);
          md.Router.navigate(slug);
        } else {
          ctxt.$el.addClass('search');
          md.Router.getSearch();
          md.Router.navigate('rechercher');
        }
        return btn.parent().find('h1').html('Cliquez pour rechercher');
      };

      SearchbarView.prototype.edit = function(evt) {
        evt.stopPropagation();
        return $(this).parent().find('form.search').addClass('visible').find('input').focus();
      };

      SearchbarView.prototype.stop = function(evt) {
        console.log(evt);
        if (evt) {
          return evt.data.context.$el.find('form.search.visible').removeClass('visible');
        } else {
          return this.$el.find('form.search.visible').removeClass('visible');
        }
      };

      SearchbarView.prototype.hasChanged = function(keyword) {
        return this.currentText !== keyword;
      };

      SearchbarView.prototype.keyup = function(evt) {
        var keyword, _this;
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
          _this.submit(null, this, _this);
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

      SearchbarView.prototype.submit = function(evt, input, ctxt) {
        var selected;
        if (input == null) {
          input = null;
        }
        if (ctxt == null) {
          ctxt = null;
        }
        if (evt) {
          selected = $(this);
          ctxt = evt.data.context;
          input = selected.parent().parent().find('input');
        } else {
          selected = $(input).parent().find('ul').children('.active');
        }
        $(input).parent().parent().find('h1').html(selected.html());
        if (ctxt.$el.hasClass('comparison')) {
          if ($(input).attr('id') === 'name-2') {
            ctxt.update(selected.data('slug'), 2);
            md.Router.navigate(ctxt.topics.topic1.slug + '/' + selected.data('slug'));
            md.Router.getComparison(ctxt.topics.topic1.slug, selected.data('slug'));
          } else if ($(input).attr('id') === 'name-1') {
            ctxt.update(selected.data('slug'), 1);
            md.Router.navigate(selected.data('slug') + '/' + ctxt.topics.topic2.slug);
            md.Router.getComparison(selected.data('slug'), ctxt.topics.topic2.slug);
          }
        } else {
          if (ctxt.$el.hasClass('search')) {
            ctxt.$el.removeClass('search');
          }
          ctxt.update(selected.data('slug'), $(input).attr('id').substring(5, 6));
          md.Router.navigate(selected.data('slug'));
          md.Router.getPerson(selected.data('slug'));
        }
        return ctxt.stop();
      };

      SearchbarView.prototype.navigate = function() {};

      SearchbarView.prototype.filter = function(keyword) {
        keyword = keyword.toLowerCase();
        return _.filter(this.collection, function(topic) {
          if (topic.lastName.toLowerCase().substring(0, keyword.length) === keyword) {
            return true;
          } else if (topic.firstName.toLowerCase().substring(0, keyword.length) === keyword) {
            return true;
          }
        });
      };

      SearchbarView.prototype.renderResults = function(input, results) {
        var ul;
        ul = input.parent().find('ul').html('');
        return _.each(results, function(result) {
          var el;
          el = $('<li>').data('slug', result.slug).append($('<div>').attr('class', 'img').append($('<img>').attr('src', result.picture)), result.name);
          return ul.append(el);
        });
      };

      return SearchbarView;

    })(Backbone.View);
  });

}).call(this);
