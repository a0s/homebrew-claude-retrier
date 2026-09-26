# homebrew-agent-retrier

Homebrew tap for [agent-retrier](https://github.com/a0s/agent-retrier) — keep a
Claude Code or codex session going after a usage limit, on a pty, without tmux.

```sh
brew install a0s/agent-retrier/agent-retrier
```

Then run your session through it instead of calling claude directly:

```sh
agent-retrier                                 # plain `claude`
agent-retrier --cmd claude-work               # your own binary, alias or function
agent-retrier --cmd 'claude --model opus'     # a whole command line
codex-retrier                                 # codex, installed alongside
```

Latest from `main` instead of the released tag:

```sh
brew install --HEAD a0s/agent-retrier/agent-retrier
```
