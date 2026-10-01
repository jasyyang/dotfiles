alias goodmorning="rise-and-shine.sh" # stored locally in ~/.local/bin

# Claude Code on personal claude.ai auth instead of the LiteLLM proxy. The proxy
# config lives in ~/.claude/settings.json's env block, which Claude applies on
# top of the shell env, so this needs its own config dir (and its own login).
function claude-personal() {
    local dir="$HOME/.claude-personal"
    mkdir -p "$dir"
    [[ -e "$dir/CLAUDE.md" ]] || ln -s "$HOME/.claude/CLAUDE.md" "$dir/CLAUDE.md"
    (
        unset -m 'ANTHROPIC_*'
        export CLAUDE_CONFIG_DIR="$dir"
        # Zscaler intercepts TLS to api.anthropic.com too
        export NODE_EXTRA_CA_CERTS="$HOME/code/zentreefish/projects/infra/container-images/zscaler-root-certs/cert.crt"
        command claude "$@"
    )
}
alias claudep='claude-personal'
