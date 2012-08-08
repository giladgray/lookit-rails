class Lookit.Routers.LookitsRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    "": "index"
    "*url": "gallery"
  
  index: ->
    @view = new Lookit.Views.IndexView()
    $("#lookits").html(@view.render().el)

  gallery: (url) ->
    # console.log "showing gallery:", url
    @view = new Lookit.Views.GalleryView(url: url)
    $("#lookits").html(@view.render().el)

