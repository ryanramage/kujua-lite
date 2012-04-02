$(function() {
  // Dynamic year for footer copyright
  var year = (new Date).getFullYear();
  $(".footer .year").text(year);
  $(".hero-unit .btn").click(function() {
      $('.faqs').slideToggle();
  });
});
