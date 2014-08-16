
# ALL ROUTES.
module.exports = (app, moongose)->
	UsersController = require('./controllers/UserController')(moongose, app)
	ComprasController = require('./controllers/ComprasController')(moongose, app)
	ProductosController = require('./controllers/ProductosController')(moongose, app)
	VentasController = require('./controllers/VentasController')(moongose, app)
	
	# ROUTE FOR LOG PAGE.
	isAut = (req, res, next)->
		if req.session.aut
			# console.log '2'
			next()  
		else
			res.redirect '/'
			# console.log '1' 

	app.get '/', (req, resp)->
		req.session.destroy (err)->
			console.log err if err
		resp.render 'pages/login', {title:'Log'}
	
	# ROUTES FOR PAGES/
	app.get '/pages/:page', isAut, (req, resp)->
		console.log req.session
		# resp.header('Cache-Control', 'private, no-cache, no-store, must-revalidate')
		# resp.header('Expires', '-1')
		# resp.header('Pragma', 'no-cache')
		page = req.params.page
		resp.render "pages/#{page}", {page:page, dataUser:req.session.dataUser}

	# ROUTES FOR USER.
	app.post '/users/login', UsersController.doLogin
	app.get '/users/getAll', UsersController.getAll
	app.get '/newuser/:name/:password/:estado?/:privilegios?', UsersController.newUser

	#rutas y acciones(io) (route:accion) desde el cliente.
	app.io.route 'users',
		create:UsersController.create
		delete:UsersController.delete
		edit:UsersController.edit
		userIn:UsersController.userIn
		userOut:UsersController.userOut
		
	# COMPRAS.
	app.get '/compras/prodReg', ComprasController.prodReg
	app.get '/newcompra/:serie/:codigo/:descripcion/:costo/:cantidad/:utilidad/:garantia/:proveedor', ComprasController.newCompra
	#rutas y acciones(io) (route:accion) desde el cliente.
	app.io.route 'compras',
		shopp:ComprasController.shopp
		delete:ComprasController.delete
		edit:ComprasController.edit
		shopping:ComprasController.shopping

	# PRODUCTOS.
	app.get '/productos/getAll', ProductosController.getAll

	# VENTAS.
	app.io.route 'ventas',
		addToCart:VentasController.addToCart
		delToCart:VentasController.delToCart
		cancelShopp:VentasController.cancelShopp
		shopp:VentasController.shopp

	#TEST ROUTES.
	app.get '/pdf', (req, resp)->
		resp.render 'pdf'

	app.get '/reporte.pdf', (req, resp)->
		lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in suscipit purus.  Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus nec hendrerit felis. Morbi aliquam facilisis risus eu lacinia. Sed eu leo in turpis fringilla hendrerit. Ut nec accumsan nisl.'
		PDFDocument = require('pdfkit')
		fs = require('fs')
		doc = new PDFDocument
			margins:
				top: 50
				bottom: 50
				left: 72
				right: 72
		# for i in [0..1000]
		doc.fontSize 10
		# doc.addPage
		#   margins:
		#     top: 50
		#     bottom: 50
		#     left: 72
		#     right: 72

		doc.pipe( fs.createWriteStream('out.pdf'))
		# doc.moveDown()
		# doc.moveTo(100, 100)
		doc.text 'INFORME', 270, 40,
		x = 30
		y = 70
		w = 100
		h = 30
		npag = 1
		# HEADER.
		for i in [0..4]
			doc.rect(x-5, y-5, w+10, h+5).lineWidth(1).fillOpacity(0.9).fillAndStroke('black', 'black')
			doc.fillColor 'white'
			doc.text "REPORTES #{i}", x, y+5,
				width: w
				height: h
				align: 'center'#
				# stroke:true
			x += w+10

		#ADD ROWS.
		doc.fontSize 9
		doc.fillColor 'black'
		y += h+5
		for j in [1...500]
			if j % 18 is 0
				# console.log y
				doc.text "Pagina #{npag++}", 270, 710,
				y = h+5
				doc.addPage()
			x = 30
			for i in [0..4]
				doc.rect(x-5, y-5, w+10, h+5).lineWidth(0.2).stroke('black')
				doc.text "Marcelo Juan Cabrera Gutiérrez", x, y,
					width: w
					height: h
					align: 'justify'#
					# stroke:true
				x += w+10
			y += h+5
		if 500 % 18 isnt 0
			doc.text "Pagina #{npag++}", 270, 710,

		# draw bounding rectangle
							# ptox, ptoy, anchox, anchoy
		# doc.moveTo(100, 100)
		# .lineTo(100, 130)
		# .lineTo(130, 160)
		# .fill('red', 'even-odd')

		# loremIpsum = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in...' 

		# doc.y = 320
		# doc.fillColor('black')
		# doc.text(loremIpsum, {
		# 	paragraphGap: 10,
		# 	# indent: 20,
		# 	align: 'left',
		# 	columns: 3
		# })
		doc.pipe( resp )
		doc.end()