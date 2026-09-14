# homebrew-claude-retrier

Homebrew tap for [claude-retrier](https://github.com/a0s/claude-retrier) — keep a
Claude Code or codex session going after a usage limit, on a pty, without tmux.

```sh
brew install a0s/claude-retrier/claude-retrier
```

Then run your session through it instead of calling claude directly:

```sh
claude-retrier                                 # plain `claude`
claude-retrier --cmd claude-work               # your own binary, alias or function
claude-retrier --cmd 'claude --model opus'     # a whole command line
codex-retrier                                  # codex, installed alongside
```

Latest from `main` instead of the released tag:

```sh
brew install --HEAD a0s/claude-retrier/claude-retrier
```
