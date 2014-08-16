
model = undefined
module.exports = (mongoose)->
	# create Collection. first
	ProductosSchema = mongoose.Schema
		fecha:{ type: Date, default: Date.now }
		serie:{type:String, default:'----------'}
		codigo:String
		descripcion:String
		precio_recibo:Number
		precio_factura:Number
		cantidad:Number
		costo:Number
		utilidad:Number
		garantia:String
		proveedor:String
	
	if mongoose.modelNames().indexOf('Productos') is -1
		model = mongoose.model('Productos', ProductosSchema)
	
	# console.log model
	model