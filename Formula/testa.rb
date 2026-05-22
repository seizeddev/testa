# Homebrew formula for Testa. Builds from source so no notarized binary is
# required. Put this in a tap repo (e.g. homebrew-testa) and:
#   brew tap <you>/testa && brew install testa
#
# Update `url`/`sha256` to a tagged release tarball before publishing.
class Testa < Formula
  desc "Autonomous iOS Simulator E2E driver for AI agents"
  homepage "https://github.com/YOURNAME/testa"
  url "https://github.com/YOURNAME/testa/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/YOURNAME/testa.git", branch: "main"

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
