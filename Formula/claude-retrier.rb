class ClaudeRetrier < Formula
  desc "Resume Claude Code after a usage limit and restart it before it fills up"
  homepage "https://github.com/a0s/claude-retrier"
  url "https://github.com/a0s/claude-retrier/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "e85391826854e594b825710bcc8200dc51a85c2506df3e7edfa11f116e08fd29"
  license "MIT"
  head "https://github.com/a0s/claude-retrier.git", branch: "main"

  # The script degrades to plain claude when it cannot find an interpreter with
  # pty/zoneinfo, so a missing python3 costs the retry rather than the session —
  # but that is a silent loss of the whole feature, which is worth a dependency.
  depends_on "python@3.13"

  def install
    # Put Homebrew's python first in the search list. The default candidates find
    # the system python3 on macOS (Xcode CLT, may be absent) and whatever is on
    # PATH elsewhere; neither is the one this formula just guaranteed.
    inreplace "claude-retrier.sh",
              "CR_PYTHON_CANDIDATES:=python3:",
              "CR_PYTHON_CANDIDATES:=#{formula_opt_bin("python@3.13")}/python3.13:python3:"

    bin.install "claude-retrier.sh" => "claude-retrier"
  end

  def caveats
    <<~EOS
      Run your session through the wrapper instead of calling claude directly:

        claude-retrier

      If your Claude is not plain `claude` — a claude-work binary, an alias in
      your ~/.zshrc, a shell function — name it and the wrapper will run it:

        claude-retrier --cmd claude-work
        claude-retrier --cmd 'claude --model opus'

      To make it the default, in your ~/.zshrc:

        alias claude='claude-retrier --cmd claude-work'

      It can also restart a session before it fills its context window: fold the
      session into a file, verify the file, /clear, unfold. That one is off
      until you ask for it:

        CR_CONTEXT_PCT=51 claude-retrier

      The log goes to ~/.claude-retrier/log; nothing else is written to $HOME.
    EOS
  end

  test do
    assert_match "claude-retrier #{version}", shell_output("#{bin}/claude-retrier --cr-version")

    # The embedded supervisor must be valid Python under the interpreter this
    # formula pinned — an inreplace typo would otherwise only show up in a real
    # session, at the moment a limit is hit.
    (testpath/"supervisor.py").write(shell_output("#{bin}/claude-retrier --cr-dump-python"))
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
    out = shell_output("#{bin}/claude-retrier --cmd #{testpath}/claude-work -p hello")
    assert_match "started with: -p hello", out
  end
end
