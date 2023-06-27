import net.http
import encoding.base64
import os
import crypto.md5
import szip
import json


struct Mainfest {
	name string
	exec string
	main string
}


fn main() {
	write()
	run()
}

fn run() {
	os.chdir('package') or { return }
	raw_json := os.read_file('manifest.json') or { return }
	manifest := json.decode(Mainfest, raw_json) or { return }
	if manifest.exec == 'shell' {
		os.system(manifest.main.replace('{{ ROOT_DIR }}', os.abs_path('.')))
	}
}

fn write() {
	data, checksum := request()
	if checksum == md5.hexhash(data) {
		os.create('package.zip') or {
			return
		}
		os.write_file_array('package.zip', base64.decode(data)) or {
			return
		}
		if !os.exists('package') {
			os.mkdir('package') or { return }
		}
		szip.extract_zip_to_dir('package.zip', 'package') or {
			return
		}
	} else {
		request()
	}
}

fn request() (string, string) {
	data := http.get_text('http://localhost:8080/package.zip')
	checksum := http.get_text('http://localhost:8080/checksum')
	return data, checksum
}