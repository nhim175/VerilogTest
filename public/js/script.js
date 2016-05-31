'use strict';

$(function() {
  var printed = [];
  $('.warning, .error').each(function() {
    if (printed.indexOf($(this).html()) > -1) {
      $(this).next('br').remove();
      $(this).remove();
    } else {
      printed.push($(this).html());
    }
  });
});
