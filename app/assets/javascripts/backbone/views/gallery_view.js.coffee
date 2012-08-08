class Lookit.Views.GalleryView extends Backbone.View
  template: JST["backbone/templates/gallery"]
  slideshowTemplate: JST["backbone/templates/slideshow"]

  el: "#container"

  events:
    'click .btn.slideshow': 'slideshow'

  initialize:  ->
    @options.url = if @options.url.startsWith('http') then @options.url else 'http://' + @options.url
    @galleries = new Lookit.Collections.GalleriesCollection(@options)
    console.log "loading GalleriesCollection"
    @galleries.fetch
      success: @showGalleries
      error: (error, message) -> console.error "ERROR! ", message

  render: ->
    url = @options.url
    $(@el).html(@template(url: url))
    return this

  showGalleries: (collection, response) =>
    console.log "success!", collection
    list = @$("#content")
    collection.forEach (gal) ->
      url = gal.get('galleryUrl')
      if url.startsWith('http') and not blacklisted url
        @gallery = new Lookit.Views.GalleryThumb(model: gal)
        list.append(@gallery.render().el)

  slideshow: ->
    console.log "Creating carousel... ", @galleries
    # construct the carousel HTML
    carousel = $(@slideshowTemplate(pics: @galleries.map (item) -> item.get('galleryUrl')))

    carousel.find(":first-child").addClass("active")
    showModal carousel