# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
processImageLink = (index, tag) ->
  console.log tag
  url = /http:\S*/.exec $(tag).attr("href")
  return if url is null

  close = span("close btn-hover", "&times;").hide().click (event) ->
    event.preventDefault()
    $(this).closest(".pic-container").remove()

  queue = span("queue btn-hover", "+queue").hide().click (event) ->
    console.log "queuing this bad boy"
    $("#queue").append $(this).closest(".pic-container").remove()

  linktag = link(url, "pic").attr("target", "_blank").append($(tag).find("img"))
  $("#contents").append spantag = span "pic-container", linktag, close, queue
  spantag.click -> $("div#history").append($(this).detach())
  spantag.mouseenter -> $(this).children(".btn-hover").show()
  spantag.mouseleave -> $(this).children(".btn-hover").hide()

loadImages = (url) ->
  url = "http://#{url}"  unless url.startsWith("http://")
  console.log "Loading URL " + url
  $.get "/show", url: url, (response) ->
    $(response).find("a>img").parent().each processImageLink
    $("input#url").val ""

$(document).ready ->
  $("button#lookit").click (event) ->
    event.preventDefault()
    loadImages $("input#url").val()

  $("button.clear").click ->
    id = $(this).data("clear")
    console.log "clearing ##{id}"
    $("##{id}").children(".pic-container").remove()

  $("button#openQueue").click ->
    for pic in $("#queue").children(".pic-container")
      window.open $(pic).find("a").attr("href")
      $("#history").append $(pic).remove()
    self.focus()

  $("input#url").keypress (event) ->
    $("button#lookit").click()  if event.which is 13