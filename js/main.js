$(function() {
  // Dynamic year for footer copyright
  var year = (new Date).getFullYear();
  $(".footer .year").text(year);

  $(".what a").click(function() {
      $('.install').slideDown();
  });
  $("#curl").click(function() {
      $('.withfuton').slideUp(function() {
          $('.withcurl').slideDown();
      });
  });
  $("#futon").click(function() {
      $('.withcurl').slideUp(function() {
          $('.withfuton').slideDown();
      });
  });
});
