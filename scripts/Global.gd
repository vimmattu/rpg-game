extends Node


func is_server() -> bool:
	return (
		"--server" in OS.get_cmdline_args() or
		OS.has_feature("Server")
	)

