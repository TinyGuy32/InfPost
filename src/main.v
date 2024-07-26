module main

import vweb
import os

struct App {
	vweb.Context
}

const err_str = 'Avalible actions:\n  --serve [port]\n  --add [message]'
const content_file_path = './posts'

fn main() {
	if os.args.len != 3 {
		eprintln(err_str)
		exit(1)
	}
	
	action := os.args[1]

	if action == '--serve' {
		port := os.args[2].i32()

		app := App {}
		vweb.run_at(app, vweb.RunParams{host:'0.0.0.0', port: port, family: .ip})!
	} else if action == '--add' {
		message := os.args[2]
		mut file := os.open_append(content_file_path)!
		file.writeln(message)!
		file.close()
	}
}

fn (mut app App) index() vweb.Result {
	mut buffer := []u8{len: 2048}
	mut file := os.open(content_file_path) or { return app.server_error(500) }

	defer{
		file.close()
	}

	len := file.read(mut buffer) or { return app.server_error(500) }
	text_data := buffer[0..len].bytestr()
	return app.text(text_data)	
}
