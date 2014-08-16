allUsers = {}

serializeForm = (formJq)->
	data = {}
	formJq.find('input:text, select').each (i)->
		elJq = $(this)
		data[elJq.attr('name')] = elJq.val()
	privilegios = []
	formJq.find('div.privilegios input:checkbox').each (i)->
		elJq = $(this)
		if elJq.is ':checked'
			privilegios.push elJq.attr 'name'	
	data.privilegios = privilegios
	pass = formJq.find('#rewPass').val()
	data.password = pass if pass isnt '' 
	data

formHtml = (opt)->
	htmlForm = "<form class='form-horizontal'role='form'>"
	htmlForm += "<div class='form-group'>
		<label for='name' class='col-lg-3 control-label'>Nombre</label>
		<div class='col-lg-8'>
			<input type='text' autofocus class='form-control' id='name' name='name' validar='requiere'>
		</div>
	</div>
	<div class='form-group'>
			<label for='email' class='col-lg-3 control-label'>Email</label>
			<div class='col-lg-8'>
				<input type='text' class='form-control' id='email' name='email' validar='email'>
			</div>
		</div>"
	htmlForm += "<div class='form-group'>
		<label for='privilegios' class='col-lg-3 control-label'>Privilegios</label>
		<div class='col-lg-8'>
			<div id='blk-privilegio' class='privilegios' validar='especial'>
				<label class='checkbox'>
					<input type='checkbox' name='inicio'> Inicio 
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='compras'> Compras 
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='ventas'> Ventas 
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='usuarios'> Usuarios
				</label>
			</div>
		</div>
	</div>"
	htmlForm += "<div class='form-group'>
		<label for='estado' class='col-lg-3 control-label'>Estado</label>
		<div class='col-lg-8'>
			<select type='text' class='form-control' id='estado' name='estado' validar='requiere'>
				<option></option>
				<option>Habilitado</option>
				<option>Bloqueado</option>
			</select>
		</div>
	</div>"
	if opt is 'edit'
		htmlForm += "<div class='form-group chk'>
			<div class='col-lg-offset-2 col-lg-10'>
				<div class='checkbox'>
					<label>
						<input type='checkbox' name='chk'> Cambiar Password
					</label>
				</div>
			</div>
		</div>"
		htmlForm += "<div class='cnt-pass' style='display:none;'>"
	else
		htmlForm += "<div class='cnt-pass'>"
	arrayPass = {newPass:'Password', rewPass:'Reescribir pass'}#oldPass:'Anterio pass', 
	for key, val of arrayPass
		htmlForm += "<div class='form-group'>
			<label for='#{key}' class='col-lg-3 control-label'>#{val}</label>
			<div class='col-lg-8'>
				<input type='password' class='form-control' id='#{key}' name='#{key}' validar='requiere#{if key is "rewPass" then ",igual_a|newPass" else ""}'>
			</div>
		</div>" 
	htmlForm += "</div></form>"
	htmlForm
class User
	constructor: (@options = {}) ->
		@html = "<div class='col-lg-5' id='#{@options._id}' >
			<div class='panel panel-info'>
				<div class='panel-heading'>
					<i class='fa fa-user fa-2x'></i> <strong>#{@options.name}</strong>
				</div>
				<div class='panel-body'>
					<p><strong>Email: </strong>#{@options.email}</p>	      	
					<p><strong>Privilegio: </strong>#{@options.privilegios}</p>	      	
					<p><strong>Estado: </strong>#{@options.estado}</p>	      	
				</div>
				<div class='panel-footer'>
					<div class='btn-group btn-group-sm'>
						<button type='button' class='btn btn-info'><i class='fa fa-pencil fa-fw'></i> Editar</button>
						<button type='button' class='btn btn-danger'><i class='fa fa-minus fa-fw'></i> Eliminar</button>
					</div>
				</div>
			</div>
		</div>"
	
		###
			<select type='text' class='form-control' id='#{key}' name='#{key}' validar='requiere'>
				<option></option>
				<option>Administrador</option>
				<option>Empleado</option>
			</select>
		###
	addTo:(jqElement)->
		@jq = $(@html).appendTo jqElement
		@panelJq = $('div.panel', @jq)
		$('button:first', @jq).click (e)=> 
			@panelJq.removeClass().addClass('panel panel-danger')
			@edit()
		$('button:last', @jq).click (e)=> 
			@panelJq.removeClass().addClass('panel panel-danger')
			@delete()
			
	delete:->
		# first confirm
		modConfirmar = new Modal
			titulo:if @options.name is globalUser then 'Eliminar - Usuario (<small>El sitema se reinicia</small>)' else 'Eliminar - Usuario' 
			tipo:'confirmacion'
			#icono:'images/admin/icons/packs/fugue/24x24/alert.png'
			contenido: "Realmente desea eliminar este usuario?"
			accionSi:() =>
				modConfirmar.cerrar =>
					io.emit('users:delete', {id:@options._id, userDelete:@options.name, userAction:globalUser})#emitir. al servidor, en vez de ajax.
					
			despuesDeCerrar:(mjq)=>
				@panelJq.removeClass().addClass('panel panel-info')
	edit:->
		editModal = new Modal
			titulo:if @options.name is globalUser then 'Editar - Usuario (<small>El sitema se reinicia</small>)' else 'Editar - Usuario' 
			tipo:'formulario'
			contenido:formHtml('edit')
			antesDeMostrar:(jq)=>
				ctnPassJq = $('div.cnt-pass')
				$('div.chk input:checkbox', jq).click ->
					if $(this).is(':checked')
						ctnPassJq.show()
					else
						ctnPassJq.hide()
				jq.find("input##{key}, select##{key}").val val for key, val of @options when key isnt '_id'
				privilegios = @options.privilegios
				jq.find('div#blk-privilegio input:checkbox').each (e)->
					elChkJq = $(this)
					if _.indexOf(privilegios, $.trim(elChkJq.attr('name'))) isnt -1
						elChkJq.trigger 'click'			

			despuesDeCerrar:(mjq)=>
				@panelJq.removeClass().addClass('panel panel-info')
				
		new Validador
			formulario:editModal.jq.find('form:first')
			procesarFormulario:(formJq)=>
				# alert formJq.serialize()
				console.log serializeForm(formJq)
				editModal.cerrar =>
					io.emit('users:edit', {id:@options._id, newData:serializeForm(formJq), userAction:globalUser, useredit:@options.name})#emitir. al servidor, en vez de ajax.

				# $.ajax
				# 	url:"usuarios/saveUser/#{@options.id}/"
				# 	type:'GET'
				# 	data:formJq.serialize()
				# 	dataType:'json'
				# 	success:(resp)=>
				# 		msg = resp.msg
				# 		if msg.tipo is 'exito'
				# 			editModal.cerrar =>
				# 				@updateHtml(resp.user)
				# 				@pbodyJq.effect('highlight', {}, 5000)
				# 			new Alerta msg
				# 			if beforeNick is globaUser
				# 				setTimeout ->
				# 					window.location.replace('logout')
				# 				,2000
				# 		else
				# 			new Alerta msg

	updateHtml:(newData)->
		(@options[key] = val if @options[key]) for key, val of newData
		$('div.panel-heading strong', @jq).text @options.name
		$('div.panel-body', @jq).html "<p><strong>Email: </strong>#{@options.email}</p><p><strong>Privilegio: </strong>#{@options.privilegios}</p><p><strong>Estado: </strong>#{@options.estado}</p>"	      	

$(window).load ->
	contentJq = $('div.users-content')#.sortable {items: 'div.col-lg-4'}
	#escuchadores de acciones (para modificar el DOM tags html).
	io.on 'users:create', (data)->
		if data.msg.tipo is 'exito'
			user = new User data.user
			user.addTo contentJq
			allUsers[data.user._id] = user
			
			console.log data.userAction+'---'+globalUser
			if data.userAction isnt globalUser# para los otros usuarios.
				data.msg.tipo = 'info'
				data.msg.titulo = 'Informacion'
				data.msg.texto = "El usuario <strong>#{data.userCreate}</strong>a sido creado"
			new Alerta data.msg
		else
			if data.userAction is globalUser
				new Alerta data.msg 

	io.on 'users:delete', (data)->
		console.log data
		msg = data.msg
		el = allUsers[data.id]
		el.jq.fadeOut 'medium', ->
			el.jq.remove()
			`delete el`
			if data.userAction isnt globalUser# para los otros usuarios.
				msg.tipo = 'info'
				msg.titulo = 'Informacion'
				msg.texto = "!El usuario <strong>#{data.userDelete}</strong> a sido eliminado."
			new Alerta msg
		if data.userDelete is globalUser
			setTimeout ->
				window.location.replace('/')
			,2000

	# updateHtml = (newData)->
	# 	(@options[key] = val if @options[key]) for key, val of newData
	# 	$('div.panel-heading strong', @jq).text @options.name
	# 	$('div.panel-body', @jq).html "<p><strong>Email: </strong>#{@options.email}</p><p><strong>Privilegio: </strong>#{@options.privilegios}</p><p><strong>Estado: </strong>#{@options.estado}</p>"	      	

	io.on 'users:edit', (data)->
		user = allUsers[data.id]
		user.updateHtml data.newData
		if data.userAction is globalUser
			new Alerta data.msg
			
		if data.useredit is globalUser
			data.msg.tipo = 'info'
			data.msg.titulo = 'Informacion'
			data.msg.texto = "!Tu cuenta a sido modificada el sistema se reiniciara."
			new Alerta data.msg
			setTimeout ->
				window.location.replace('/')
			,2000

		# updateHtml.call(data.userObj, data.newData)
		# msg = data.resp.msg
		# if msg.tipo is 'exito'
		# 	@updateHtml(resp.user)
		# 	@pbodyJq.effect('highlight', {}, 5000)
		# 	new Alerta msg
		# 	if beforeNick is globaUser
		# 		setTimeout ->
		# 			window.location.replace('logout')
		# 		,2000
		# else
		# 	new Alerta msg
	
	# elmesFormAdd = $('div#addUser input:text, div#addUser input:password, div#addUser select').val ''
	# chekboxesJq = $('input:checkbox')
	# clearFunc = ->
	# 	elmesFormAdd.val ''
	# 	chekboxesJq.each (indx)->
	# 		thisEljq = $(this)
	# 		thisEljq.trigger('click') if thisEljq.is(':checked')

	# 	val.ocultarMensajes()
	# 	setTimeout ->
	# 		$(elmesFormAdd[0]).focus()
	# 	,0 
	# $('div#addUser').on('show.bs.collapse', -> clearFunc())
	# $('div.col-md-offset-3 button:first').click -> clearFunc()
	$('button#btn-addUser').on 'click', (e)->
		addUserModal = new Modal
			titulo:'Nuevo - Usuario' 
			tipo:'formulario'
			contenido:formHtml('add')
			despuesDeMostrar:(jq)->
				setTimeout ->
					jq.find('input#name').focus()
				,800
	
		val = new Validador
			formulario:addUserModal.jq.find('form')
			procesarFormulario:(jqForm)->
				#console.log serializeForm(jqForm)
				addUserModal.cerrar ->
					dataUser = serializeForm(jqForm)
					# console.log dataUser
					# console.log globalUser
					io.emit('users:create', {usuario:dataUser, userAction:globalUser, userCreate:dataUser.name})#emitir. al servidor, en vez de ajax.

			# CREAR NUEVO USUARIO.
				# alert jqForm.serialize()
				# $.ajax
				# 	url:'usuarios/saveUser/'
				# 	type:'GET'
				# 	dataType:'json'
				# 	data:jqForm.serialize()
				# 	success:(resp)->
				# 		msg = resp.msg
				# 		if msg.tipo is 'exito'
				# 			user = new User resp.user
				# 			clearFunc()
				# 			user.addTo contentJq
				# 			user.jq.hide()
				# 			user.jq.fadeIn 'slow', ->
				# 				new Alerta resp.msg
								
				# 		else
				# 			new Alerta resp.msg

	$.ajax
		url:'/users/getAll'
		jsonp: "callback",
		dataType:'jsonp'
		success:(users)->
			for useri, i in users
				user = new User useri	
				user.addTo contentJq
				
				allUsers[useri._id] = user
				
	# console.log window
