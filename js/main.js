$(function() {
  // Dynamic year for footer copyright
  var year = (new Date).getFullYear();
  $(".footer .year").text(year);

  $(".learn-more").click(function() {
      $('.faqs').slideToggle();
  });
});
