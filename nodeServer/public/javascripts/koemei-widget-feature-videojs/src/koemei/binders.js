// TODO : this needs to be coffeed and backboned

/*
events:
    'click .new_binder_button':'new_binder',
    'click .new_snippet_button':'new_snippet',
    'click .binder_edit_button':'edit_binder',
    'click .binder_delete_button':'delete_binder',
    'click .binder_create_popup div.button':'hide_popups',
    'click .binder_delete_popup div.button':'hide_popups',
    'click .binder_edit_popup div.button':'hide_popups',
    'click .snippet_create_popup div.button':'hide_popups',

    new_snippet:function(event){
        event.preventDefault();
		var button = event.currentTarget;
		var pos = $(button).offset();
        this.hide_popups();
        $(button).addClass('active');
        var template = _.template(new_snippet);
        this.$el.children().append(template);
        $('.snippet_create_popup').css('top',pos.top+34);
        $('.snippet_create_popup').css('left',pos.left-6);
    },

    new_binder:function(event){
        event.preventDefault();
		var button = event.currentTarget;
		var pos = $(button).offset();
        this.hide_popups();
        $(button).addClass('active');
        var template = _.template(new_binder);
        this.$el.children().append(template);
        $('.binder_create_popup').css('top',pos.top+34);
        $('.binder_create_popup').css('left',pos.left-6);
    },

    edit_binder:function(event){
        event.preventDefault();
		var button = event.currentTarget;
		$(button).toggleClass('active');
		var pos = $(button).offset();
		if ($(button).hasClass('active')) {
            this.hide_popups();
            $(button).addClass('active');
            var template = _.template(edit_binder);
            this.$el.children().append(template);
            $('.binder_edit_popup').css('top',pos.top+34);
            $('.binder_edit_popup').css('left',pos.left-6);
		} else {
			this.hide_popups();
		}
    },

    delete_binder:function(event){
        event.preventDefault();
		var button = event.currentTarget;
		$(button).toggleClass('active');
		var pos = $(button).offset();
		if ($(button).hasClass('active')) {
            this.hide_popups();
            $(button).addClass('active');
            var template = _.template(delete_binder);
            this.$el.children().append(template);
            $('.binder_delete_popup').css('top',pos.top+34);
            $('.binder_delete_popup').css('left',pos.left-6);
		} else {
			this.hide_popups();
		}
    },

	display_binder:function() {
        // initialize binders/snippets view with dummy data
        this.player_view.notes_heatmap.hide();
        this.snippets = new Koemei.Collection.Snippets([{
            video_title: 'Macro vs Micro Economics',
            timestamp: '37:22',
            content: 'Vestibulum ante ipsum primis.'
        }, {
            video_title: 'Macro vs Micro Economics',
            timestamp: '12:05',
            content: 'Participating in a new business creation is a common activity among U.S. workers over the course of their careers..'
        }]);

        this.binder_list_view = new Koemei.View.BinderList({
            el: this.$('.widget_hold_panel'),
            height: this.options.widget_height
        });

        this.snippet_list_view = new Koemei.View.SnippetList({
            el: this.$('.widget_hold_panel'),
            height: this.options.widget_height,
            model: new Koemei.Model.Binder
        });

        // just ask the view to render
        this.binder_list_view.render();
	},
*/