crypto = require('crypto')
_ = require('underscore')

LETTERS = 'ABCDEFGHJKLMNPQRSTUVWXYZ'.split('')

addNumber = (result, number) ->
  result.unshift(number % 10)
  Math.floor(number / 10)
addLetter = (result, number) ->
  result.unshift(LETTERS[number % LETTERS.length])
  Math.floor(number / LETTERS.length)

addCheckDigit = (nhi) ->
  total = _.reduce(nhi, (sum, digit, index) ->
    if index < 3
      sum += (_.indexOf(LETTERS, digit) + 1) * (7 - index)
    else
      sum += Number(digit) * (7 - index)
    sum
  , 0)
  result = total % 11
  nhi.push(if result is 10 then 0 else result)

generate = (num, s) ->
  sum = crypto.createHash('md5')
  sum.update("#{num}-#{s}")
  number = parseInt(sum.digest('hex'), 16)
  result = []

  number = addNumber(result, number)
  number = addNumber(result, number)
  number = addNumber(result, number)
  number = addLetter(result, number)
  number = addLetter(result, number)
  number = addLetter(result, number)

  addCheckDigit(result)
  result.join('')

module.exports.generate = generate
