env: reqs

reqs: requirements.txt
	nix run -f https://github.com/nix-community/pypi2nix/archive/master.tar.gz --command pypi2nix -r requirements.txt

.PHONY: env reqs
