# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
processImageLink = (index, tag) ->
  console.log tag
  url = /http:\S*/.exec $(tag).attr("href")
  return if url is null

  close = span("close", "&times;").hide()
  close.click (event) ->
    event.preventDefault()
    $(this).closest(".pic-container").remove()

  linktag = link(url, "pic").attr("target", "_blank").append($(tag).find("img"))
  $("#contents").append spantag = span "pic-container", linktag, close
  spantag.click -> $("div#history").append($(this).detach())
  spantag.mouseenter -> $(this).children(".close").show()
  spantag.mouseleave -> $(this).children(".close").hide()
loadImages = (url) ->
  url = "http://" + url  unless url.startsWith("http://")
  console.log "Loading URL " + url
  $.get "/picpage/load.php",
    url: url
  , (response) ->
    $(response).find("a>img").parent().each processImageLink
    $("input#site").val ""

history = undefined
contents = undefined
siteField = undefined
$(document).ready ->
  $("button#load").click ->
    loadImages $("input#site").val()

  $(".clear").click ->
    $(this).nextAll(".pic-container").remove()

  $("input#site").keypress (event) ->
    $("button#load").click()  if event.which is 13