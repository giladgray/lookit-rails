class Lookit.Views.GalleryView extends Backbone.View
  template: tmpl 'gallery'
  slideshowTemplate: tmpl 'slideshow'

  el: "#container"

  events:
    # event handlers for header buttons do various things
    'click .btn.slideshow': 'slideshow'
    'click .btn.float': 'toggleFloat'
    'click .btn.media': 'toggleMedia'
    'click .btn.slash': 'toggleSlash'
    # header filter fields update list of galleries
    'blur #blacklist': 'update'
    'blur #filter': 'update'
    # modal events
    'click .modal img': 'fullscreenModal'
    'click .carousel img': 'fullscreenModal'
    'click .modal .left.control': 'previousImage'
    'click .modal .right.control': 'nextImage'

  initialize:  ->
    # field defaults
    @typeCheck = false
    @filter = ''
    @blacklist = []
    @views = []

    url = @options.url
    
    # build the URL with http:// and final /
    url = 'http://' + url unless url.startsWith('http')

    @loadGalleries url

    $('body').keydown @keypress

    # TODO: must be a way to replace this global event
    Backbone.Events.on 'gallery:load', (url) => @loadGalleries url

  render: ->
    $(@el).html(@template(url: @url))

    # regular expression to break URL into alpha and numeric blocks
    decimals = new RegExp('(\\D*)(\\d+)', 'g')
    measure = $('h2 a').text('')
    # create number buttons for each number until there are no more
    while numbers = decimals.exec @url
      # append previous non-number string
      measure.append span '', numbers[1]
      # append a number counter
      counter = new Lookit.Views.NumberCounter
        number: numbers[2]
        index: decimals.lastIndex - numbers[2].length
      measure.append counter.render()
      lastIndex = decimals.lastIndex
    # append the rest of the URL that wasn't matched
    measure.append("<span>#{@url.slice lastIndex}</span>")

    return this

  loadGalleries: (url) ->
    # update URL in browser
    router.navigate @url = url
    # actually fetch the galleries in the given URL
    @galleries = new Lookit.Collections.GalleriesCollection({url: url})
    console.log "loading GalleriesCollection @ #{url}"
    @galleries.fetch
      success: @createGalleries
      error: (error, message) -> console.error "ERROR! ", message

  createGalleries: (collection) =>
    @galleryViews = collection.map (gal) -> new Lookit.Views.GalleryThumb(model: gal).render()

    @update()

  showGalleries: ->
    # filtered = collection.filter @filterGallery

    document.title = @galleries.title + " @ lookit"
    @$("#title").text(@galleries.title)
    @$('#url').attr('href', @url)
    
    list = @$("#content").html('')
    for view in @galleryViews
      view.remove()
      if @filterGallery(view)
        view.delegateEvents()
        list.append(view.el) 

    console.log "success!", @views, @views.length

  filterGallery: (galleryView) =>
    gallery = galleryView.model
    url = gallery.get('galleryUrl')
    blacklisted = _.any(@blacklist, (item) -> not _.isEmpty(item) and url.indexOf(item) >= 0) 
    filtered = gallery.get('name').indexOf(@filter) >= 0
    typed = if @typeCheck then (gallery.get('type') in ['image', 'video']) else true
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

  fullscreenModal: ->
    console.log 'fullscreening modal'
    @$("#modal").toggleClass('fullscreen')

  toggleFloat: -> @$(".thumbnail").toggleClass('pull-left')

  toggleMedia: -> 
    @typeCheck = not @typeCheck
    @update()

  toggleSlash: ->
    if /\/$/.test @url
      @loadGalleries @url.slice(0, @url.length - 1)
    else @loadGalleries @url + '/'

  previousImage: ->
    $('.open').prevAll('.image').first().find('a').click()

  nextImage: ->
    $('.open').nextAll('.image').first().find('a').click()

  keypress: (event) =>
    console.log event.which
    switch event.which
      # left - previous image
      when 37 then @previousImage()
      # right - next image
      when 39 then @nextImage()
      # space - toggle fullscreen
      when 32 then $('.modal img').click()
      # m - toggle media
      when 77 then @$('.btn.media').click()
      # , - toggle float
      when 188 then @$('.btn.float').click()
      # / - toggle slash
      when 191 then @$('.btn.slash').click()

