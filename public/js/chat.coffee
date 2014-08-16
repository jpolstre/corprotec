class Chat			#array
	constructor: (@usersIn, inChat) ->
		@html = "<li>
			Conectados: <strong id='conectados'>#{@usersIn}</strong>
		</li>
		<li class='divider'></li>"

		for	comment in inChat
			@html = "<li class='dropdown'>
				<a class='dropdown-toggle' data-toggle='dropdown' href='#'>
					<span class='top-label label label-warning'>#{@usersIn}</span>  <i class='fa fa-bell fa-3x'></i>
				</a>
				<!-- dropdown alerts-->
				<ul class='dropdown-menu dropdown-alerts'>
					<li>
						<a href='#'>
							<div>
								<i class='fa fa-comment fa-fw'></i>#{comment.user} dice:
								<span class='pull-right text-muted small'>4 minutes ago</span>
								<p>#{comment.txt}</p>
							</div>
						</a>
					</li>
					<li class='divider'></li>
				</ul>
				<!-- end dropdown-alerts -->
			</li>"
		@html = "<li>
			<form class='form-horizontal'>
				<input type='text'  class='form-control' name='texto'>
			</form>
		</li>"
	addTo:(jqEl)->
		@jq = $(@html).appendTo jqEl 
		@conectadosJq = @jq.find('strong#conectados')
	
	updateUsersIn:(usersObj)->
		users = []
		users.push userObj.name for userObj in usersObj
		@conectadosJq.text users



$(window).on 'load', ->
	inChat = new Chat [], []
	inChat.addTo $('#mi-chat')

	io.emit('users:userIn', {userAction:globalUser})

	io.on 'users:userIn', (data)->
		inChat.updateUsersIn data.usersIn
		# console.log  data.usersIn
	
	$(window).on 'click', ->
		sw = 1
	
	`$(window).on('beforeunload', function(e){
			if(sw === 0){
				console.log(e);
			}
			sw = 0
			io.emit('users:userOut', {
				userAction: globalUser
			});
			return 'ooo'
		})`

