version := DEFINE_A_VERSION

zip:
	@echo "Zipping Project with version: $(version)"
	git archive --worktree-attributes -o builds/KSHPortals_v$(version).zip main
