model = undefined

module.exports = (mongoose)->
	# create Collection. first
	ventasSchema = mongoose.Schema
		fecha: { type:Date, default: Date.now }
		serie: { type:String, default:'----------'}
		codigo:String
		descripcion:String
		tipoVenta:String
		precioVenta:Number
		cantidad:Number
		costo:Number
		precio_recibo:Number
		precio_factura:Number
		utilidad:Number
		garantia:String
		proveedor:String
		cliente:String
	
	if mongoose.modelNames().indexOf('Ventas') is -1#si no existe creamos el esquema.
		model = mongoose.model('Ventas', ventasSchema)
	#si existe enviamos el ya creado.
	model