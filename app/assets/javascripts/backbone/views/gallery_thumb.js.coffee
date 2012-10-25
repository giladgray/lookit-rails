class Lookit.Views.GalleryThumb extends Backbone.View
  template: JST["backbone/templates/thumb"]
  tagName: 'span'
  className: 'pic-container thumbnail'

  events:
    'click .btn-hover.close': 'remove'
    'click .btn-hover.open': 'open'
    'click a.pic': 'lookit' 
    'click span.type': 'lookit' 
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
    $(@el).takeClass 'open'
    @markAsSeen()

  markAsSeen: ->
    $(@el).addClass 'seen'

  toggleButtons: ->
    $(@el).css 'font-size', @el.clientHeight
    $(@el).toggleClass 'active'

  showModal: ->
    window.content = img(@model.get('galleryUrl'))
    content[0].onload = =>
      # set the modal margins to half the image dimensions + inner margin and remember it for later
      @marginLeft = -Math.min(content[0].clientWidth, document.width) / 2 - 10
      @marginTop = -Math.min(content[0].clientHeight, document.height) / 2 - 10
      modal.css('margin-left', @marginLeft).css('margin-top', @marginTop)
      console.log "setting margins! left: #{@marginLeft}, top: #{@marginTop}"
    $("#modal").html(content).modal('show')
    # initialize dialog with last modal's margins
    modal.css('margin-left', @marginLeft).css('margin-top', @marginTop)
    
    console.log content, content.clientWidth, content.clientHeight

