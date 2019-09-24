env: reqs

reqs: requirements.txt
	nix run -f /home/matt/src/pypi2nix --command pypi2nix -r requirements.txt

.PHONY: env reqs
