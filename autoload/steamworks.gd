## Steamworks
extends Node

signal host_created()


const APP_ID: int = 480

const LOBBY_TYPE: Steam.LobbyType = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS: int = 4

var peer: SteamMultiplayerPeer

func _ready() -> void:
	initialize_steam()
	
	## lobby signals
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_join_requested)
	
	## status signals
	Steam.relay_network_status.connect(_on_relay_network_status) ## I somehow don't get this callback when using Steam.initRelayNetworkAccess(), so don't ig?


#func _process(_delta: float) -> void:
	#Steam.run_callbacks() ## run every frame to get steam callbacks using signals

#region Steam Setup
func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(APP_ID, true)
	print("Did Steam initialize?: %s " % initialize_response)
	
	print("Steam ID: ", Steam.getSteamID())
	
	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
		# Show some kind of prompt so the game doesn't suddently stop working
		show_warning_prompt(initialize_response['verbal'])
		#get_tree().quit()

func show_warning_prompt(text: String = "") -> void:
	if !text:
		text = "All good haha"
	
	## Window Node version
	#get_window().set_embedding_subwindows(false)
	var warning_window: AcceptDialog = AcceptDialog.new()
	warning_window.popup_window = true
	warning_window.dialog_text = text
	get_tree().root.add_child.call_deferred(warning_window)
	warning_window.popup_centered.call_deferred()
	
	## OS version
	#OS.alert(text)
#endregion

#region Multiplayer stuff
func host_lobby() -> void:
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS) ## Will cause lobby_created and lobby_joined to emit

func _on_lobby_created(connect_result: int, _lobby_id: int) -> void:
	if connect_result == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(lobby) == Steam.getSteamID(): ## skip this if we made the lobby
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby))
		multiplayer.multiplayer_peer = peer
		
		## open game scene, shouldn't be here tho
		var new_scene: Node = SceneManager.WORLD_PACKED_SCENE.instantiate()
		var new_world_scene: World = new_scene as World
		new_world_scene.initialize(World.Gamemode.MULTIPLAYER_CLIENT)
		get_tree().change_scene_to_node(new_scene)

func _on_join_requested(lobby_id: int, _steam_id: int) -> void:
	Steam.joinLobby(lobby_id)
#endregion


func _on_relay_network_status(available: int, ping_measurement: int, available_config: int, available_relay: int, debug_message: String) -> void:
	
	print("relay_network_status:")
	print("available: ", available)
	print("ping_measurement: ", ping_measurement)
	print("available_config: ", available_config)
	print("available_relay: ", available_relay)
	print("debug: ", debug_message)
	
