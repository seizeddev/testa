# Homebrew formula for Testa. Builds from source, so no notarized binary is
# needed. Install directly (no tap required):
#   brew install https://raw.githubusercontent.com/seizeddev/testa/main/Formula/testa.rb
# Bump `url`/`sha256` for each tagged release.
class Testa < Formula
  desc "Autonomous iOS Simulator E2E driver for AI agents"
  homepage "https://github.com/seizeddev/testa"
  url "https://github.com/seizeddev/testa/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "0fcc71fa4c56d23e4e85f6fdc4a5f1c90372dfe7872b19fe6deb68c44e5171b6"
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
