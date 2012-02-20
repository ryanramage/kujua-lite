exports.sms_message_values = {
    map: function (doc) {
        var smsparser = require('views/lib/smsparser'),
            smsforms = require('views/lib/smsforms');

        if (doc.type === 'sms_message' && doc.form) {
            var def = smsforms[doc.form];
            if (def) {
                emit(
                    [doc.form, doc.sent_timestamp],
                    smsparser.parseArray(def, doc));
            }
        }
    }
};

exports.sms_messages = {
    map: function (doc) {
        if (doc.type === 'sms_message') {
            emit(doc._id);
        }
    }
};