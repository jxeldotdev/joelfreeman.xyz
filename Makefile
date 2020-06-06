_update-deps:
	git submodule update --init --recursive

_build: _update-deps
	cd blog && hugo --minify -v

_test:
	if [ ! -d blog/public ]; then echo "Public directory not found, did you run hugo to build the site?"; exit 1; fi
	htmlproofer blog/public --assume-extension --check-html --check-img-http --http-status-ignore 999 --enforce-https

_deploy:
	if [ ! -d blog/public ]; then echo "Public directory not found, did you run hugo to build the site?"; exit 1; fi
	cd blog && hugo deploy --dryRun

all: _build _test