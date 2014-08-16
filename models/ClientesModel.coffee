model = undefined
module.exports = (mongoose)->
	# create Collection. first
	clienteSchema = mongoose.Schema
		nombre: String
		ci_nit: String
		fonos: []
		direcciones:[]
		emails:[]
	
	if mongoose.modelNames().indexOf('Clientes') is -1#si no existe creamos el esquema.
		model = mongoose.model('Clientes', clienteSchema)
	#si existe enviamos el ya creado.
	model