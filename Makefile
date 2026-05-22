.PHONY: build release install test showcase e2e clean stop

build:
	swift build

release:
	swift build -c release

test:
	swift test

install:
	./install.sh

# Build + launch the native SwiftUI showcase on the booted simulator.
showcase:
	./examples/native/build.sh

# Run the end-to-end gesture regression suite against the native showcase.
e2e: build
	chmod +x examples/native/e2e.sh
	./examples/native/e2e.sh

stop:
	-./.build/debug/testa stop

clean:
	swift package clean
	rm -rf examples/native/build
