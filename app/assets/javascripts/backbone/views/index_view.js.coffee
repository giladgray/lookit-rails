class Lookit.Views.IndexView extends Backbone.View
  template: JST["backbone/templates/lookit"]
  el: 'div#container'

  events:
  	'click #lookit': 'submit'

  render: ->
    $(@el).html(@template())
    return this

  submit: (event) =>
    event.preventDefault()
  	url = @$("#url").val()
  	console.log "clicked on the button!", url
  	router.navigate url, trigger: true
