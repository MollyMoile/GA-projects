mapInit = (lat, lng)->
  mapCanvas = document.getElementById("map-canvas")
  latLng = new google.maps.LatLng(lat, lng)
  mapOptions = 
    center: latLng,
    mapTypeControl: false,
    panControl: false,
    zoomControl: false,
    streetViewControl: false,
    zoom: 12

  # create a map
  map = new google.maps.Map(mapCanvas, mapOptions)
  # add a marker
  marker = new google.maps.Marker(
    map: map,
    position: latLng
  )

jQuery.fn.submitOnCheck = ()->
  this.find('input[type=submit]').remove()
  return this

manageRsvps = ->
  $('.rsvp-btn').on('click', ()->
    if $('.rsvp .confirm').length == 0
      guestLoginPrompt($(this))
    else
      updateInvite($(this))
  )

guestLoginPrompt = (el)->
  rsvp = el.attr('value')
  $('#user_rsvp').attr('value', rsvp)
  $('#loginPrompt').modal('show')

updateInvite = (el)->
  rsvp = el.attr('value')
  $('#invite_rsvp').val(rsvp)
  el.parent('form').submit()

notificationsFade = ->
  $.each([1,2,3,4,5], (i, num)->
    $(".fade-#{num}").removeClass("fade-#{num}")
  )
  $('.alert-dismissable').each((i)->
    $(this).addClass("fade-#{i}")
  )

hostConfirmsTickets = ->
  $('.ticket-confirm').on('click', ()->
    $(this).parent('form').submit()
  )

expandGuestList = ->
  $('#guest-list-collapse').collapse('show')

guestRegistrationForm = ->
  focusInput = ->
    $("#guest-name-input").focus()

  $('.register-name').on('click', ()->
    $('#loginPrompt').modal('hide')
    $("#fullGuestList").focus()
    expandGuestList()
    $('.guest-register').css('display', 'block')
    setTimeout(focusInput, 200)
  )

keyEnterToSubmit = ->
  # allow user to press enter instead of clicking
  $('#guest-name-input').keypress( (e)->
    if (e.which == 13)
      $(this).parent('form').submit()
  )

paymentMethodForm = ->
  $('.btn-payment').on('click', ()->
    payment = $(this).attr('value')
    $('#invite_payment_method').attr('value', payment)
    $(this).parent('form').submit()
  )

paymentTracking = ->
  $('.edit_invite').submitOnCheck()
  $('.edit_event').submitOnCheck()
  $('.onoffswitch-label').on('click', ()->
    checkBox = $(this).prev('input')
    val = checkBox.is(':checked')
    checkBox.prop('checked', !val)
    $(this).parent('form').submit()
  )
eventRow = ->
  $('.event-listing').on('click', ()->
    window.document.location = $(this).data("url")
  )

ready = ->
  # to copy to clipboard in browser, copy event link for emails
  clip = new ZeroClipboard($('#invite-btn'))
  
  manageRsvps()
  paymentTracking()
  hostConfirmsTickets()
  guestRegistrationForm()
  keyEnterToSubmit()
  paymentMethodForm()
  eventRow()
  if $('.inline.guest').length() > 4
    $('#guest-list-collapse').collapse('show')

$(document).ready(ready)
$(document).on('page:load', ready)

