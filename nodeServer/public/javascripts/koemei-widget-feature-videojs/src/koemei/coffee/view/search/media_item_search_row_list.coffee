class Koemei.View.SearchMediaItemRow extends Koemei.View.MediaItem

  tagName: 'article'

  initialize: ->
    Koemei.log "Koemei.View.SearchMediaItemRow#initialize"
    super()
    @template = JST.Media_item_search_portal
