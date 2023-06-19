class FermyonSpin < Formula
  desc "Open-source tool for building and running serverless WebAssembly applications"
  homepage "https://spin.fermyon.dev/"
  url "https://github.com/fermyon/spin.git",
    tag:      "v1.3.0",
    revision: "9fb8256d1380a046414b22bf2c17d1543f5029e4"
  license "Apache-2.0" => { with: "LLVM-exception" }

  depends_on "rust" => [:build, :test]
  depends_on "rustup-init" => [:build, :test]

  on_linux do
    depends_on "pkg-config" => :build
  end

  def install
    system "#{Formula["rustup-init"].bin}/rustup-init", "-qy", "--no-modify-path"
    ENV.prepend_path "PATH", HOMEBREW_CACHE/"cargo_cache/bin"
    system "rustup", "target", "add", "wasm32-wasi", "wasm32-unknown-unknown"
    system "cargo", "install", *std_cargo_args

    # Install default templates and plugins for language tooling and deploying apps to the cloud.
    # Templates and plugins are installed into `pkgetc/"templates"` and `pkgetc/"plugins"`.
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin-python-sdk", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin-js-sdk", "--upgrade"
    system "#{bin}/spin", "plugins", "update"
    system "#{bin}/spin", "plugins", "install", "js2wasm", "--yes"
    system "#{bin}/spin", "plugins", "install", "py2wasm", "--yes"
    system "#{bin}/spin", "plugins", "install", "cloud", "--yes"
    # Set permissions for local plugins repository
    chmod 0755, spin_datadir/"plugins/.spin-plugins"
  end

  def spin_datadir
    pkgetc
  end

  test do
    system "#{Formula["rustup-init"].bin}/rustup-init", "-qy", "--no-modify-path"
    ENV.prepend_path "PATH", HOMEBREW_CACHE/"cargo_cache/bin"
    system "rustup", "target", "add", "wasm32-wasi", "wasm32-unknown-unknown"
    system bin/"spin", "new", "http-rust", "test-app", "--accept-defaults"
    system bin/"spin", "build", "--from", testpath/"test-app/spin.toml"
    assert_predicate testpath/"test-app/target/wasm32-wasi/release/test_app.wasm", :exist?
  end
end
