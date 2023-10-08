# Docker Image for WASM Workshop

## Image Content

This is a Docker image for exercises in a WASM workshop. It puts together the following tools:

| Tool                                                                     | Notes                                     |
| ------------------------------------------------------------------------ | ----------------------------------------- |
| [Build Essentials](https://packages.ubuntu.com/focal/build-essential)    | C Compiler, C Library, etc.               |
| _wget_, _curl_, _vim_                                                    | Just some useful tools                    |
| [WebAssembly Binary Toolkit (WABT)](https://github.com/WebAssembly/wabt) | Contains useful tools like wat2wasm       |
| [Wasmtime](https://wasmtime.dev/)                                        | A runtime for WebAssembly & WASI          |
| [Rust](https://www.rust-lang.org/)                                       | Rust tools for Rust-related Wasm examples |
| [Fermyon Spin](https://www.fermyon.com/spin)                             | Platform for serverless Wasm apps         |
| [WASI SDK](https://github.com/WebAssembly/wasi-sdk)                      | WASI-enabled WebAssembly C/C++ toolchain  |
| [.NET](https://dot.net)                                                  | .NET SDK for building _Blazor_ apps       |
| [Just](https://github.com/casey/just)                                    | Useful command runner                     |

Note that for Rust, the _wasm32-wasi_ target and [_wasm-pack_](https://rustwasm.github.io/wasm-pack/) are also installed.

Note that for .NET, the [_wasm-tools_ workload](https://learn.microsoft.com/en-us/aspnet/core/blazor/tooling?view=aspnetcore-7.0&pivots=linux-macos#net-webassembly-build-tools) is also installed.

Don't forget that there are [online alternatives to running WABT locally](https://webassembly.github.io/wabt/demo/)!

**NOTE:** See the [GitHub Repository](https://github.com/rstropek/wasm-workshop/) for lots of sample code to be used in the workshop.

## How to Use

- Start the container using Docker or a compatible container runtime: `docker run -it --rm -p 8080:8080 rstropek/wasm-workshop`
- If you don't have it, install [Visual Studio Code](https://code.visualstudio.com) with the following extensions:
  - [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
  - [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
  - [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack)
  - [C#](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
  - [Rust Analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)
  - [crates](https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates)
  - [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- Attach VSCode to the running container using the _Docker_ extension.

  ![Attach VSCode to container](https://github.com/rstropek/wasm-workshop/blob/main/attach.png?raw=true)

## Arguments

The Docker image accepts the following [arguments](https://docs.docker.com/engine/reference/builder/#arg):

| Argument         | Default Value  |                        |
| ---------------- | -------------- | ---------------------- |
| `base_image`     | `ubuntu:jammy` | The base image         |
| `wasi_sdk`       | `20`           | WASI SDK version       |
| `dotnet_repo`    | `22.04`        | Used .NET repository   |
| `dotnet_version` | `7.0`          | Installed .NET version |

Read more about .NET repository version [here](https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#register-the-microsoft-package-repository).

## Exercises

### Hello World Wasm

#### With C

```c
#include <stdio.h>

int main() {
    printf("Hello World\n");
    return 0;
}
```

Compile and run:

```bash
$CCWASM hello.c -o hello.wasm
wasmtime hello.wasm
```

#### With Rust

* `cargo new hello-wasm`
* Look at _src/main.rs_
* Compile and run:

  ```bash
  cargo build --target wasm32-wasi
  wasmtime target/wasm32-wasi/debug/hello-wasm.wasm
  ```

#### Exercise

Goals: Make sure that you have the necessary tools (given if you use the Docker image), get familiar with compiling code to Wasm and running it outside of the browser with Wasmtime.

* Choose C or Rust
* Implement a program that prints all Fibonacci numbers up to 1000
* Compile it to Wasm
* Run it with Wasmtime

### Introduction to Wasm with WAT

#### Hello World (Online)

![wat2wasm online](https://github.com/rstropek/wasm-workshop/blob/main/wat2wasm-online.png?raw=true)

#### Fibonacci

Try this code in the [online WAT editor](https://webassembly.github.io/wabt/demo/wat2wasm/index.html).

```wasm
(module
  ;; The memory section declares a linear memory instance and initializes it with a given contents.
  ;; Memory is array-like and can be accessed with loads and stores.
  ;; Here, we allocate 1 page of memory, which is 64KiB.
  (memory 1) 

  ;; The export section makes WebAssembly functions and memory available for calling from JavaScript.
  ;; We're exporting the memory we defined above so we can manipulate it or read from it in JS.
  (export "memory" (memory 0))

  ;; The func section declares a list of functions in the module.
  (func $fibonacci 
    ;; Declaring the result type of the function.
    ;; Our fibonacci function returns an i32 (32-bit integer) with the number
    ;; of elements written to memory (address 0).
    (result i32) 

    ;; Defining local variables which will be used in the function.
    ;; The local.get and local.set instructions allow for manipulating them.
    (local $i i32) ;; will hold a fibonacci number
    (local $j i32) ;; will hold the subsequent fibonacci number
    (local $k i32) ;; will be used as a pointer to memory where to store the numbers
    (local $limit i32) ;; will define our upper bound for fibonacci calculation

    ;; Initializing our local variables.
    (local.set $i (i32.const 0))
    (local.set $j (i32.const 1))
    (local.set $k (i32.const 0)) 
    (local.set $limit (i32.const 100)) 

    ;; Storing the first two Fibonacci numbers (0 and 1) in memory.
    (i32.store (local.get $k) (local.get $i))
    ;; Update $k to point to the next memory cell.
    (local.set $k (i32.add (local.get $k) (i32.const 4))) 
    (i32.store (local.get $k) (local.get $j))
    (local.set $k (i32.add (local.get $k) (i32.const 4))) 

    ;; Loop that calculates Fibonacci numbers and stores them in memory.
    (loop $loop1
      ;; Calculate the next Fibonacci number and store it in $i.
      (local.set $i (i32.add (local.get $i) (local.get $j)))

      ;; Check if the new Fibonacci number is less than or equal to our limit.
      (if (i32.le_s (local.get $i) (local.get $limit))
        (then
          ;; If yes, store it in memory.
          (i32.store (local.get $k) (local.get $i)) 
          ;; Update $k to point to the next memory cell.
          (local.set $k (i32.add (local.get $k) (i32.const 4))) 
          ;; Update $j to hold the last computed Fibonacci number.
          (local.set $j (local.get $i)) 
          ;; Continue loop from its beginning.
          (br $loop1) 
        )
      )
    )

    ;; At the end, we return how many Fibonacci numbers have been calculated 
    ;; and stored in memory by dividing the memory pointer by 4 
    ;; (since WebAssembly's i32 takes up 4 bytes of memory).
    (i32.div_u (local.get $k) (i32.const 4))
  )

  ;; Exporting the fibonacci function so it can be called from JavaScript.
  (export "fibonacci" (func $fibonacci)) 
)
```

```js
const wasmInstance = new WebAssembly.Instance(wasmModule, {});
const { fibonacci } = wasmInstance.exports;
let len = fibonacci();
console.log(`We got ${len} numbers and here they are:`);
const fibonacciNumbers = new Uint32Array(wasmInstance.exports.memory.buffer);

// Extract Fibonacci numbers from memory and print them
for(let i = 0; i < len; i++) {
  console.log(fibonacciNumbers[i]);
}
```

Exercises:

* Store the WAT code locally and compile it with _wat2wasm_: `wat2wasm fib.wat`
* Decompile the Wasm code with _wasm2wat_: `wasm2wat fib.wasm`
* Decompile the Wasm code with _wasm2c_: `wasm2c fib.wasm`
* Try running _wat-desugar_ on the WAT code: : `wat-desugar fib.wat`
* Try running _wasm-stats_: `wasm-stats fib.wasm`

#### Diving Deeper into WAT

[Introduction to WAT](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat) based on first day of _Advent of Code 2022_. See [justfile](https://github.com/rstropek/AdventOfCode2022/blob/main/Day01-wat/justfile) for commands. The sample contains hosts in

* [Rust](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-rs),
* [JavaScript](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-js) and
* [.NET](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-dotnet)

Compare [Mini Rust sample](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-mini-rs) with [Full Rust sample](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-full-rs).

### WASI

#### With C

Example see [here](https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md#from-c).

```bash
$CCWASM demo.c -o demo.wasm
ls -la demo.wasm
wasmtime demo.wasm
echo hello wasm from c > test.txt
wasmtime demo.wasm test.txt /tmp/test.txt
wasmtime --dir=. --dir=/tmp demo.wasm test.txt /tmp/test.txt
cat /tmp/test.txt
```

Read more about the above sample script [here](https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md#executing-in-wasmtime-runtime).

#### With Rust

Example see [here](https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md#from-rust).

```bash
cargo build --target wasm32-wasi
ls -la target/wasm32-wasi/debug/demo.wasm
cp target/wasm32-wasi/debug/demo.wasm .
wasmtime demo.wasm
echo hello wasm from Rust > test.txt
wasmtime demo.wasm test.txt /tmp/test.txt
wasmtime --dir=. --dir=/tmp demo.wasm test.txt /tmp/test.txt
cat /tmp/test.txt
```

Read more about the above sample script [here](https://github.com/bytecodealliance/wasmtime/blob/main/docs/WASI-tutorial.md#executing-in-wasmtime-runtime).

