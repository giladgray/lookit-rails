class Lookit.Views.NumberCounter extends Backbone.View
  template: tmpl 'number_slider'

  tagName: 'span'
  className: 'number'

  events:
    'click .btn.down': 'numberDown'
    'click .btn.up': 'numberUp'

  initialize: ->
    # remember the length as a string
    @length = @options.number.length
    # and store it as an integer
    @number = parseInt @options.number

  render: ->
    $(@el).append(@template(number: @options.number))
    @$el

  numberDown: (event) -> @numberChange event, -1

  numberUp: (event) -> @numberChange event, 1

  numberChange: (event, amount) ->
    event.preventDefault()

    # update the number and convert to a zero-padded string using original length
    @number += amount 
    nextNum = pad0 @number, @length
    # splice the updated string into the old URL (taken from link href) and
    # trigger the global event to load a gallery with this update URL
    Backbone.Events.trigger 'gallery:load', $('#url').attr('href').splice(@options.index, @length, nextNum)

    # update slider text
    @$('span').text nextNum