couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost', 'admin', 'admin')
module.exports = client.db('kujua')
