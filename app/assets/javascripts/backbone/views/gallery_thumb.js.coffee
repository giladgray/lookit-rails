class Lookit.Views.GalleryThumb extends Backbone.View
  template: JST["backbone/templates/thumb"]
  tagName: 'span'
  className: 'pic-container thumbnail'

  events:
    'click .btn-hover.close': 'remove'
    'click .btn-hover.open': 'open'
    'click a.pic': 'lookit' 
    'mouseenter': 'toggleButtons'
    'mouseleave': 'toggleButtons'

  render: ->
    $(@el).html(@template(model: @model))
    return this

  submit: =>
    url = @$("#url").val()
    console.log "clicked on the button!", url
    router.navigate url, trigger: true

  open: ->
    console.log "open"
    window.open @model.get('galleryUrl')
    @markAsSeen()

  lookit: (evt) ->
    evt.preventDefault()
    console.log "lookit"
    for type, value of displayTypes
      if @model.get('type') == type then value.show(@model.get('galleryUrl'))
    @markAsSeen()

  markAsSeen: ->
    $(@el).addClass 'seen'

  toggleButtons: ->
    $(@el).toggleClass 'active'

