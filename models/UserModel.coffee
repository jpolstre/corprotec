module.exports = (mongoose)->
	# create Collection. first

	UserSchema = mongoose.Schema
		name: String
		password: String
		email: String
		estado: String
		privilegios: []#puede ser tambien []
		conectado:{type:String, default:'off'}

	mongoose.model('User', UserSchema)