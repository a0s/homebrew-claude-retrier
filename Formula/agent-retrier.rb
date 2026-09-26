class AgentRetrier < Formula
  desc "Keep a Claude Code or codex session going when it stops"
  homepage "https://github.com/a0s/agent-retrier"
  url "https://github.com/a0s/agent-retrier/archive/refs/tags/v3.0.1.tar.gz"
  sha256 "0419c73652a99601c51c9088d9696a94e6395d5082c65879bf0eb6c77bbf3479"
  license "MIT"
  head "https://github.com/a0s/agent-retrier.git", branch: "main"

  # The script degrades to plain claude when it cannot find an interpreter with
  # pty/zoneinfo, so a missing python3 costs the retry rather than the session —
  # but that is a silent loss of the whole feature, which is worth a dependency.
  depends_on "python@3.13"

  def install
    # Put Homebrew's python first in the search list. The default candidates find
    # the system python3 on macOS (Xcode CLT, may be absent) and whatever is on
    # PATH elsewhere; neither is the one this formula just guaranteed.
    inreplace "agent-retrier.sh",
              "CR_PYTHON_CANDIDATES:=python3:",
              "CR_PYTHON_CANDIDATES:=#{formula_opt_bin("python@3.13")}/python3.13:python3:"

    bin.install "agent-retrier.sh" => "agent-retrier"
    # The same file under one name per agent: it reads the name it was called by,
    # the same as `agent-retrier --claude` / `--codex`. Both are installed whether
    # or not codex is — without it, agent-retrier-codex says so and exits 127,
    # and installing codex later needs
    # nothing reinstalled.
    bin.install_symlink "agent-retrier" => "agent-retrier-claude"
    bin.install_symlink "agent-retrier" => "agent-retrier-codex"
  end

  def caveats
    <<~EOS
      Run your session through the wrapper instead of calling claude directly:

        agent-retrier-claude        (or: agent-retrier --claude)

      If your Claude is not plain `claude` — a claude-work binary, an alias in
      your ~/.zshrc, a shell function — name it and the wrapper will run it:

        agent-retrier-claude --cmd claude-work
        agent-retrier-claude --cmd 'claude --model opus'

      To make it the default, in your ~/.zshrc:

        alias claude='agent-retrier-claude --cmd claude-work'

      codex is wrapped the same way:

        agent-retrier-codex         (or: agent-retrier --codex)

      There it also answers a turn the server refused outright ("Selected model
      is at capacity"), which states no reset time and, on a session running
      agents, takes every one of them down with it.

      It can also restart a session before it fills its context window: fold the
      session into a file, verify the file, /clear, unfold. That one is off
      until you ask for it:

        CR_CONTEXT_RESTART=1 agent-retrier-claude
        CR_CONTEXT_RESTART=1 agent-retrier-codex

      On codex it also keeps codex's own compaction from getting there first.

      The log goes to ~/.agent-retrier/log; nothing else is written to $HOME.
    EOS
  end

  test do
    assert_match "agent-retrier #{version}", shell_output("#{bin}/agent-retrier --cr-version")

    # The embedded supervisor must be valid Python under the interpreter this
    # formula pinned — an inreplace typo would otherwise only show up in a real
    # session, at the moment a limit is hit.
    (testpath/"supervisor.py").write(shell_output("#{bin}/agent-retrier --cr-dump-python"))
    system formula_opt_bin("python@3.13")/"python3.13", "-c",
           "import py_compile,sys; py_compile.compile(sys.argv[1], doraise=True)",
           testpath/"supervisor.py"

    # A stand-in claude, named the way a user would name theirs: the wrapper has
    # to run it and pass the arguments through untouched.
    (testpath/"claude-work").write <<~SH
      #!/bin/sh
      echo "started with: $*"
    SH
    chmod 0755, testpath/"claude-work"
    out = shell_output("#{bin}/agent-retrier --cmd #{testpath}/claude-work -p hello")
    assert_match "started with: -p hello", out

    # agent-retrier-codex is the same file, and the name alone makes codex the
    # default; --codex does the same for the plain name.
    (testpath/"bin/codex").write <<~SH
      #!/bin/sh
      echo "codex started with: $*"
    SH
    chmod 0755, testpath/"bin/codex"
    out = shell_output("PATH=#{testpath}/bin:$PATH #{bin}/agent-retrier-codex exec hello")
    assert_match "codex started with: exec hello", out
    out = shell_output("PATH=#{testpath}/bin:$PATH #{bin}/agent-retrier --codex exec hello")
    assert_match "codex started with: exec hello", out
  end
end
