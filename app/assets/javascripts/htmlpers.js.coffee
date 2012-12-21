# returns true if string starts with given prefix
String::startsWith = (prefix) ->
  @substring(0, prefix.length) is prefix

# returns true if string ends with given suffix
String::endsWith = (suffix) ->
  @indexOf(suffix, this.length - suffix.length) != -1

# splice a given string into a String using Array::splice magic
# [source: http://www.bennadel.com/blog/2160-Adding-A-Splice-Method-To-The-Javascript-String-Prototype.htm]
String::splice = (index, howManyToDelete, stringToInsert) ->
  # NOTE: Because splice() mutates the actual array (and returns the removed values), 
  # we need to apply it to an existing array instead of simply calling it.
  characterArray = this.split ""                # Split string into individual character array 
  Array::splice.apply characterArray, arguments # Use Array::splice to insert the new string (as an array)
  characterArray.join ""                        # Join the character array back into a single string value and return it

window.defaultValue = (value, defaultValue) ->
  if value? then value else defaultValue

# HTML GENERATORS (jQuery wrappers)
window.tag = (tagname, classes, body...) ->
  html = $(tagname).addClass(classes)
  html.append text for text in body
  html
window.div = (classes, body...) ->
  tag "<div>", classes, body...
window.span = (classes, body...) ->
  tag "<span>", classes, body...
window.btn = (classes, body...) ->
  tag "<button>", "btn #{classes}", body...
window.li = (classes, body...) ->
  tag "<li>", classes, body...
window.link = (href, classes, body...) ->
  tag("<a>", classes, body...).attr("href", href)
window.img = (src, classes, body...) ->
  tag("<img>", classes, body...).attr("src", src)
window.btn = (classes, text) ->
  span "btn #{classes}", text
# Twitter Bootstrap icon generator
window.icon = (name, white=false) ->
  html = tag("<i>", "icon-#{name}")
  html.addClass("icon-white") if white
  html

# convert jQuery object to string
$.fn.toString = () -> @prop('outerHTML')

# removes the given class from all elements (optionally within scope selector)
# and applies it to this element. useful for singleton class, such as .active
$.fn.takeClass = (targetClass, scope='') ->
  $("#{scope} .#{targetClass}").removeClass targetClass
  @addClass targetClass
  
# shorthand for JST template path
window.tmpl = (template) -> JST["backbone/templates/#{template}"]

# pad a number with leading zeros to form a string of given total length
window.pad0 = (num, length) -> (1e15 + num + "").slice(-length)
# combine with large number, to string, cut leading 1 and 0s to size
# [source: http://stackoverflow.com/questions/2998784]
