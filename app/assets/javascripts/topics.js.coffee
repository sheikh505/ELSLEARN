# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#all_topics').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    retrieve: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#all_topics').data('source')

