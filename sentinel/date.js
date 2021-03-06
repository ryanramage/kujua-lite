var DATE_RE = /(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?/,
    sd = require('./config').get('synthetic_date'),
    start_date = new Date(),
    synth_start_date = undefined;

function load() {
    if (sd) {
      var matches =  String(sd).match(DATE_RE);
      if (matches) {
          var fullmatch = matches[0],
              year = matches[1],
              month = matches[2],
              day = matches[3],
              // default hours to noon so catches send window
              hours = matches[4] || 12,
              minutes = matches[5] || 0;
          synth_start_date = new Date(start_date.valueOf());
          synth_start_date.setFullYear(year, month -1, day);
          synth_start_date.setHours(hours, minutes, 0, 0);
          return;
      }
    }
}

// allows us to apply a delta to a timestamp when we run sentinel in synthetic
// time mode
function getTimestamp() {
    var now = new Date().valueOf();
    if (isSynthetic())
        return (now - start_date.valueOf()) + synth_start_date.valueOf();
    return now;
};
function isSynthetic() {
    if (synth_start_date)
        return true;
    return false;
}
function getDate() {
    if (synth_start_date)
        return new Date(synth_start_date.valueOf());
    return new Date();
}
module.exports = {
    getDate: getDate,
    getTimestamp: getTimestamp,
    isSynthetic: isSynthetic
};
load();
