class VentasController
	constructor:(moongose, app)->
		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		@VentasModel = require('../models/VentasModel')(moongose)
		# @moment = require('moment')
		@app = app
		# utils.
		# @hash = require('../libs/password')
	addToCart:(req, resp)=>
		console.log req.session
		itemi = req.data.item
		itemIncart = req.session.inCart[itemi._id]
		if itemIncart isnt undefined
			itemIncart.cantidad += itemi.cantidad*1
		else
			req.session.inCart[itemi._id] = itemi 
		@ProductosModel.findById itemi._id, (err, item)=>
			if item 
				if itemi.cantidad*1 is item.cantidad*1#delete.
					item.remove (err, item)=>
						console.log 'delete'
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"#{itemi.cantidad} agregado(s) al carrito", posicion:'arriba-derecha'}
						@app.io.broadcast('ventas:addToCart', req.data)#enviar al cliente.
				else#update.
					item.cantidad -= itemi.cantidad*1
					item.save (err, item)=>
						console.log 'update'
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"#{itemi.cantidad} agregado(s) al carrito", posicion:'arriba-derecha'}
						@app.io.broadcast('ventas:addToCart', req.data)#enviar al cliente.
			else
				console.log 'producto no encontrado.'
	
	delToCart:(req, resp)=>
		id = req.data.id
		@restoreItem(id, req)
		@app.io.broadcast('ventas:delToCart', req.data)#enviar al cliente.		

	cancelShopp:(req, resp)=>
		@restoreItem(id, req) for id, item of req.session.inCart
		@app.io.broadcast('ventas:cancelShopp', req.data)#enviar al cliente.

	restoreItem:(id, req)=>
		# clone
		itemi = {}
		itemi[prop] = val for prop, val of req.session.inCart[id]
		#delete		
		delete req.session.inCart[id]
		console.log req.session.inCart
		@ProductosModel.findById id, (err, item)=>
			if item#update.
				item.cantidad += itemi.cantidad*1
				item.save (err, item)=>
			else#add.	
				item = new  @ProductosModel itemi
				item.save (err, item)=>

	shopp:(req, resp)=>
		fecha = new Date()
		cliente = req.data.cliente
		tipoVenta = req.data.tipoVenta
		# console.log req.session.inCart
		# add in the collections ventas.
		for key, item of req.session.inCart
			delete item._id
			delete item.__v
			item.tipoVenta = tipoVenta
			item.precioVenta = if tipoVenta is 'recibo' then item.precio_recibo else item.precio_factura 
			item.fecha = fecha
			item.cliente = cliente
			itemVenta = new @VentasModel item
			itemVenta.save (err, itemVenta)=>
				if err 
					console.error(err)
		req.session.inCart = {}
		req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Venta Realizada.'}
		@app.io.broadcast('ventas:shopp', req.data)


module.exports = (moongose, app)->	new VentasController(moongose, app)