darwin := `nix-build '<darwin>' -A system --no-out-link`
darwin-rebuild := darwin / "sw/bin/darwin-rebuild"

darwin-build:
	{{ darwin-rebuild }} build --flake ".#lisa"

darwin-switch:
	{{ darwin-rebuild }} switch --flake ".#lisa"