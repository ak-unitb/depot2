# added file by AK for common functionalities.


window.showAjaxUpdateMessage = (msg, type) ->
  if $(".messageDisplay").length < 1
    $("body").append($("<div />").addClass("messageDisplay"))
  clasz = if type == "error" then "error" else if type == "success" then "success" else "info"
  hideAgain = () ->
    $(".messageDisplay").fadeOut(1000, "linear", () -> )
  $(".messageDisplay")
    .html(msg)
    .removeClass("error, success, info")
    .addClass(clasz)
    .fadeIn(
      1000,
      "linear",
      () ->
        window.setTimeout( hideAgain , 1000 )
        false
    )
  alert($(".messageDisplay")[0].class)
