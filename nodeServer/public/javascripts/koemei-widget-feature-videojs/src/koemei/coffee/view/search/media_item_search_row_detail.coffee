class Koemei.View.SearchMediaItemRowDetail extends Koemei.View.MediaItem

  tagName: 'article'

  initialize: ->
    Koemei.log "Koemei.View.SearchMediaItemRow#initialize"
    super()
    @template = JST.Search_detail_video

