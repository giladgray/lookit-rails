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
    siteUrlBits = urlRegex.exec @models[0].get('url')
    window.resp = response = $(response)

    # seems the first element in the response is the page title
    for line in resp 
      if line.text? 
        @title = line.text 
        break
    console.log @title

    thumbs = []
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
        # console.log thumbUrl, '~~', galleryUrl
    thumbs
 