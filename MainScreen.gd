extends Control

func _ready():
	get_tree().connect("files_dropped", self, "Handle_dropped_files")

func Handle_dropped_files(files: PoolStringArray, _screen: int):
	for file in files:
		# Prevent non .png file to be used
		if !".png" in file:
			return
		
		# Create the receptor image and prepare it for osu
		var OriginalReceptor = Image.new()
		OriginalReceptor.load(file)
		OriginalReceptor.resize(OriginalReceptor.get_width(), $ColumnSize.value * 1.6)
		
		# Create final image and import the receptor in it
		var FinaleReceptor = Image.new()
		FinaleReceptor.create(OriginalReceptor.get_width(), 768, false, OriginalReceptor.get_format())
		var receptor = OriginalReceptor.get_rect(Rect2(0, 0, OriginalReceptor.get_width(), OriginalReceptor.get_height()))
		var ReceptorHeight = 768 - ($HitPosition.value * 1.6) if ($UpScroll.pressed == true) else ($HitPosition.value * 1.6) - receptor.get_height()
		FinaleReceptor.blit_rect(receptor, Rect2(0, 0, receptor.get_width(), receptor.get_height()), Vector2(0, ReceptorHeight))
		
		# Create LaneCover if bigger than 0
		if ($LaneCover.value != 0):
			var LaneCover = Image.new()
			LaneCover.create(OriginalReceptor.get_width(), $LaneCover.value, false, OriginalReceptor.get_format())
			LaneCover.fill($CoverColor.color)
			var LaneCoverHeight = 768 - LaneCover.get_height() if ($UpScroll.pressed == true) else 0
			FinaleReceptor.blit_rect(LaneCover, Rect2(0, 0, LaneCover.get_width(), LaneCover.get_height()), Vector2(0, LaneCoverHeight))
		
		# Create a texture using the image
		var texture = ImageTexture.new()
		texture.create_from_image(FinaleReceptor)
		
		# Use RegEx to get the filename and then save the OriginalReceptor using the name
		var regex = RegEx.new()
		regex.compile(escapeRegExp("[-a-zA-Z0-9@:%_\\+.~#?&//=]{2,256}\\.[a-z]{2,4}\\b(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)?"))
		var ReceptorName = regex.search(file)
		print(ReceptorName.get_string())
		FinaleReceptor.save_png("user://" + ReceptorName.get_string())
	OS.shell_open(OS.get_user_data_dir())

func escapeRegExp(string):
	# Automatically take care of escape sequence
	string = string.replace("/[.*+?^${}()|[\\]\\\\]/g", '\\$&')
	return string
