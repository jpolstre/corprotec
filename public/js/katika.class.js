var Katika = (function() {
	var Alerta, Formulario, MensajeError, Modal, Validador;

	function Katika() {
		this.Alerta = Alerta;
		this.Validador = Validador;
		this.Modal = Modal;
		this.Formulario = Formulario;
	}

	Alerta = (function() {

		function Alerta(args) {
			var _ref, _ref1, _ref2, _ref3, _ref4;
			this.clase = (_ref = args.tipo) != null ? _ref : 'exito';
			this.titulo = (_ref1 = args.titulo) != null ? _ref1 : 'OK hecho';
			this.texto = (_ref2 = args.texto) != null ? _ref2 : 'evento realizado';
			this.posicion = (_ref3 = args.posicion) != null ? _ref3 : 'arriba-centro';
			this.tiempoDeVida = (_ref4 = args.tiempoDeVida) != null ? _ref4 : 4000;
			this.botonCerrar = true;
			switch (this.clase) {
				case 'exito':
					this.clase = 'alert-success';
					break;
				case 'error':
					this.clase = 'alert-danger';
					break;
				case 'alerta':
					this.clase = 'alert-warning';
					break;
				default:
					this.clase = 'alert-info';
			}
			this.generar();
		}

		Alerta.prototype.generar = function() {
			var botonCerrar, contenedor, mensaje;
			contenedor = $(".contenedor-mensaje-" + this.posicion);
			if (!contenedor.length) {
				contenedor = $("<div class='contenedor-mensaje-" + this.posicion + "'></div>").appendTo('body');
			}
			mensaje = $("<div class='alert alert-block " + this.clase + "'><h4>" + this.titulo + "</h4><p>" + this.texto + "</p></div>");
			if (this.botonCerrar) {
				botonCerrar = $("<button type='button' class='close' data-dismiss='alert'>x</button>").prependTo(mensaje);
				botonCerrar.bind('click', function(ev) {
					ev.preventDefault();
					return $(this).parent().fadeOut('medium', function() {
						return $(this).remove();
					});
				});
			}
			if (this.tiempoDeVida && this.tiempoDeVida > 0) {
				setTimeout(function() {
					return mensaje.fadeOut('medium', function() {
						return mensaje.remove();
					});
				}, this.tiempoDeVida);
			}
			contenedor.addClass(this.posicion);
			if (this.posicion.split('-'[0] === 'arriba')) {
				return mensaje.prependTo(contenedor).hide().fadeIn('slow');
			} else {
				return mensaje.appendTo(contenedor).hide().fadeIn('slow');
			}
		};

		return Alerta;

	})();

	MensajeError = (function() {

		function MensajeError(elementoJq, mensaje) {
			var html;
			this.elementoJq = elementoJq;
			if (mensaje == null) {
				mensaje = 'msg por defecto';
			}
			html = "<span class='help-inline' style='display:none;color: chocolate;cursor:pointer;'>*" + mensaje + "</span>";
			this.divControlJq = this.elementoJq.parent().parent();
			if (this.elementoJq.parent().attr('class') === 'input-group') {
				this.divControlJq = this.elementoJq.parent().parent().parent();
				this.mensajeJq = $(html).insertAfter(this.elementoJq.parent());
			} else {
				
				this.mensajeJq = $(html).insertAfter(this.elementoJq);
			}
			this.addEventoClick();
		}

		MensajeError.prototype.setValor = function(mensaje) {
			return this.mensajeJq.html(mensaje);
		};

		MensajeError.prototype.addEventoClick = function() {
			var _this = this;
			return this.mensajeJq.bind('click', function(e) {
				return _this.ocultarMensaje();
			});
		};

		MensajeError.prototype.mostrarMensaje = function() {
			this.divControlJq.addClass('has-error');
			return this.mensajeJq.show();
		};

		MensajeError.prototype.ocultarMensaje = function() {
			this.divControlJq.removeClass('has-error');
			return this.mensajeJq.fadeOut('fast');
		};

		return MensajeError;

	})();

	Validador = (function() {

		function Validador(parametros) {
			var mi_this, validarTeclas, _ref;
			this.formulario = parametros.formulario;
			this.procesarFormulario = parametros.procesarFormulario;
			this.validarTeclas = (_ref = parametros.validarTeclas) != null ? _ref : true;
			this.expRegEntero = /^(\+|\-)?\d+$/;
			this.expRegReal = /^[+-]?\d+([,.]\d+)?$/;
			this.expRegEmail = /^(.+\@.+\..+)$/;
			this.elementos = [];
			mi_this = this;
			this.inputs = this.formulario.find('[validar]').each(function(indice) {
				var elemento;
				elemento = new Object();
				elemento.jq = $(this);
				elemento.reglas = ($(this).attr('validar')).split(',');
				elemento.mensajeError = new MensajeError($(this), 'msg por defecto');
				return mi_this.elementos.push(elemento);
			});
			this.validarForm();
			if (this.validarTeclas) {
				this.validarInputs();
			}
		}

		Validador.prototype.reiniciar = function(){
			this.formulario.find('div.has-error').removeClass('has-error')
				this.formulario.find('span.help-inline').remove()
			this.elementos = [];
			mi_this = this;
			this.inputs = this.formulario.find('[validar]').each(function(indice) {
				var elemento;
				elemento = new Object();
				elemento.jq = $(this);
				elemento.reglas = ($(this).attr('validar')).split(',');
				elemento.mensajeError = new MensajeError($(this), 'msg por defecto');
				return mi_this.elementos.push(elemento);
			});
			this.validarForm();
			if (this.validarTeclas) {
				this.validarInputs();
			}
		};

		Validador.prototype.validarRegla = function(elem, regla) {
			var campoAcompara, mensajeError, respuesta, valor;
			valor = elem.jq.val();
			mensajeError = elem.mensajeError;
			respuesta = 0;
			switch (regla) {
				case 'requiere':
					if (valor === null || valor.length === 0 || /^\s+$/.test(valor)) {
						mensajeError.setValor('&nbspcampo&nbsprequerido');
						mensajeError.mostrarMensaje();
						respuesta = 1;
					}
					break;
				case 'especial':
					arrayChkElm = elem.jq.find('input:checkbox, input:radio');
					// alert(arrayChkElm[3]);
					for (var indx = 0 ; indx <= arrayChkElm.length; indx++){
						if ($(arrayChkElm[indx]).is(':checked')){
							return respuesta;
						}
					}
					mensajeError.setValor('&nbspcampo&nbsprequerido');
					mensajeError.mostrarMensaje();
					respuesta = 1;
 
					break;
				case 'email':
					if (!this.expRegEmail.test(valor)) {
						mensajeError.setValor('Escriba un email');
						mensajeError.mostrarMensaje();
						respuesta = 1;
					}
					break;
				case 'real':
					if (!this.expRegReal.test(valor)) {
						mensajeError.setValor('Escriba un numero real');
						mensajeError.mostrarMensaje();
						respuesta = 1;
					}
					break;
				case 'entero':
					if (!this.expRegEntero.test(valor)) {
						mensajeError.setValor('Escriba un numero entero');
						mensajeError.mostrarMensaje();
						respuesta = 1;
					}
					break;
				default:
					campoAcompara = regla.split('|')[1];
					if (valor !== this.formulario.find('#' + campoAcompara).val()) {
						mensajeError.setValor("Debe ser igual al campo " + campoAcompara + "...!");
						mensajeError.mostrarMensaje();
						respuesta = 1;
					}
			}
			return respuesta;
		};

		Validador.prototype.esValido = function() {
			var elemento, regla, respuesta, respuestaTotal, _i, _j, _len, _len1, _ref, _ref1;
			respuestaTotal = 0;
			_ref = this.elementos;
			for (_i = 0, _len = _ref.length; _i < _len; _i++) {
				elemento = _ref[_i];
				respuesta = 0;
				if (elemento.jq.is(':visible')) {
					_ref1 = elemento.reglas;
					for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
						regla = _ref1[_j];
						respuesta += this.validarRegla(elemento, regla);
					}
				}
				respuestaTotal += respuesta;
				if (!respuesta) {
					elemento.mensajeError.ocultarMensaje();
				}
			}
			return respuestaTotal;
		};
		

		Validador.prototype.validarForm = function() {
			var _this = this;
			return this.formulario.bind('submit', function(e) {
				e.preventDefault();
				if (!_this.esValido()) {//es valido.
					$.each(_this.elementos, function(i, elemento) {
						return elemento.jq.val($.trim(elemento.jq.val()));
					});
					if (_this.procesarFormulario) {
						return _this.procesarFormulario(_this.formulario);
					} else {
						return _this.formulario.unbind('submit').trigger('submit');
					}
				}
				// modificado para grupoAlfa.
				// new Alerta({
				//   tipo:'error',
				//   titulo:'Error',
				//   texto:'Llene todos los campos Requeridos.',
				//   tiempoDeVida:4000
				//   // posicion:'arriba-centro'
				// });
				//buscando el primer elemento con error y darle el foco.
			 
				var el;
				for (var i = 0; i < _this.elementos.length ;i++) {
					el = _this.elementos[i];
					if (el.mensajeError.mensajeJq.is(':visible')){
						el.jq.focus();
						break;
					}
				}

			});
		};

		Validador.prototype.validarInputs = function() {
			var this_;
			this_ = this;
			return this.inputs.bind('keyup change', function(e) {
				var elemento, indice, regla, res, _i, _len, _ref;
				if ($(this).is(':visible')) {
					indice = this_.inputs.index(this);
					elemento = this_.elementos[indice];
					res = 0;
					_ref = elemento.reglas;
					for (_i = 0, _len = _ref.length; _i < _len; _i++) {
						regla = _ref[_i];
						res += this_.validarRegla(elemento, regla);
					}
					if (!res) {
						return elemento.mensajeError.ocultarMensaje();
					}
				}
			});
		};

		Validador.prototype.ocultarMensajes = function() {
			return $.each(this.elementos, function(i, elemento) {
				elemento.mensajeError.divControlJq.removeClass('has-error');
				return elemento.mensajeError.mensajeJq.hide();
			});
		};

		Validador.prototype.noValidar = function(elementos) {
			var this_;
			this_ = this;
			this.noValidados = [];
			return elementos.each(function(index) {
				var elemento, i, id, _i, _len, _ref, _results;
				id = $(this).attr('id');
				_ref = this_.elementos;
				_results = [];
				for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
					elemento = _ref[i];
					if (id === elemento.jq.attr('id')) {
						elemento.mensajeError.mensajeJq.hide();
						this_.noValidados.push(elemento);
						this_.elementos.splice(i, 1);
						break;
					} else {
						_results.push(void 0);
					}
				}
				return _results;
			});
		};

		Validador.prototype.reValidar = function(elementos) {
			var this_;
			this_ = this;
			return elementos.each(function(index) {
				var elemento, i, id, _i, _len, _ref, _results;
				id = $(this).attr('id');
				_ref = this_.noValidados;
				_results = [];
				for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
					elemento = _ref[i];
					if (id === elemento.jq.attr('id')) {
						this_.elementos.push(elemento);
						break;
					} else {
						_results.push(void 0);
					}
				}
				return _results;
			});
		};

		Validador.prototype.validar = function(elementos) {


		};

		return Validador;

	})();

	Formulario = (function() {

		function Formulario(params) {
			var aClase, campo, campos, clase, opcion, rValidar, _i, _j, _len, _len1, _ref, _ref1, _ref2;
			campos = (_ref = params.campos) != null ? _ref : "<input type='text'>";
			clase = (_ref1 = params.clase) != null ? _ref1 : 'form-horizontal';
			this.html = "<form class='" + clase + "'>";
			for (_i = 0, _len = campos.length; _i < _len; _i++) {
				campo = campos[_i];
				rValidar = campo.reglasValidacion ? "validar = '" + (campo.reglasValidacion.join(',')) + "'" : '';
				aClase = campo.clase ? "class = '" + campo.clase + "'" : '';
				switch (campo.tipo) {
					case 'text':
						this.html += "<div class='control-group'><label class='control-label' for='" + campo.titulo + "'>" + campo.titulo + "</label><div class='controls'><input type='text' name='" + campo.id + "' id='" + campo.id + "' " + aClase + " " + rValidar + "></div></div>";
						break;
					case 'input-append':
						this.html += "<div class='control-group'><label class='control-label' for='" + campo.titulo + "'>" + campo.titulo + "</label><div class='controls'><div class='input-append'><input type='text' name='" + campo.id + "' id='" + campo.id + "' " + aClase + " " + rValidar + "><span class='add-on'>Und</span></div></div></div>";
						break;
					case 'textarea':
						this.html += "<div class='control-group'><label class='control-label' for='" + campo.titulo + "'>" + campo.titulo + "</label><div class='controls'><textarea name='" + campo.id + "' id='" + campo.id + "' " + aClase + " " + rValidar + " rows='3'></textarea></div></div>";
						break;
					case 'select':
						this.html += "<div class='control-group'><label class='control-label' for='" + campo.id + "'>" + campo.titulo + "</label><div class='controls'><select name='" + campo.id + "' id='" + campo.id + "' " + rValidar + "><option value=''></option>";
						_ref2 = campo.opciones;
						for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
							opcion = _ref2[_j];
							this.html += "<option>" + opcion + "</option>";
						}
						this.html += "</select></div> </div>";
						break;
					case 'hidden':
						this.html += "<input type='hidden' name='" + campo.id + "' id='" + campo.id + "'>";
						break;
					default:
						this.html += "<div class='control-group'><label class='control-label' for='" + campo.titulo + "'>" + campo.titulo + "</label><div class='controls'><input type='" + campo.tipo + "' name='" + campo.id + "' id='" + campo.id + "' " + aClase + " " + rValidar + "></div></div>";
				}
			}
			this.html += "<div class='control-group'><div class='controls'><button type='submit' class='btn btn-primary submit'>Guardar</button></div></div></form>";
		}

		Formulario.prototype.adicionarA = function(nodoJq) {
			return this.jq = $(this.html).appendTo(nodoJq);
		};

		return Formulario;

	})();

	Modal = (function() {

		function Modal(params) {
			var botonCerrar, botonGuardar, btnAceptar, btnSubmitJq, contenido, footerJq, html, id, this_, tipo, titulo, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
				_this = this;
			id = (_ref = params.id) != null ? _ref : 'katika_modal';
			$("#" + id).remove();
			titulo = (_ref1 = params.titulo) != null ? _ref1 : 'Katika Modal';
			tipo = (_ref2 = params.tipo) != null ? _ref2 : 'alerta';
			this.antesDeMostrar = (_ref3 = params.antesDeMostrar) != null ? _ref3 : function() {};
			this.despuesDeMostrar = (_ref4 = params.despuesDeMostrar) != null ? _ref4 : function() {};
			this.despuesDeCerrar = (_ref6 = params.despuesDeCerrar) != null ? _ref6 : function() {};
			contenido = (_ref5 = params.contenido) != null ? _ref5 : '<p>Sin contenido..!<p/>';
			html = "<div class='modal fade' id='" + id + "'><div class='modal-dialog'><div class='modal-content'><div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button><h3 class='modal-title'>" + titulo + "</h3></div><div class='modal-body'>" + contenido + "</div></div></div></div>";
			this.jq = $(html).appendTo('body').draggable();
			footerJq = $("<div class='modal-footer'></div>").appendTo(this.jq.find('div.modal-content'));
			switch (tipo) {
				case 'formulario':
					botonGuardar = "<button  type='button' class='btn btn-primary'>Guardar</button>";
					botonCerrar = "<button  type='button' class='btn btn-default'>Cancelar</button>";
					// btnSubmitJq = this.jq.find("button[type='submit']").hide();
					formJq = this.jq.find("form:first");
					$(botonGuardar).appendTo(footerJq).click(function(e) {
						e.preventDefault();
						return formJq.submit();
					});
					break;
				case 'alerta':
					botonCerrar = "<button class='btn btn-primary'>Aceptar</button>";
					// this.jq.addClass('alert-error');
					break;
				case 'confirmacion':
					btnAceptar = "<button type='button' class='btn btn-danger'>Aceptar</button>";
					botonCerrar = "<button type='button' class='btn btn-default'>Cancelar</button>";
					// this.jq.addClass('alert-error');
					$(btnAceptar).appendTo(footerJq).click(params.accionSi);
			}
			$(botonCerrar).appendTo(footerJq).click(function(e) {
				return _this.cerrar();
			});
			this.onClosed = function() {};
			
			this_ = this;
			this.jq.on('hidden.bs.modal', function() {
				$(this).remove();
				// $('html, body').css('overflow', 'visible');
				this_.despuesDeCerrar();
				return this_.onClosed();// Modificado.
			});
			this.jq.on('show.bs.modal', function() {
				return _this.despuesDeMostrar(_this.jq);
			});
			this.mostrar();
		}

		Modal.prototype.cerrar = function(accion) {
			if (accion == null) {
				accion = function() {};
			}
			this.onClosed = accion;
			return this.jq.modal('hide');
		};

		Modal.prototype.mostrar = function() {
			this.antesDeMostrar(this.jq);
			return this.jq.modal('show');
		};

		return Modal;

	})();
 return Katika;
})();
var kat = new Katika() 
	Alerta = kat.Alerta 
	Formulario = kat.Formulario
	MensajeError = kat.MensajeError
	Modal = kat.Modal
	Validador = kat.Validador
