# homebrew-agent-retrier

Homebrew tap for [agent-retrier](https://github.com/a0s/agent-retrier) — keep a
Claude Code or codex session going after a usage limit, on a pty, without tmux.

```sh
brew install a0s/agent-retrier/agent-retrier
```

Then run your session through it instead of calling claude directly:

```sh
agent-retrier-claude                          # instead of: claude
agent-retrier-codex                           # instead of: codex
agent-retrier --claude / --codex              # the same, through a flag
agent-retrier-claude --cmd claude-work        # your own binary, alias or function
agent-retrier-claude --cmd 'claude --model opus'  # a whole command line
```

Latest from `main` instead of the released tag:

```sh
brew install --HEAD a0s/agent-retrier/agent-retrier
```
