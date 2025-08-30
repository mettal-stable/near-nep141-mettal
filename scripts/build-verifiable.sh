cargo near build --verifiable-wasm
mkdir -p res
cp target/wasm32-unknown-unknown/release/*.json res/
