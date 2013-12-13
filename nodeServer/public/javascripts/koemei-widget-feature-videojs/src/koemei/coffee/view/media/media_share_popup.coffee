class Koemei.View.ShareMediaPopup extends Koemei.View.Tooltip

  events:
    'click .facebook_share':'share_facebook'
    'click .twitter_share':'share_twitter'
    'click .email_share':'share_email'
    #'click .koemei_share':'share_koemei'
    'click .google_share':'share_google'


  template: JST.Media_share_popup


  #TODO : share the actual media url
  #TODO : urlencode!
  share_facebook: (e) ->
    e.preventDefault()
    #video_url = @options.widget.options.koemei_host+'/media/'+@options.widget.media_item.get('uuid')
    video_url = @options.widget.options.koemei_host
    url = 'http://www.facebook.com/sharer.php?s=100&p[url]='+video_url+'&p[title]='+@options.widget.media_item.get('title')+'&p[summary]='+@options.widget.media_item.get('description')
    window.open url,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600'
    @remove()


  share_twitter: (e) ->
    e.preventDefault()
    #video_url = @options.widget.options.koemei_host+'/media/'+@options.widget.media_item.get('uuid')
    video_url = @options.widget.options.koemei_host
    url = 'https://twitter.com/intent/tweet?original_referer='+video_url+'&text='+@options.widget.media_item.get('title')+' '+video_url
    window.open url,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600'
    @remove()


  share_google: (e) ->
    e.preventDefault()
    #video_url = @options.widget.options.koemei_host+'/media/'+@options.widget.media_item.get('uuid')
    video_url = @options.widget.options.koemei_host
    url = 'https://plus.google.com/share?url='+video_url
    window.open url,'', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600'
    @remove()


  share_email: (e) ->
    e.preventDefault()
    #video_url = @options.widget.options.koemei_host+'/media/'+@options.widget.media_item.get('uuid')
    video_url = @options.widget.options.koemei_host
    window.location = 'mailto:?subject=Check out this video!&body=I thought you might find this interesting:'+video_url
    @remove()
