class ComprasController
	iva: 17
	constructor:(moongose, app)->
		# models for working in this controller.
		@ComprasModel = require('../models/ComprasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		# @moment = require('moment')
		@app = app
		

		# utils.
		# @hash = require('../libs/password')

	shopp:(req, resp)=>
		fecha = new Date()
		# dataResp = []
		for compra in req.data.compras
			compra.fecha = fecha
			series = compra.series.split ','
			delete compra.series
			for serie in series 
				compra.serie = serie.trim()
				compra.cantidad = if serie is '----------' then compra.cantidad else 1
				unaCompra = new @ComprasModel compra
				unaCompra.save (err, unaCompra)=>
					if err 
						console.error(err)
						req.data.msg = {tipo:'error', titulo:'Error', texto:'no Se Pudo Comprar, Error en el servidor.'}
						@app.io.broadcast('compras:shopp', req.data)
				
				compra.precio_recibo = parseFloat(compra.costo*1 + compra.utilidad*1).toFixed(2) 
				compra.precio_factura = parseFloat(compra.precio_recibo*1 + (compra.precio_recibo*@iva)/100).toFixed(2)
				
				unaCompra = new @ProductosModel compra
				unaCompra.save (err, unaCompra)=>
					if err 
						console.error(err)
						req.data.msg = {tipo:'error', titulo:'Error', texto:'no Se Pudo Comprar, Error en el servidor.'}
						@app.io.broadcast('compras:shopp', req.data)
			# for response.
			# compra._id = unaCompra._id
			# objResp = {}	
			# objResp.docdata = compra

			# dataResp.push objResp	
		# req.data.compras = dataResp
		# console.log req.data
		req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Compras Realizadas.'}
		@app.io.broadcast('compras:shopp', req.data)#enviar al cliente.
		
	prodReg:(req, resp)=>				#ultima compra										 #todos los costos							#el primero. el de menor fecha todos los registros dela tabla ComprasModel
		@ComprasModel.aggregate().sort('fecha').group({_id:'$codigo', series: { $addToSet: "$serie" }, costos: { $addToSet: "$costo" }, docdata:{$last:"$$ROOT"}}).exec (err, compras)=>
			# ().distinct('codigo').populate('codigo').sort({fecha:'asc'}).exec (err, compras)=>
			# console.log compras
			respData = {}
			respData.data = compras
			resp.jsonp respData

	newCompra:(req, resp)=>
		# req.params.fecha = Date.now
		console.log req.params
		unaCompra = new @ComprasModel req.params
		unaCompra.save (err, compra)=>
			unProducto = new @ProductosModel req.params
			unProducto.precio_recibo = parseFloat(compra.costo*1 + compra.utilidad*1).toFixed(2) 
			unProducto.precio_factura = parseFloat(unProducto.precio_recibo*1 + (unProducto.precio_recibo*@iva)/100).toFixed(2)   
			unProducto.save (err, producto)=>
				if err 
					console.error(err)
				else
					console.log unProducto		
					resp.send 'ok creado'

	shopping:(req, resp)=>
		@app.io.broadcast('ventas:shopp', req.data)

module.exports = (moongose, app)->	new ComprasController(moongose, app)
