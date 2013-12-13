# Koemei Widget

Koemei widget for indexing and captioning your videos

## Getting Started
Download the [production version][min] or the [development version][max].

[min]: https://raw.github.com/seb/widget/master/dist/koemei-widget.min.js
[max]: https://raw.github.com/seb/widget/master/dist/koemei-widget.js

Requirement: jQuery version must be between `1.7.0` and `1.8.3`.

See examples/ for examples of the different usages

In your web page:

```html
<script src="jquery.js"></script>
<script src="dist/koemei-widget.min.js"></script>
<script>
  new KoemeiWidget({
    // the uuid of the media item that will be loaded in the widget
    media_uuid: 'a5113b4b-44a2-4a4a-a8f7-718735be1f06'
  });
</script>
```

To use the search view:

```html
<script src="jquery.js"></script>
<script src="dist/koemei-widget.min.js"></script>
<script>
  new Koemei.View.Search({
    // the default search query
    string: 'open'
  });021
</script>
```

To use the campus page view:

```html
<script src="jquery.js"></script>
<script src="dist/koemei-widget.min.js"></script>
<script>
  new Koemei.View.UserPortal({
      media_uuid: 'a5113b4b-44a2-4a4a-a8f7-718735be1f06',
      type: 'user_portal',
  });
</script>
```

Note: You must have a `crossdomain.xml` file in your root directory, with the following content:

```xml
<?xml version="1.0" ?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
<allow-access-from domain="*" secure="false"/>
</cross-domain-policy>
```

Note: To build the doc on macOs, you need to set the JAVA_HOME environment variable in your .bashrc
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

## Documentation

The widget should not be in a container with overflow hidden, or iframe
(otherwise in minimal mode the dialogs will not show below)

### Development

#### Setting up Grunt

First you'll need to install node.js (at least version 0.8). Check [this](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager) page.
In case you already have a grunt version older than 0.4, you'll need to uninstall it first:

    # only if you have a prior than 0.4 version installed
    $ sudo npm uninstall -g grunt

    # this installs grunt globally
    $ sudo npm install -g grunt-cli

Now, let's install the node dependencies listed on package.json with:

    $ npm install

#### Compile the widget

grunt quick


### Common options
* user_uuid (Koemei uuid):
    Koemei user uuid of the owner of the media
    (mandatory)

### Widget options:
* media_uuid (Koemei uuid):
    Koemei media uuid of the media to display
    (mandatory)
* features (list of features):
** transcripts (bool):
    Display the transcript pane
    (default: true)
** notes (bool):
    Display the notes pane
    (default: true)
** videos (bool):
    Display the videos pane
    (default: true)
** binders (bool):
    Display the binders pane
    (default: true)
* autosave (int):
    interval in seconds between autosaves. If 0 : no autosave.
    (default: 60)
* solid_overlay (bool):
    if true, then non transparent overlay in modal mode
    (default: false)
* black_overlay (bool)
    solid #000 overlay background. please also check solid_overlay flag for background image overlay (pattern from dashboard)
    (default: false)
* type (string):
    used to know what to init:
    search_portal
    widget
    caption_portal
    (default: widget)
* start_time(int):
    specify a start time for the movie, in seconds
    (default: 0)
* autoplay (bool):
    automatically launch playback on widget initialization
    (default: false)
* mode (string):
    Display mode.
    minimal: just the toolbar and no captions
    edit: the regular widget with the edit transcript pane
    embed: readonly with captions
    play: ??????
    (default: edit)
* background_save (bool):
    automatic background save. If true, the confirm save popup will not be shown, the action will happen in the background
* show_exit (bool):
    on false the exit button is not shown
    (default: true)
* el (DOM element):
    The element where the widget has to be located : e.g. $('#widget') if there is an empty "div" element on the page to put the widget to
* service (string):
    Service to publish the captions to. NB : the user account must be linked with that service.
    (default: 'koemei')
* width (int)
    The width in pixels of the widget. Please note that if the screen is smaller than the width bad things will probably happen.
    (default: 458, minimum: ??)
* video_height (int)
    The height in pixels of the video panel
    (default: 324, minimum: ??)
* video_width (int)
    The width in pixels of the video panel
    (default: 458, minimum: ??)
* widget_height (int):
    The height in pixels of the widget panel below the video
    (default: 324, minimum: ??)
* panel (string):
    The default panel to show when the widget is displayed
    (default: transcripts)
* toolbar (bool):
    Display the toolbar
    (default: true)
* captions (bool):
    Display an overlay with the captions on the player
    (default: true)
* modal (bool):
    Display the widget as a modal popup instead of inline
    (default: true)
* readonly (bool):
    Display the transcript as readonly
    (default: false)
* display_related_media (bool):
    Display the related media when doing a search on a media transcript
    (default: false)
* player_id (string):
    id of the player in case it is a Kaltura player
    (default: false)
* show_exit (bool):
    Display the exit button
    (default: true)
* detach_info (bool):
    Display video info outside the player
    (default: false)
* show_confidence (bool):
    Display the transcript confidence in a `<div>` outside the info
    (default: false)
* left_space (int):
    The distance between the player left margin and the seekbar start, in pixels - used for calculating the position of markers on seekbar
    (default: 45)
* right_space (int):
    The distance between the player right margin and the seekbar end, in pixels - used for calculating the position of markers on seekbar
    (default: 37)    

### Search portal options:
* search_string (string):
    Allows to display the search portal with an already active search
    (default: '', no search active)
* search_default (string):
    Display a prompt or the recent media of the user (prompt vs recent)
    (default: prompt)

### Mystery options
* improve_popup (bool):
    Not sure what does this popup does.
    (default: false)

### Future options:
* alternatives:
    Display alternatives for the low confidence words in the transcript
    (default: false)
* display_speakers
    Display the speaker in the transcript
    (default: true)

### Readonly options:
* koemei_host:
    'https://www.koemei.com'
* static_cdn_path:
    URL of the CDN hosting the static files.
* koemei_css_path:
    URL of a CSS file, if you want to override some rules.
* usermedia_cdn_path:
    User media streaming address.

### Development options:
* debug (bool):
    Log messages to the JavaScript console. You can also use the `kw_debug`
    parameter in the URL query to enable the debug mode (accepted values: 1,
    true, on)
    (default: false)

## Examples
see /examples
* widget.html displays the widget with the default layout (player+ bottom panes)
* search.html displays the widget as a search portal
* userportal.html displays the Campus page

## Release History
_(Nothing yet)_