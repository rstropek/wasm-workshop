type exportType = {
    is_palindrome: (ptr: number, len: number) => number,
    memory: WebAssembly.Memory
}

(() => {
    const check = document.getElementById("check") as HTMLButtonElement;
    const word = document.getElementById("word") as HTMLInputElement;
    const resultHeader = document.getElementById("result") as HTMLHeadElement;

    check.addEventListener("click", async () => {
        const wasm = await fetch("demo.wasm");
        const wasmModule = await WebAssembly.instantiate(await wasm.arrayBuffer());

        const exports: exportType = wasmModule.instance.exports as any;
        const bytes = new Uint8Array(exports.memory.buffer, 0, 1024);
        new TextEncoder().encodeInto(word.value, bytes);
        const result = exports.is_palindrome(0, word.value.length);
        
        if (result) {
            resultHeader.innerText = "Yes, it is a palindrome";
        } else {
            resultHeader.innerText = "Sorry, no palindrome";
        }
    });
})();
