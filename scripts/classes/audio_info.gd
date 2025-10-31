extends Resource
class_name AudioInfo

@export var sound_name : String
@export var audio_file : AudioStream

enum AudioType { MUSIC, SFX }
@export var type : AudioType = AudioType.SFX

@export_group("ingame music info")
@export var song_name : String = "Song Name"
@export var artist_name : String = "Artist Name"
