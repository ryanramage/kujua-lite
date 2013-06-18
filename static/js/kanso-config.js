
var config;

$.kansoconfig = function(key, noFallback) {
  if (!config) loadConfig();

  var result = config[key];
  return arguments.length === 0 ? config : noFallback ? result : result || key;
};

function loadConfig() {
  var response = {};
  var base = window._baseURL || '.';
  $.ajax({
      url : base + '/config.json',
      async: false,
      success: function(data){
         config = data;
      }, error  : function() {
        config = {};
      }
  });
  $(document).data('kanso-config', config);
}