import vweb
import crypto.md5
import os
import encoding.base64

struct App {
	vweb.Context
}

fn main() {
	vweb.run(&App{}, 8080)
}

["/package.zip"]
fn (mut app App) pkg() vweb.Result {
	bytes := os.read_bytes('package.zip') or {
		panic(err)
	}
	return app.text(base64.encode(bytes))
}

["/checksum"]
fn (mut app App) check() vweb.Result {
	bytes := os.read_bytes('package.zip') or {
		panic(err)
	}
	return app.text(md5.hexhash(base64.encode(bytes)))
}