class Lookit.Views.GalleryView extends Backbone.View
  template: JST["backbone/templates/gallery"]
  slideshowTemplate: JST["backbone/templates/slideshow"]

  el: "#container"

  events:
    # event handlers for header buttons do various things
    'click .btn.slideshow': 'slideshow'
    'click .btn.float': 'toggleFloat'
    'click .btn.media': 'toggleMedia'
    # header filter fields update list of galleries
    'blur #blacklist': 'update'
    'blur #filter': 'update'
    # modal image click toggles fullscreen
    'click .modal.big img': 'fullscreenModal'
    'click .carousel img': 'fullscreenModal'

  initialize:  ->
    # field defaults
    @typeCheck = false
    @filter = ''
    @blacklist = []
    @views = []
    
    # build the URL with http:// and final /
    url = @options.url
    url = 'http://' + url unless url.startsWith('http')
    url = url + '/' unless @options.url.indexOf('?') > 0 or /\/(\w+\.\w+)?$/.test @options.url
    @options.url = url

    # actually fetch the galleries in the given URL
    @galleries = new Lookit.Collections.GalleriesCollection(@options)
    console.log "loading GalleriesCollection @ #{@options.url}"
    @galleries.fetch
      success: @createGalleries
      error: (error, message) -> console.error "ERROR! ", message

  render: ->
    url = @options.url
    $(@el).html(@template(url: url))

    numbers = /(\D*)(\d+)/g.exec url
    console.log numbers.slice(2)
    for match in numbers.slice(2)
      @$('.page-header').append(JST['backbone/templates/number_slider'](number: match[1], margin: match[0]))
    return this

  createGalleries: (collection) =>
    @galleryViews = collection.map (gal) -> new Lookit.Views.GalleryThumb(model: gal).render()

    @update()

  showGalleries: ->
    # filtered = collection.filter @filterGallery

    document.title = @galleries.title + " @ lookit"
    @$("#title").text(@galleries.title)

    # view.remove() for view in @views
    @views = _.filter @galleryViews, @filterGallery
    
    list = @$("#content").html('')
    for view in @views
      view.delegateEvents()
      list.append(view.el) 

    console.log "success!", @views, @views.length

  filterGallery: (galleryView) =>
    gallery = galleryView.model
    url = gallery.get('galleryUrl')
    blacklisted = _.any(@blacklist, (item) -> not _.isEmpty(item) and url.indexOf(item) >= 0) 
    filtered = gallery.get('name').indexOf(@filter) >= 0
    typed = if @typeCheck then gallery.get('type') in ['image', 'video'] else true
    filtered and typed and not blacklisted

  slideshow: ->
    console.log "Creating carousel... ", @galleries
    # construct the carousel HTML
    carousel = $(@slideshowTemplate(pics: @galleries.select((item) -> item.get('type') == 'image').map (item) -> item.get('galleryUrl')))

    carousel.find(":first-child").addClass("active")
    @$("#modal").html(carousel).modal('show')

  update: ->
    console.log "UPDATING"
    @filter = @$("#filter").val()
    @blacklist = @$("#blacklist").val().split(/[,;\s]/)
    console.log "filtering by '#{@filter}'. blacklist: ", @blacklist
    @showGalleries()

  fullscreenModal: () ->
    console.log 'fullscreening modal'
    @$("#modal").toggleClass('fullscreen')

  toggleFloat: () -> @$(".pic-container").toggleClass('pull-left')

  toggleMedia: () -> 
    @typeCheck = not @typeCheck
    @update()

  carouselKeys: (event) ->
    console.log event