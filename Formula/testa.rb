# Homebrew formula for Testa. Builds from source, so no notarized binary is
# needed. Install directly (no tap required):
#   brew install https://raw.githubusercontent.com/seizeddev/testa/main/Formula/testa.rb
# Bump `url`/`sha256` for each tagged release.
class Testa < Formula
  desc "Autonomous iOS Simulator E2E driver for AI agents"
  homepage "https://github.com/seizeddev/testa"
  url "https://github.com/seizeddev/testa/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "e5dfb46541eb4b8abaddeea1fa7244268151fb909022fc465b925020dda22907"
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
      Finish setup (installs the Claude Code skill + registers the MCP server):
        testa setup

      Then boot a simulator, and:  testa info && testa ui
    EOS
  end

  test do
    assert_match "testa", shell_output("#{bin}/testa help")
  end
end
