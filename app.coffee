express = require 'express.io'
# http = require 'http'
# consolidate = require 'consolidate'
ECT = require 'ect' 
ectRenderer = ECT { watch: true, root: "#{__dirname}/views" }

# moment = require 'moment'
# moment.lang("es")
app = express()
app.http().io()

#config express.
app.set 'port', process.env.PORT or 6969
app.set 'views', "#{__dirname}/views"
app.engine '.ect', ectRenderer.render
# app.engine 'ect', consolidate.ect
app.set 'view engine', 'ect'
# use middlewares express.
app.use express.static("#{__dirname}/public")
# para ler los campos POST.
# app.use(express.bodyParser()) equivale alas siguientes 3 lineas.
app.use(express.json());
app.use(express.urlencoded());
# app.use(express.multipart());

app.use(express.cookieParser())
app.use express.session(secret: '023197422617bce43335cbd3c675aeed')
app.use express.logger('dev')

# CONFIG DB.
mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/corprotecdb')
# mongoose.connect('mongodb://nodejitsu:d24b07c39d5fdfc80e3cf77ef17ea1c3@troup.mongohq.com:10044/nodejitsudb1578159567')
# ALL ROUTES.
require('./routes')(app, mongoose)
# START SERVER.
app.listen app.get('port'), ->
	console.log "servidor escuchando en: #{app.get 'port'}"

