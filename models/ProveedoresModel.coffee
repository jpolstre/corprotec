model = undefined
module.exports = (mongoose)->
	# create Collection. first
	proveedorSchema = mongoose.Schema
		nombre: String
		ci_nit: String
		fonos: []
		direcciones:[]
		emails:[]
	
	if mongoose.modelNames().indexOf('Proveedores') is -1#si no existe creamos el esquema.
		model = mongoose.model('Proveedores', proveedorSchema)
	#si existe enviamos el ya creado.
	model