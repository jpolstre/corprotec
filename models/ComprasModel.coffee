model = undefined

module.exports = (mongoose)->
	# create Collection. first
	ComprasSchema = mongoose.Schema
		fecha: { type:Date, default: Date.now }
		serie: { type:String, default:'----------'}
		codigo: String
		descripcion: String
		costo:Number
		cantidad:Number
		utilidad:Number
		garantia:String
		proveedor:String
	
	if mongoose.modelNames().indexOf('Compras') is -1#si no existe creamos el esquema.
		model = mongoose.model('Compras', ComprasSchema)
	#si existe enviamos el ya creado.
	model