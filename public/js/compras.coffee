# globals
numItemsJq = $('span#num-items')
msgCarritoJq = $('div#msg-carrito')
AuxObjAttribs = ['series', 'codigo', 'descripcion', 'costo', 'cantidad', 'utilidad', 'garantia', 'subtotal']

htmlProveedor = '<form class="form-horizontal">'
htmlProveedor += "
<div class='form-group'>
	<label for='proveedor' class='col-md-3  control-label'>Proveedor:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='proveedor' name='proveedor' validar='requiere'>
	</div>
</div>"
htmlProveedor += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'


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
	numRows:0
	numItems:0
	itemsInCart:[]
	objAttribs:AuxObjAttribs#for order.
	# upOrCreIdexesRows:[]
	html: '<table class="table table-striped table-bordered table-hover" style="display:none;" id="carrito-compra">
						<thead>
							<tr>
								<th>Serie(s)</th>
								<th>Codigo</th>
								<th>Descripcion</th>
								<th>Costo</th>
								<th>Cantidad</th>
								<th>Utilidad</th>
								<th>Garantia</th>
								<th>Subtotal</th>
								<th>Opciones</th>
							</tr>
						</thead><tbody></tbody><tfoot><tr><td colspan="7">TOTAL</td><td colspan="2" id="tolal"></td></tr><tr><td colspan="9" style="text-align:center;"><button class="btn btn-danger">Cancelar</button> <button class="btn btn-success">Comprar</button></td></tr></tfoot></table>'
	
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
		modalProveedor = new Modal
			titulo:'Proveedor'
			tipo:'formulario'
			contenido: htmlProveedor
			despuesDeMostrar:(ModalJq)->
				# alert 'ok'
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					ModalJq.find('input:text:first').focus()		
				,500

			antesDeMostrar:(ModalJq)->
				ModalJq.find('div.modal-footer button:first').text 'ok' 
		
		new Validador
			formulario:modalProveedor.jq.find('form:first')
			procesarFormulario:(formJq)=>
				modalProveedor.cerrar =>
					proveedor = formJq.find('input:text').val()
					# comprasArr = @serialize formJq.find('input:text').val() 
					item.proveedor = proveedor for item in @itemsInCart

					io.emit('compras:shopp', {compras:@itemsInCart, userAction:globalUser})
					io.emit('compras:shopping', {userAction:globalUser})#for ventas.

	restar:->
		@itemsInCart = []
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
					@itemsInCart = []
					# @upOrCreIdexesRows = []
					@numRows = 0
					@numItems = 0
					numItemsJq.text @numItems
					@tBodyJq.html ''
					@jq.fadeOut 'fast', ->
						msgCarritoJq.fadeIn('fast')
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
						@totalJq.text @sumColumn 7
						@numItems = @sumColumn 4
						numItemsJq.text @numItems

				else
					new Alerta
						tipo:'error'
						titulo:'Error'
						texto: "debe escribir #{cantidad} serie(s)"
						posicion:'arriba-izquierda'
						
					
	addRow:(rowObj)->
		# {codigo:'XXDDGG', descripcio:'Una descripcion', ...}
		@numRows++
		@numItems += rowObj.cantidad*1
		numItemsJq.text @numItems
		htmlRow = '<tr>'
		htmlRow += "<td>#{rowObj[attr]}</td>" for attr in @objAttribs
		htmlRow += '<td><button type="button" class="btn btn-danger btn-circle" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info btn-circle" alt="editar"><i class="fa fa-pencil"></i></button></td>'
		htmlRow += '</tr>'
		$(htmlRow).appendTo @tBodyJq
		@totalJq.text @sumColumn 7
		if @numRows is 1
			msgCarritoJq.hide()
			@jq.show()
		
		delete rowObj.subtotal
		@itemsInCart.push rowObj

	delRow:(rowJq)->
		cantidad = rowJq.find('td:eq(4)').text()
		@numRows--
		@numItems -= cantidad*1
		numItemsJq.text @numItems
		rowJq.fadeOut 'medium', =>
			rowJq.remove()
			if @numRows is 0
				@jq.hide()
				msgCarritoJq.show()
				# $('<h2>Ningun Item</h2>').@jq.parent()

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
	# day = moment('2014-07-19T16:10:59.568Z')
	# console.log day.format("MM-DD-YYYY")

	# ESCUCHADORES.
	io.on 'compras:shopp', (data)->
		# and update table for all users.
		# for item, i in data.compras
		# 	indexRow = shoppingCart.upOrCreIdexesRows[i]
		# 	if indexRow is -1#create
		# 		tablaCompras.add(shoppingCart.itemsInCart[i])
		# 	else#update.
		# 		tablaCompras.row(indexRow).data(item)
		tablaCompras.ajax.reload()
		if data.userAction is globalUser
			shoppingCart.restar()
			new Alerta data.msg 

		# and update table for all users.
		# if itemElegido.codigo#no empty
		# 	tdElegido = $('td', tablaComprasJq.tBodyJq).filter(in) -> $(this).text() is itemElegido.codigo 
		# 	trElegido = tdElegido.parent() 


	tablaComprasJq = $('#productos-registrados')
	contTablaCompJq = tablaComprasJq.parent()
	tablaCompras = tablaComprasJq.DataTable
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

		"ajax": '/compras/prodReg',
		"columns": [
			{ "data": "docdata._id" }
			{ "data": "docdata.fecha" }
			{ "data": "docdata.serie" }
			{ "data": "docdata.codigo" }
			{ "data": "docdata.descripcion" }
			{ "data": "docdata.costo" }
			{ "data": "docdata.cantidad" }
			{ "data": "docdata.utilidad" }
			{ "data": "docdata.garantia" }
			{ "data": "docdata.proveedor" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": false, "createdCell":(td, cellData, rowData, row, col)-> $(td).text moment(cellData).format("DD-MM-YYYY H:mm:ss")}
			{ "visible": false, "targets": 2 }
			{ "targets": 3, "createdCell":(td, cellData, rowData, row, col)-> $(td).html("<a href='javascript:;'>#{cellData}</a>")}
			{ "targets": 4, "createdCell":(td, cellData, rowData, row, col)-> $(td).html("<a href='javascript:;'>#{cellData}</a>")}
			{ "visible": false, "targets": 5 }
			{ "visible": false, "targets": 6 }
			{ "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": false, "targets": 9 }
			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'desc'],
		# "ordering": false

	showHideMenujq = $('div.show-hide-colms')
	$(document).ajaxComplete (event, xhr, settings)->
		tablaComprasJq.css('width', '')
		showHideMenujq.show()
	
	#hide/show columns.
	$('ul.dropdown-cols input:checkbox').on 'click', (event)->
		column = tablaCompras.column( $(this).attr('data-column') );
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaComprasJq.css('width', '')

	#tabs
	btnsTabs = $('button.btns-tabs')
	ctnsTabs = $('div.tab-pane')
	btnsTabs.on 'click', (evt)->
		elJq = $(this);
		btnsTabs.removeClass('active')
		elJq.addClass('active')
		ctnsTabs.hide()
		$('div#'+elJq.attr('name')).show()

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
	cantidadJq = 	$("input#cantidad")
	valArray = {codigo:$('input#codigo'), descripcion:$('textarea#descripcion'), costo:$('input#costo'), utilidad:$('input#utilidad'), garantia:$('input#garantia')}
	titlePanelJq = $('span#title-panel')
	itemElegido = {}
	$('tbody', tablaComprasJq).on 'click', 'a',(evt) ->
		evt.preventDefault()
		showHideMenujq.hide()
		indexElegido = tablaCompras.row($(this).parents('tr')[0]).index()
		# shoppingCart.upOrCreIdexesRows.push indexElegido
		data =  tablaCompras.row(indexElegido).data()
		itemElegido = data.docdata
		console.log data
		contTablaCompJq.fadeOut 'fast', ->
			titlePanelJq.html('<strong>(Agregue al carrito)</strong>')
			contTablaCompJq.next().fadeIn 'fast', ->
				jq.val data.docdata[prop] for prop, jq of valArray #when prop isnt 'costo'
				#valArray.costo.val data.costo
				valArray.costo.select()
					
	#btn search.
	inputSearchJq = $('input.input-sm', contTablaCompJq)
	formCompraJq = $('form#nueva-compra')
	imputsFormCompraJq = $('input:text, textarea', formCompraJq)
	btnSearchJq = $('button#btn-search-form').on 'click', (evt)->
		showHideMenujq.show()
		# imputsFormCompraJq.val ''
		validador.ocultarMensajes()
		cantidadJq.val ''
		contTablaCompJq.next().fadeOut 'fast', ->
			if inputSearchJq.val() isnt ''
				inputSearchJq.val ''
				inputSearchJq.trigger 'keyup'
			titlePanelJq.html('Productos Registrados <strong>(Elija Uno)</strong> / o uno <a href="javascript:;">Nuevo</a>')
			contTablaCompJq.fadeIn 'fast', ->
				inputSearchJq.focus()
	#new shopp
	$(titlePanelJq).on 'click', 'a', (e)->
		contTablaCompJq.fadeOut 'fast', ->
			titlePanelJq.html('<strong>(Agregue al carrito)</strong>')
			btnClearJq.trigger 'click'
			contTablaCompJq.next().fadeIn 'fast', ->
				valArray.codigo.focus()
		
	#btn clear.
	btnClearJq = $('button#btn-clear-form').on 'click', (evt)->
		imputsFormCompraJq.val ''
		validador.ocultarMensajes()
		itemElegido = {}
		valArray.codigo.focus()
	# serialize form
	serializeForm = (formJq)->
		objResult = {}
		$('input:text, textarea', formJq).each (k)->
			elJq = $(this)
			objResult[elJq.attr('id')] = elJq.val()	
		objResult

	# FORM NUEVA COMPRA SUBMIT
	procAddToCard = (series = false)->
		rowObj = serializeForm formCompraJq
		rowObj.subtotal = rowObj.cantidad * rowObj.costo
		if series
			rowObj.series = series#'ACC-11, XX-34, etc'
		else
			rowObj.series = '----------'	
		console.log rowObj
		shoppingCart.addRow rowObj	
		btnSearchJq.trigger 'click'
		new Alerta
			tipo:'info'
			titulo:'Item(s) Agregado'
			texto: "#{rowObj.cantidad} item(s) agregados al carrito"
			posicion:'arriba-izquierda'

		# alert itemElegido.codigo

	procSeries = ->
		# arrayProductos[codigoJq.val()] = true
		cantidad = cantidadJq.val()*1
		htmlSeries = '<form class="form-horizontal">'
		for i in [0...cantidad]
			htmlSeries += "
			<div class='form-group'>
				<label for='serie#{i+1}' class='col-md-3  control-label'>Serie#{i+1}:</label>
				<div class='col-md-5'>
					<input type='text' class='form-control upper' id='serie#{i+1}' name='serie#{i+1}' placeholder='Serie del producto' validar='requiere'>
				</div>
			</div>"
		htmlSeries += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'
		modalSeries = new Modal
			titulo:'Series'
			tipo:'formulario'
			contenido: htmlSeries
			despuesDeMostrar:(ModalJq)->
				# alert 'ok'
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					ModalJq.find('input:text:first').focus()		
				,500
			antesDeMostrar:(ModalJq)->
				ModalJq.find('div.modal-footer button:first').text 'ok' 
		
		new Validador
			formulario:modalSeries.jq.find('form:first')
			procesarFormulario:(formSeriesJq)=>
				modalSeries.cerrar ->
					series = ''
					formSeriesJq.find('input:text:not(:last)').each (k)->
						series += "#{$(this).val()}, "
					series += formSeriesJq.find('input:text:last').val()
					procAddToCard(series)
			
	validador = new Validador
		# validarTeclas:false#no validar al presionar teclas
		formulario:formCompraJq

		procesarFormulario:(formJq)->
			# alert arrayProductos[codigoJq.val()].serie
			prod = itemElegido
			unless prod.serie#es nuevo.
				# shoppingCart.upOrCreIdexesRows.push -1
				modalConfirm = new Modal
					titulo:'Producto Nuevo'
					tipo:'confirmacion'
					contenido:"<p>! El Producto con codigo <strong>#{valArray.codigo.val()}</strong> es un nuevo producto</p><br> <p>Posee serie?</p>"
					accionSi: ->
						modalConfirm.cerrar ->
							procSeries()
					antesDeMostrar:(jqModal)->
						btnsi = jqModal.find('button.btn-danger').text('SI')
						jqModal.find('button:last').text('NO').click (e)->
							procAddToCard()
						setTimeout ->
							btnsi.focus()		
						,500
					despuesDeCerrar: (jqModal)->
			else if prod.serie isnt '----------'
				procSeries()
			else
				procAddToCard()

	# SHOPPING CART.

	shoppingCart = new ShoppingCart()

	shoppingCart.addTo $('div.table-responsive:eq(1)')#ok
	# shoppingCart.addRow {series:'DDS-124', codigo:'XXX', descripcion:'Descripcion de XXX', costo:1456, cantidad:4, utilidad:178, garantia:'1 anio'}