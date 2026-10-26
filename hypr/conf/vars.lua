return {
	qs = "qs -p ~/.config/quickshell/phoenix/",
	terminal = "kitty",
	browser = "helium-browser",
	external_keyboard = os.getenv("EXTERNAL_KEYBOARD"),
	touchpad = os.getenv("TOUCHPAD_DEVICE"),
	touchpad_mouse = os.getenv("TOUCHPAD_MOUSE"),
	touch_screen = os.getenv("TOUCH_SCREEN"),
	audio_monitor = os.getenv("AUDIO_MONITOR"),
}
