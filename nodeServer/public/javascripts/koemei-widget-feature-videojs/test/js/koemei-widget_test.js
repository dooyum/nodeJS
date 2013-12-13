module({
  'koemei.widget': function() {
    return {
      setup: function() {},
      teardown: function() {}
    };
  }
});

test('basic', 2, function() {
  var edit_widget, options, toolbar_container, widget_container;

  options = {
    media_uuid: 'c5676ff9-bc0d-41b7-8d8f-60452e8ada14',
    mode: 'edit'
  };
  edit_widget = new KoemeiWidget(options);
  widget_container = $('#koemei_widget_container');
  ok(widget_container.is(':visible'), 'Koemei widget is initially visible');
  toolbar_container = $('#widget_toolbar_hold');
  ok(toolbar_container.is(':visible'), 'Koemei toolbar is initially visible');
  return widget_container.remove();
});

test('edit', 1, function() {
  var edit_container, edit_widget, options, widget_container;

  options = {
    media_uuid: 'c5676ff9-bc0d-41b7-8d8f-60452e8ada14',
    mode: 'edit'
  };
  edit_widget = new KoemeiWidget(options);
  widget_container = $('#koemei_widget_container');
  edit_container = $('#kw_transcript_container');
  ok(edit_container.is(':visible'), 'Koemei edit container is initially visible');
  return widget_container.remove();
});

test('player_controls', 0, function() {
  var edit_widget, options, widget_container;

  options = {
    media_uuid: 'c5676ff9-bc0d-41b7-8d8f-60452e8ada14',
    mode: 'edit'
  };
  edit_widget = new KoemeiWidget(options);
  widget_container = $('#koemei_widget_container');
  console.log(edit_widget.player);
  edit_widget.player.play();
  console.log(edit_widget.player.player.getState());
  return widget_container.remove();
});

test('edit_subtitles', 1, function() {
  var edit_widget, options, subtitles_container, widget_container;

  options = {
    media_uuid: 'c5676ff9-bc0d-41b7-8d8f-60452e8ada14',
    mode: 'edit'
  };
  edit_widget = new KoemeiWidget(options);
  widget_container = $('#koemei_widget_container');
  edit_widget.player.play();
  edit_widget.player.pause();
  subtitles_container = $('#kw_subtitles');
  console.log(subtitles_container);
  equal(subtitles_container.innerText, '', 'Koemei edit container is initially visible');
  return widget_container.remove();
});

/*test 'search_portal', 1, ->
  # test if the widget is displayed in search mode, using recent styff
  options = {
    type: 'search_portal',
    mode:'embed',
	  search_default:'recent'
  }
  edit_widget = new KoemeiWidget(options)
  widget_container = $('#koemei_widget_container')
  edit_container = $('#transcript_container')
  ok edit_container.is(':visible'), 'Koemei edit container is initially visible'
  widget_container.remove()
*/

