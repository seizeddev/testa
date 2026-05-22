# Homebrew formula for Testa. Builds from source, so no notarized binary is
# needed. Install directly (no tap required):
#   brew install https://raw.githubusercontent.com/seizeddev/testa/main/Formula/testa.rb
# Bump `url`/`sha256` for each tagged release.
class Testa < Formula
  desc "Autonomous iOS Simulator E2E driver for AI agents"
  homepage "https://github.com/seizeddev/testa"
  url "https://github.com/seizeddev/testa/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "bc71d6cab7aa93678985abb3dd94945502fafb536c62de842fb4f5a24d3de845"
  license "MIT"
  head "https://github.com/seizeddev/testa.git", branch: "main"

  depends_on xcode: ["26.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/testa"
    (pkgshare/"skills/testa").install "skills/testa/SKILL.md"
  end

  def caveats
    <<~EOS
      Install the Claude Code skill and register the MCP server:
        mkdir -p ~/.claude/skills/testa
        cp #{opt_pkgshare}/skills/testa/SKILL.md ~/.claude/skills/testa/
        claude mcp add testa -- testa mcp

      Boot a simulator, then:  testa info && testa ui
    EOS
  end

  test do
    assert_match "testa", shell_output("#{bin}/testa help")
  end
end
