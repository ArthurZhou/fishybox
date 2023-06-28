import net.http
import encoding.base64
import os
import crypto.md5
import szip
import json
import time


struct Manifest {
	name string
	exec string
	main string
}


fn main() {
	address := "http://localhost:8080"
	mut last := ""
	for {
		last = write(address, last)
		run()
		time.sleep(1800000000000)
	}
}

fn run() {
	os.chdir('package') or { return }
	raw_json := os.read_file('manifest.json') or { return }
	manifest := json.decode(Manifest, raw_json) or { return }
	if manifest.exec == 'shell' {
		os.system(manifest.main.replace('{{ ROOT_DIR }}', os.abs_path('.')))
	}
}

fn write(address string, last string) string {
	mut data := ""
	mut checksum := ""

	checksum = http.get_text(os.join_path(address, 'checksum'))
	if checksum != last {
		data = http.get_text(os.join_path(address, 'package.zip'))
		if checksum == md5.hexhash(data) {
			os.create('package.zip') or {
				return ""
			}
			os.write_file_array('package.zip', base64.decode(data)) or {
				return ""
			}
			if !os.exists('package') {
				os.mkdir('package') or { return "" }
			}
			szip.extract_zip_to_dir('package.zip', 'package') or {
				return ""
			}
		} else {
			data = http.get_text('http://localhost:8080/package.zip')
			checksum = http.get_text('http://localhost:8080/checksum')
		}
	}
	return checksum
}