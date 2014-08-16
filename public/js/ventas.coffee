# globals
tablaVentas = undefined
numItemsJq = $('span#num-items')
msgCarritoJq = $('div#msg-carrito')
AuxObjAttribs = ['serie', 'codigo', 'descripcion', 'cantidad', 'precio_recibo', 'precio_factura', 'subtotal']

htmlCliente = '<form class="form-horizontal">'
htmlCliente += "
<div class='form-group'>
	<label for='proveedor' class='col-md-3  control-label'>Proveedor:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='proveedor' name='proveedor' validar='requiere'>
	</div>
</div>"
htmlCliente += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'


formHtmlEditarItem = '<form class="form-horizontal">'
for item in AuxObjAttribs when item isnt 'subtotal'
	formHtmlEditarItem += "
	<div class='form-group'>
		<label for='#{item}' class='col-md-3  control-label'>#{item}:</label>
		<div class='col-md-7'>
			<input type='text' class='form-control upper' id='#{item}' name='#{item}' validar='requiere'>
		</div>
	</div>"
formHtmlEditarItem += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'

class ShoppingCart
	tipoPrecio:'recibo'
	numRows:0
	numItems:0
	itemsInCart:{}
	objAttribs:AuxObjAttribs#for order.
	# upOrCreIdexesRows:[]
	html: "<table class='table table-striped table-bordered table-hover' style='display:none;' id='carrito-compra'>
						<thead>
							<tr>
								<th>Serie</th>
								<th>Codigo</th>
								<th>Descripcion</th>
								<th>Cantidad</th>
								<th>precio_recibo</th>
								<th>precio_factura</th>
								<th>Subtotal</th>
								<th>Opciones</th>
							</tr>
						</thead><tbody></tbody><tfoot><tr><td colspan='6'>TOTAL</td><td colspan='2' id='tolal'></td></tr><tr><td colspan='8' style='text-align:center;'><button class='btn btn-danger'>Cancelar</button> <button class='btn btn-success'>Vender</button></td></tr></tfoot></table>"
	
	addTo:(elJq)->
		scope = @
		@jq = $(@html).appendTo elJq
		@tBodyJq = $('tbody', @jq)
		@totalJq = $('td#tolal', @jq)
		@tBodyJq.on 'click', 'button', (e)->
			if $(this).attr('alt') is 'eliminar'
				scope.delRow($(this).parent().parent())
			else
				scope.editRow($(this).parent().parent())
		$('tfoot', @jq).on 'click', 'button', (e)->
			if $(this).attr('class') is 'btn btn-danger'
				scope.cancelShopp()
			else
				# shopp
				scope.shopp()
	shopp:->
		modalCliente = new Modal
			titulo:'Cliente'
			tipo:'formulario'
			contenido: htmlCliente
			despuesDeMostrar:(ModalJq)->
				# alert 'ok'
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					ModalJq.find('input:text:first').focus()		
				,500

			antesDeMostrar:(ModalJq)->
				ModalJq.find('div.modal-footer button:first').text 'ok' 
		
		new Validador
			formulario:modalCliente.jq.find('form:first')
			procesarFormulario:(formJq)=>
				modalCliente.cerrar =>
					cliente = formJq.find('input:text').val()
					# console.log @itemsInCart
					# comprasArr = @serialize formJq.find('input:text').val() 
					item.proveedor = proveedor for item in @itemsInCart

					io.emit('ventas:shopp', {cliente:cliente, tipoVenta:@tipoPrecio, userAction:globalUser})
	restar:->
		@itemsInCart = {}
		# @upOrCreIdexesRows = []
		@numRows = 0
		@numItems = 0
		numItemsJq.text @numItems
		@tBodyJq.html ''
		@jq.hide()
		msgCarritoJq.show()

	cancelShopp:->
		modalConfirm = new Modal
			titulo:'Confirmar - Cancelar Compra'
			tipo:'confirmacion'
			contenido:"<p>Realmente desea cancelar esta compra?</p>"
			accionSi: =>
				modalConfirm.cerrar =>
					@itemsInCart = {}
					# @upOrCreIdexesRows = []
					@numRows = 0
					@numItems = 0
					numItemsJq.text @numItems
					@tBodyJq.html ''
					@jq.fadeOut 'fast', ->
						msgCarritoJq.fadeIn('fast')
					io.emit('ventas:cancelShopp', {userAction:globalUser})
			antesDeMostrar:(jqModal)->
				btnsi = jqModal.find('button.btn-danger').text('SI')
				jqModal.find('button:last').text('NO').click (e)->
					modalConfirm.cerrar()
					
	sumColumn:(index)->
		sum = 0
		@tBodyJq.find('tr').each (i)->
			valTd = $(this).find("td:eq(#{index})").text()*1
			sum += valTd
		sum

	calcSubtotal:()->#y suma total de paso.
		# @tipoPrecio = tipo
		index = if tipo is 'recibo' then 4 else 5 
		sum = 0
		@tBodyJq.find('tr').each (i)->#recibo o factura.
			cantidad = $(this).find("td:eq(#{3})").text()*1
			valTd = $(this).find("td:eq(#{index})").text()*1
			subTotali = parseFloat(cantidad*valTd).toFixed 2
			$(this).find("td:eq(#{6})").text subTotali 
			sum += subTotali*1
		@totalJq.text parseFloat(sum).toFixed 2

	editRow:(trJq)->
		dtsJq = trJq.find('td')
		modalEditar = new Modal
			titulo:'Editar - Item (Compra)'
			tipo:'formulario'
			contenido: formHtmlEditarItem
			despuesDeMostrar:(modalJq)->
				for item, i in AuxObjAttribs when item isnt 'subtotal'
					elTdVal = $(dtsJq[i]).text()
					elJq = $("input##{item}", modalJq)
					elJq.val elTdVal
					if elTdVal is '----------'
						elJq.attr 'disabled', 'disabled'
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					modalJq.find('input:text:first').select()		
				,500

			antesDeMostrar:(modalJq)->
				modalJq.find('div.modal-footer button:first').text 'ok' 
		
		new Validador
			formulario:modalEditar.jq.find('form:first')
			procesarFormulario:(formJq)=>
				cantidad = $('input#cantidad', formJq).val()
				seriesJq = $('input#series', formJq)
				seriesArr = seriesJq.val().split ','
				# console.log cantidad+'---'+seriesArr.length
				if cantidad*1 is seriesArr.length*1 or seriesJq.val() is '----------'     
					modalEditar.cerrar =>
						for item, i in AuxObjAttribs 
							elTdJq = $(dtsJq[i])
							elVal = $("input##{item}", formJq).val()
							elTdJq.text elVal
							if item is 'subtotal'
								elTdJq.text $(dtsJq[3]).text()*1*$(dtsJq[4]).text()
						@totalJq.text parseFloat(@sumColumn 6).toFixed 2
						@numItems = @sumColumn 3
						numItemsJq.text @numItems

				else
					new Alerta
						tipo:'error'
						titulo:'Error'
						texto: "debe escribir #{cantidad} serie(s)"
						posicion:'arriba-izquierda'
						
					
	addRow:(rowObj)->
		addItem = =>#add table shoppincart
			@numRows++
			@numItems += rowObj.cantidad*1
			numItemsJq.text @numItems
			precio = if @tipoPrecio is 'recibo' then rowObj.precio_recibo else rowObj.precio_factura
			rowObj.subtotal =  parseFloat(rowObj.cantidad*1*precio).toFixed(2)
			htmlRow = "<tr id=#{rowObj._id}>"
			htmlRow += "<td>#{rowObj[attr]}</td>" for attr in @objAttribs
			htmlRow += '<td><button type="button" class="btn btn-danger btn-circle" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info btn-circle" alt="editar"><i class="fa fa-pencil"></i></button></td>'
			htmlRow += '</tr>'
			$(htmlRow).appendTo @tBodyJq
			@totalJq.text parseFloat(@sumColumn 6).toFixed 2 	
			if @numRows is 1
				msgCarritoJq.hide()
				@jq.show()
			# new Alerta
			# 	tipo:'info'
			# 	titulo:'Item(s) Agregado'
			# 	texto: "#{rowObj.cantidad} Item(s) agregados al carrito."
			# 	posicion:'arriba-centro'
			delete rowObj.subtotal
			@itemsInCart[rowObj._id] = rowObj
		# {codigo:'XXDDGG', descripcio:'Una descripcion', ...}
		if rowObj.serie is '----------'
			item = @itemsInCart[rowObj._id]
			if item isnt undefined #update tavble shoppincart.
				@numItems += rowObj.cantidad*1
				numItemsJq.text @numItems
				trJq = $("tr##{item._id}", @tBodyJq)
				cantidadJq = trJq.find('td:eq(3)')
				cantidadJq.text cantidadJq.text()*1+rowObj.cantidad*1
				precio = if @tipoPrecio is 'recibo' then item.precio_recibo else item.precio_factura
				cantidad = cantidadJq.text()
				trJq.find('td:eq(6)').text parseFloat(cantidad*1*precio).toFixed(2)
				@totalJq.text parseFloat(@sumColumn 6).toFixed 2
				item.cantidad = cantidad*1
			else
				addItem()
		else
			addItem()

	delRow:(rowJq)->
		cantidad = rowJq.find('td:eq(3)').text()
		@numRows--
		@numItems -= cantidad*1
		numItemsJq.text @numItems
		rowJq.fadeOut 'medium', =>
			rowJq.remove()
			if @numRows is 0
				@jq.hide()
				msgCarritoJq.show()
		id = rowJq.attr 'id'
		# item = @itemsInCart[id]
		console.log item
		
		# if item.serie is '----------'#update
		# 	item.rowTable.remove().draw()
		# 	delete item.rowTable
		# 	item.cantidad += 1*cantidad
		# 	tablaVentas.row.add(item).draw()
		# else#add.
		# 	delete item.elTrNode
		# 	tablaVentas.row.add(item).draw()
		delete @itemsInCart[id]
		io.emit('ventas:delToCart', {id:id, userAction:globalUser})	

	serialize:(proveedor)->	
		resultArr = []
		gthis = @
		@tBodyJq.find('tr').each (i)->
			tds = $(this).find('td')
			objEl = {}
			for attr, inx in gthis.objAttribs when attr isnt 'subtotal'
				objEl[attr] = $(tds[inx]).text()
			objEl.proveedor = proveedor
			resultArr.push objEl
		resultArr#[{codgo:'SHJKHK', descripcion:'una des', ..}, {codigo:'FDGDGF', descripcion:'Otra descripcion', ..}, ..] insert in DB Mongo.


$(document).ready ->
	console.log window.location
	# day = moment('2014-07-19T16:10:59.568Z')
	# console.log day.format("MM-DD-YYYY")
	# ESCUCHADORES.
	io.on 'ventas:addToCart', (data)->
		# and update table for all users.
		# for item, i in data.compras
		# 	indexRow = shoppingCart.upOrCreIdexesRows[i]
		# 	if indexRow is -1#create
		# 		tablaVentas.add(shoppingCart.itemsInCart[i])
		# 	else#update.
		# 		tablaVentas.row(indexRow).data(item)
		# tablaVentas.ajax.reload()
		tablaVentas.ajax.reload()
		if data.userAction is globalUser
			# shoppingCart.restar()
			shoppingCart.addRow data.item
			inputSearchJq.val('').trigger('keyup').focus()
			new Alerta data.msg 

	io.on 'ventas:delToCart', (data)->
		tablaVentas.ajax.reload()
		
	io.on 'ventas:cancelShopp', (data)->
		tablaVentas.ajax.reload()

	io.on 'ventas:shopp', (data)->
		tablaVentas.ajax.reload()
		if data.userAction is globalUser
			# shoppingCart.restar()
			shoppingCart.restar()
			new Alerta data.msg 

	# io.on 'compras:shopping', (data)->
	# 	tablaVentas.ajax.reload()
		# if data.userAction is globalUser
		# 	# shoppingCart.restar()
		# 	shoppingCart.restar()
		# 	new Alerta data.msg 
	
	tablaVentasJq = $('#productos-registrados')
	contTablaVentJq = tablaVentasJq.parent()
	tablaVentas = tablaVentasJq.DataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/productos/getAll',
		"columns": [
			{ "data": "_id" }
			{ "data": "fecha" }
			{ "data": "serie" }
			{ "data": "codigo" }
			{ "data": "descripcion" }
			{ "data": "costo" }
			{ "data": "cantidad" }
			{ "data": "utilidad" }
			{ "data": "garantia" }
			{ "data": "proveedor" }
			{ "data": "precio_recibo" }
			{ "data": "precio_factura" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)-> $(td).text moment(cellData).format("DD-MM-YYYY H:mm:ss")}
			{ "visible": true, "targets": 2 }
			{ "targets": 3, "createdCell":(td, cellData, rowData, row, col)-> 
				$(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
			}
			{ "targets": 4, "createdCell":(td, cellData, rowData, row, col)-> 
				$(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
			}
			{ "visible": false, "targets": 5 }
			{ "visible": true, "targets": 6 }
			{ "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": false, "targets": 9 }
			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'asc'],
		# "ordering": false

	showHideMenujq = $('div.show-hide-colms')
	$(document).ajaxComplete (event, xhr, settings)->
		tablaVentasJq.css('width', '')
		showHideMenujq.show()
	
	#hide/show columns.
	$('ul.dropdown-cols input:checkbox').on 'click', (event)->
		column = tablaVentas.column( $(this).attr('data-column') );
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaVentasJq.css('width', '')

	#tabs
	# btnsTabs = $('button.btns-tabs')
	# ctnsTabs = $('div.tab-pane')
	# btnsTabs.on 'click', (evt)->
	# 	elJq = $(this);
	# 	btnsTabs.removeClass('active')
	# 	elJq.addClass('active')
	# 	ctnsTabs.hide()
	# 	$('div#'+elJq.attr('name')).show()

	#carousel.
	actualNum = 0
	carouselItem = $('div#item-compra').carousel interval: false
	$('ol.breadcrumb').on 'click', 'a', (evt)->
		evt.preventDefault()
		num = $(this).attr('data-target')*1
		if actualNum isnt num
			carouselItem.carousel num
			actualNum = num
	# en transition carousel.
	carouselItem.on 'slid.bs.carousel', (e)->
		inputSearchJq.focus() if inputSearchJq.is ':visible'
	#select option.
	# cantidadJq = 	$("input#cantidad")
	# valArray = {codigo:$('input#codigo'), descripcion:$('textarea#descripcion'), costo:$('input#costo'), utilidad:$('input#utilidad'), garantia:$('input#garantia')}
	# titlePanelJq = $('span#title-panel')
	rowTable = {}
	itemElegido = {}
	htmlCantdad = "<form class='form-horizontal'>
			<div class='form-group'>
				<label for='cantidad' class='col-md-3  control-label'>Cantidad:</label>
				<div class='col-md-5'>
					<input type='text' class='form-control upper' id='cantidad' name='cantidad' placeholder='Cantidad a vender' validar='requiere'>
				</div>
			</div><input type='submit' style='width:0px;height:0px;margin:0;padding:0;border:none;'></form>"
	$('tbody', tablaVentasJq).on 'click', 'a', (evt) ->
		evt.preventDefault()
		elTrNode = $(this).parents('tr')[0]
		indexElegido = tablaVentas.row(elTrNode).index()
		console.log 'elindice elegido es: '+indexElegido
		console.log tablaVentas.row indexElegido
		# shoppingCart.upOrCreIdexesRows.push indexElegido
		rowTable =  tablaVentas.row(indexElegido)
		# console.log rowTable
		itemElegido = rowTable.data()
		# console.log itemElegido
		if itemElegido.cantidad*1 > 1
			modalCantidad = new Modal
				titulo:'Cantidad A Vender'
				tipo:'formulario'
				contenido: htmlCantdad
				despuesDeMostrar:(ModalJq)->
					# alert 'ok'
					setTimeout ->
						# alert ModalJq.find('input:text:first').attr('class')
						ModalJq.find('input:text:first').focus()		
					,500
				antesDeMostrar:(ModalJq)->
					ModalJq.find('div.modal-footer button:first').text 'ok' 
			new Validador
				formulario:modalCantidad.jq.find('form:first')
				procesarFormulario:(fromJq)=>
					cantidad = fromJq.find('input:text:first').val()
					if cantidad*1 > itemElegido.cantidad*1
						new Alerta
							tipo:'error'
							titulo:'Error'
							texto: "Solo se dispone de #{itemElegido.cantidad} Productos de este tipo"
							posicion:'arriba-izquierda'
					else
						modalCantidad.cerrar ->
							itemElegido.cantidad = cantidad*1
							io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})	

							# if itemElegido.cantidad is 0#delete tr row.
							# 	# $(elTrNode).fadeOut 'faste', ->
							# 	rowTable.remove().draw()

							# else#update tr row.
							# 	rowTable.data(itemElegido).draw()
							# 	$(elTrNode).find('td.selectable-td:first').html("<a href='javascript:;'>#{itemElegido.codigo}</a>")
							# 	$(elTrNode).find('td.selectable-td:last').html("<a href='javascript:;'>#{itemElegido.descripcion}</a>")
							# 	$(elTrNode).find('td:first').text moment(itemElegido.fecha).format("DD-MM-YYYY H:mm:ss")
						
							# # console.log tablaVentas.row(indexElegido).data()
							# itemElegido.cantidad = cantidad
							# precio = if shoppingCart.tipoPrecio is 'recibo' then itemElegido.precio_recibo else itemElegido.precio_factura
							# itemElegido.subtotal =  parseFloat(cantidad*1*precio).toFixed(2)
							
							# itemElegido.rowTable = rowTable

							# shoppingCart.addRow itemElegido
							# itemElegido.cantidad = auxCantidad
		else
			io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})
		# else
			# rowTable.remove().draw()
			# precio = if shoppingCart.tipoPrecio is 'recibo' then itemElegido.precio_recibo else itemElegido.precio_factura
			# itemElegido.subtotal = parseFloat(itemElegido.cantidad*1*precio).toFixed(2)
			# shoppingCart.addRow itemElegido

	#btn search.
	inputSearchJq = $('input.input-sm', contTablaVentJq)
	$('input.tipo_precio').on 'change', ->
		shoppingCart.tipoPrecio = $(this).val()
		shoppingCart.calcSubtotal() if shoppingCart.numRows > 0
					
	shoppingCart = new ShoppingCart()

	shoppingCart.addTo $('div.table-responsive:eq(1)')#ok
	# shoppingCart.addRow {series:'DDS-124', codigo:'XXX', descripcion:'Descripcion de XXX', costo:1456, cantidad:4, utilidad:178, garantia:'1 anio'}
	`$(window).on('beforeunload', function(e) {
			io.emit('ventas:cancelShopp', {
				userAction: globalUser
			});
		})`
	
