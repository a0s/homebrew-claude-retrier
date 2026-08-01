# homebrew-claude-retrier

Homebrew tap for [claude-retrier](https://github.com/a0s/claude-retrier) — auto-resume
Claude Code after a usage limit, on a pty, without tmux.

```sh
brew install a0s/claude-retrier/claude-retrier
```

Then run your session through it instead of calling claude directly:

```sh
claude-retrier                                 # plain `claude`
claude-retrier --cr-cmd claude-work            # your own binary, alias or function
claude-retrier --cr-cmd 'claude --model opus'  # a whole command line
```

Latest from `main` instead of the released tag:

```sh
brew install --HEAD a0s/claude-retrier/claude-retrier
```
