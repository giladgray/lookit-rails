class Lookit.Models.Gallery extends Backbone.Model
  # paramRoot: 'gallery'

  # defaults:


class Lookit.Collections.GalleriesCollection extends Backbone.Collection
  model: Lookit.Models.Gallery

  url: -> '/show?url=' + @models[0].get('url')

  sync: (method, model, options) ->
    if method == 'read'
      # we have to override sync to use get instead of getJSON
      $.get @url(), (response) ->
        if response.error?
          options.error response.error.msg
        else options.success response
    else options.error 'Lookit is eyes only!'

  parse: (response) ->
    window.resp = response = $(response)
    siteUrlBits = urlRegex.exec @models[0].get('url')

    # find the title element by node name
    @title = _.find(response, (item) -> item.nodeName == 'TITLE').text

    thumbs = []

    for pic in response.find("a>img").parent()
      galUrl = urlMagic $(pic).attr('href'), siteUrlBits
      linkInfo = linkTypeAndIcon galUrl
      # generate model attributes for each galler 
      if galUrl.startsWith('http') and not blacklisted galUrl
        thumbs.push
          galleryUrl: galUrl
          thumbUrl: urlMagic $(pic).find('img').attr('src'), siteUrlBits
          name: $(pic).find('img').attr('alt') ? ''
          type: linkInfo[0]
          icon: linkInfo[1]

    # if (window.embed = response.find("embed")).length > 0
    #   flash = embed.attr('flashvars')
    #   video = /file=([-_\w\d]+\.[\w]+)/.exec(flash)[1]
    #   image = /image=([-_\w\d]+\.[\w]+)/.exec(flash)[1]
    #   thumbs.push
    #     galleryUrl: video
    #     thumbUrl: image
    #     name: ''
    #     type: 'video'
    #     icon: 'icon-film'

    thumbs
 