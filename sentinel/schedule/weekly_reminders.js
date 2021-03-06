var _ = require('underscore'),
  db = require('../db'),
  date = require('../date'),
  epi = require('epi-week'),
  i18n = require('../i18n'),
  config = require('../config'),
  utils = require('../lib/utils'),
  async = require('async'),
  moment = require('moment');

/*
 * Setup reminders for the current week unless they are already setup.
 */
function createReminders(options, callback) {
    var day = options.day,
        form = options.form,
        reminder = options.reminder,
      epiWeek,
      week,
      lastWeek = moment(date.getDate()),
      year;

    // previous CDC week is the previous Sunday
    lastWeek.subtract('weeks', 1);

    epiWeek = epi(lastWeek.toDate());
    week = epiWeek.week;
    year = epiWeek.year;

    db.view('kujua-sentinel', 'clinic_by_phone', function(err, data) {
        var recipients;
        if (err) {
            console.error("Could not run view: " + err.reason);
            callback(err);
        } else {
            recipients = _.pluck(data.rows, 'value');

            async.forEach(recipients, function(recipient, cb) {
                var phone = recipient && recipient.contact && recipient.contact.phone,
                    refid = recipient && recipient.contact && recipient.contact.rc_code;

                // we can't setup reminder if clinic has no phone number
                if (!phone) {
                    return cb();
                }

                db.view('kujua-sentinel', 'weekly_reminders', {
                    group: true,
                    key: [form, year, week, phone],
                    limit: 1
                }, function(err, data) {
                    if (err) {
                        console.error("Could not run view: " + err.reason);
                        return cb(err);
                    }
                    var doc,
                        row = _.first(data.rows),
                        result = row && row.value;

                    if (!result || (!result.received && !_.include(result.sent, day))) {
                        doc = {
                            day: day,
                            related_entities: {clinic: recipient},
                            related_form: form,
                            phone: phone,
                            refid: refid,
                            type: 'weekly_reminder',
                            week: week,
                            year: year
                        };
                        utils.addMessage(doc, phone, i18n(reminder, {
                            week: week,
                            year: year
                        }));
                        db.saveDoc(doc, function(err, ok) {

                            if (err) {
                                console.error("Could not add reminder: " + err.reason);
                            } else {
                                console.log('Created weekly reminder ' + [form,year,week,day,phone,refid]);
                            }
                            cb(err);
                        });
                    } else {
                        cb();
                    }
                });
            }, function(err) {
                callback(err);
            });
        }
  });
}

/**
 * Setup reminders for CDC
 *
 *
 *  To configure this, set the send_weekly_reminders property to something like this:
 *  {
 *    "VPD": {
 *      "3": "Last day to submit a timely VPD report for the previous week.",
 *      "4": "VPD report not received on time; please send previous week's data."
 *    }
 *  }
 *
 *  "VPD" is the form to expect; 3 & 4 are different days to send reminders on.
 *  The values are the messages to send.  {{week}} and {{year}} will be
 *  substituted into the message.
 *
 */
module.exports = function(callback) {
    var day,
        reminders = config.get('send_weekly_reminders'),
        items = [];

    if (_.isObject(reminders)) {
        day = date.getDate().getDay();
        _.each(reminders, function(schedule, form) {
            if (_.isObject(schedule)) {
                _.each(schedule, function(reminder, d) {
                    if (day === Number(d)) {
                        items.push({
                            form: form,
                            day: d,
                            reminder: reminder
                        });
                    }
                });
            }
        });
    }
    async.forEach(items, function(item, cb) {
        createReminders(item, cb);
    }, function(err) {
        callback(err);
    });
};
