# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# filetypes that can be displayed in the carousel
window.validTypes = ['.jpg', '.png', '.bmp', '.gif', '.jpeg', '.mpg', '.wmv', '.mov']
# TODO: implement HTML5 video tags

# list of blacklist regexes that will reject a URL
window.blacklist = [/(\/|\.)ads?(\/|\.)/]
window.blacklisted = (string) ->
  reject = false
  # check the string against each blacklist entry
  for item in blacklist
    if item.test(string)
      reject = true 
      console.log "'#{string}' rejected by blacklist"
      break
  reject

processImageLink = (tag) ->
  console.log tag
  # search url string for valid URL with http:// prefix, GTFO if fail.
  # this ignores relative links and finds URLs hidden in query string.
  url = /http:\S*/.exec $(tag).attr("href")
  return if url is null or blacklisted(url)

  # the X button (top-right) deletes this pic
  close = span("close btn-hover", "&times;").hide().click (event) ->
    event.preventDefault()
    $(this).closest(".pic-container").remove()

  # the Q button (bottom) adds this pic to the queue
  queue = span("queue btn-hover", "+queue").hide().click (event) ->
    $("#queue").append $(this).closest(".pic-container").remove()

  # the OPEN button (top-left) opens this link in a new lookit window
  open = span("lookit btn-hover", '<i class="icon-share"></i>').hide().click (event) ->
    url = $(this).closest(".pic-container").find("a").attr("href")
    console.log "launching link in new lookit: #{url}"
    window.open "/?url=#{url}"

  # create a new link tag so we can set our own attributes on it
  linktag = link(url, "pic").attr("target", "_blank").append($(tag).find("img"))
  # make the pic-container tag, containing the link and all the controls we created above
  spantag = span "pic-container", linktag, close, queue, open
  # add some event listeners to the pic-container: click to send to history, hover to show buttons
  spantag.click(-> $("div#history").append($(this).detach())).hover (-> $(this).children(".btn-hover").show()), (-> $(this).children(".btn-hover").hide())
  spantag

loadImages = (url) ->
  safeUrl = if url.startsWith("http://") then url else "http://#{url}"
  console.log "Loading URL " + url
  # load the page, find all image links and process them
  $.get "/show", url: safeUrl, (response) ->
    dest = createContents(url, safeUrl)
    $(".container").append dest
    dest.find(".site-list").append(processImageLink($(pic))) for pic in $(response).find("a>img").parent()
    #$(response).find("a>img").parent().each processImageLink
    $("input#url").val ""

contentIndex = 0
createContents = (name, url) ->
  id = "content#{contentIndex++}"
  # remove button deletes this row from the UI
  remove = btn("remove", icon("trash")).attr("title", "Remove this gallery").attr("data-remove", id).click ->
    $(this).parent().parent().remove()
  # refresh button reloads images from the URL
  refresh = btn("refresh", icon("refresh")).attr("title", "Refresh this gallery").attr("data-refresh", name).click ->
    loadImages($(this).data("refresh"))
    # NOTE that refresh is accomplished by simply redoing the loadImages action
    remove.click()
  carousel = btn("", icon("play")).attr("title", "Slideshow it!").attr("data-list", id).click ->
    showModal createCarousel($("#" + $(this).data("list")))

  header = div "page-header", div("btn-group right", carousel, refresh, remove), tag("<h2>", '', link(url, '', name).attr("target", "_blank"))
  div "row", header, div("site-list").attr("id", id)

createCarousel = (list) ->
  console.log "Creating carousel..."
  console.log list
  # construct the carousel HTML
  carousel = div "carousel slide", inner = div("carousel-inner"), link("#carousel", "left carousel-control", "&lsaquo;").attr("data-slide", "prev"), link("#carousel", "right carousel-control", "&rsaquo;").attr("data-slide", "next")
  carousel.attr("id", "carousel")

  # add items from the list to the carousel
  for pic in list.find("a")
    src = $(pic).attr("href")
    filetype = /\.[a-z]+$/.exec(src)
    # only add item to carousel if it is a link to an acceptable filetype
    inner.append div("item", img(src)) if filetype isnt null and filetype[0] in validTypes
  inner.find(":first-child").addClass("active")

  carousel

showModal = (contents) ->
  # show a modal dialog with the given contents
  div("modal", contents).attr("id", "modal").modal('show')

$(document).ready ->
  # click the lookit button to load images from the URL
  $("button#lookit").click (event) ->
    event.preventDefault()
    loadImages $("input#url").val()

  # clear button removes all pic-containers from data-clear element
  $("button.clear").on "click", (event) ->
    id = $(this).data("clear")
    console.log "clearing ##{id}"
    $("##{id}").children(".pic-container").remove()

  # open queue button launches each queued link in a new background window
  $("button#openQueue").click ->
    for pic in $("#queue").children(".pic-container")
      window.open $(pic).find("a").attr("href")
      $("#history").append $(pic).remove()
    self.focus()

  # enter key handler for text input
  $("input#url").keypress (event) ->
    $("button#lookit").click()  if event.which is 13

  # automatically load images if URL parameter is specified.
  # the text input will be preloaded with params[:url] if it exists.
  $("button#lookit").click() if $("input#url").val()