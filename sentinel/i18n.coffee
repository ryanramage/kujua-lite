Jed = require('jed')
locale = process.env.LOCALE or 'en'

console.log("Using #{locale} locale ...")

i18n = new Jed(
  domain: 'en'
  locale_data:
    en:
      "":
        domain: 'en'
        lang: 'en'
        plural_forms: 'nplurals=2; plural=(n != 1);'
      "Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks.": [
        null
        "Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks."
      ]
      "Greetings, %1$s. %2$s is due for an ANC visit this week.": [
        null
        "Greetings, %1$s. %2$s is due for an ANC visit this week."
      ]
      "Greetings, %1$s. It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!": [
        null
        "Greetings, %1$s.  It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!"
      ]
      "Greetings, %1$s. %2$s is due to deliver soon.": [
        null
        "Greetings, %1$s. %2$s is due to deliver soon."
      ]
      "Greetings, %1$s. Please submit the birth report for %2$s.": [
        null
        "Greetings, %1$s. Please submit the birth report for %2$s."
      ]
      "Thank you, %1$s. ANC counseling visit has been recorded.": [
        null
        "Thank you, %1$s. ANC counseling visit has been recorded."
      ]
      "Thank you. Danger sign %1$s has been recorded.": [
        null
        "Thank you. Danger sign %1$s has been recorded."
      ]
      "Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk.": [
        null
        "Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk."
      ]
      "%1$s has reported danger sign %2$s is present in %3$s. Please follow up.": [
        null
        "%1$s has reported danger sign %2$s is present in %3$s. Please follow up."
      ]
      "This is a reminder to submit your report for week %1$s of %2$s. Thank you!": [
        null
        "This is a reminder to submit your report for week %1$s of %2$s. Thank you!"
      ]
      "You have not yet submitted your report for week %1$s of %2$s. Please do so as soon as possible. Thanks!": [
        null
        "You have not yet submitted your report for week %1$s of %2$s. Please do so as soon as possible. Thanks!"
      ]
    ne:
      "":
        domain: 'ne'
        lang: 'ne'
        plural_forms: 'nplurals=2; plural=(n != 1);'
      "Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks.": [
        null
        "Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks."
      ]
      "Greetings, %1$s. %2$s is due for an ANC visit this week.": [
        null
        "Greetings, %1$s. %2$s is due for an ANC visit this week."
      ]
      "Greetings, %1$s. It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!": [
        null
        "Greetings, %1$s.  It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!"
      ]
      "Greetings, %1$s. %2$s is due to deliver soon.": [
        null
        "Greetings, %1$s. %2$s is due to deliver soon."
      ]
      "Greetings, %1$s. Please submit the birth report for %2$s.": [
        null
        "Greetings, %1$s. Please submit the birth report for %2$s."
      ]
      "Thank you, %1$s. ANC counseling visit has been recorded.": [
        null
        "Thank you, %1$s. ANC counseling visit has been recorded."
      ]
      "Thank you. Danger sign %1$s has been recorded.": [
        null
        "Thank you. Danger sign %1$s has been recorded."
      ]
      "Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk.": [
        null
        "Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk."
      ]
      "%1$s has reported danger sign %2$s is present in %3$s. Please follow up.": [
        null
        "%1$s has reported danger sign %2$s is present in %3$s. Please follow up."
      ]
      "This is a reminder to submit your report for week %1$s of %2$s. Thank you!": [
        null
        "This is a reminder to submit your report for week %1$s of %2$s. Thank you!"
      ]
      "You have not yet submitted your report for week %1$s of %2$s. Please do so as soon as possible. Thanks!": [
        null
        "You have not yet submitted your report for week %1$s of %2$s. Please do so as soon as possible. Thanks!"
      ]
)

module.exports = (key, args...) ->
  domain = i18n.translate(key).onDomain(locale)
  debugger
  domain.fetch.apply(domain, args)
