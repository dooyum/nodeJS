"""
This file contains the config variables for development environments
* static_cdn_path : static files (currently only the jwplayer)
* usermedia_cdn_path : user media rtmp streaming path
* koemei_css_path : path to externally provided css file
* koemei host : path of the koemei REST API
"""

#TODO : this should be put in a non public place

config =
  dev:
    static_cdn_path: "//s3.amazonaws.com/static.dev.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.dev.koemei.com/cfx/st/"
    koemei_css_path: "//s3.amazonaws.com/static.dev.koemei.com/widget/latest/css/koemei-widget.css"
    koemei_host: "https://dev.koemei.com"
  preprod:
    static_cdn_path: "//s3.amazonaws.com/static.preprod.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.preprod.koemei.com/cfx/st/"
    koemei_css_path: "//s3.amazonaws.com/static.preprod.koemei.com/widget/latest/css/koemei-widget.css"
    koemei_host: "https://preprod.koemei.com"
  test:
    static_cdn_path: "//s3.amazonaws.com/static.test.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.test.koemei.com/cfx/st/"
    koemei_css_path: "//s3.amazonaws.com/static.test.koemei.com/widget/lastest/css/koemei-widget.css"
    koemei_host: "https://test.koemei.com"
  localhost:
    static_cdn_path: "//s3.amazonaws.com/static.preprod.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.test.koemei.com/cfx/st/"
    koemei_css_path: "/dist/koemei-widget.css"
    koemei_host: "http://localhost:8080"
  seb:
    static_cdn_path: "//s3.amazonaws.com/static.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.www.koemei.com/cfx/st/"
    koemei_css_path: "dist/koemei-widget.css"
    koemei_host: "https://www.koemei.com"
  traian:
    static_cdn_path: "//s3.amazonaws.com/static.koemei.com"
    usermedia_cdn_path: "rtmp://usermedia.koemei.com/cfx/st/"
    koemei_css_path: "dist/koemei-widget.css"
    koemei_host: "https://www.koemei.com"
  prod:
    # in production, use the widget defaults
    use_defaults: ''

Koemei = Koemei or {}

Koemei.Config =

  api: '../REST'

  # free pricing plan
  freePlan: 'FREE'

  fileSizeLimit: '2500 MB'

  fileTypes: '*.avi;*.flv;*.m4v;*.mov;*.mp3;*.mp4;*.wav;*.wma;*.wmv'

  mediaActions: ['EDIT', 'TRANSCRIBE', 'PUBLISH', 'PLAY', 'DELETE']
