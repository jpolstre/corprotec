class ProductosController
	constructor:(moongose, app)->
		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		# @moment = require('moment')
		@app = app
		
	getAll:(req, resp)=>			#primera compra	
		@ProductosModel.find({}).sort('-fecha').exec (err, compras)=>
			respData = {}
			respData.data = compras
			resp.jsonp respData

module.exports = (moongose, app)->	new ProductosController(moongose, app)
