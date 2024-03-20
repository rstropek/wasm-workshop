![GitHub Action Badge](https://github.com/rstropek/wasm-workshop/actions/workflows/build.yml/badge.svg)
[![Docker Badge](https://img.shields.io/badge/Docker-rstropek%2Fwasm--workshop-blue)](https://hub.docker.com/r/rstropek/wasm-workshop)

# Docker Image for WASM Workshop

## Image Content

This is a Docker image for exercises in a WASM workshop. It puts together the following tools:

| Tool                                                                     | Notes                                                             |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| [Build Essentials](https://packages.ubuntu.com/focal/build-essential)    | C Compiler, C Library, etc.                                       |
| _wget_, _curl_, _vim_                                                    | Just some useful tools                                            |
| [WebAssembly Binary Toolkit (WABT)](https://github.com/WebAssembly/wabt) | Contains useful tools like wat2wasm                               |
| [Wasmtime](https://wasmtime.dev/)                                        | A runtime for WebAssembly & WASI                                  |
| [Wasmer](https://wasmer.io/)                                             | A runtime for WebAssembly & WASIX                                 |
| [emscripten](https://emscripten.org/index.html)                          | Compiler toolchain to Wasm                                        |
| [Rust](https://www.rust-lang.org/)                                       | Rust tools for Rust-related Wasm examples                         |
| [Fermyon Spin](https://www.fermyon.com/spin)                             | Platform for serverless Wasm apps                                 |
| [WASI SDK](https://github.com/WebAssembly/wasi-sdk)                      | WASI-enabled WebAssembly C/C++ toolchain                          |
| [Wasm Tools](https://github.com/bytecodealliance/wasm-tools)             | Rust tooling for low-level manipulation of WebAssembly modules    |
| [WIT Bindgen](https://github.com/bytecodealliance/wit-bindgen)           | Guest language bindings generator for WIT and the Component Model |
| [.NET](https://dot.net)                                                  | .NET SDK for building _Blazor_ apps                               |
| [Just](https://github.com/casey/just)                                    | Useful command runner                                             |
| [http-server](https://www.npmjs.com/package/http-server)                 | Simple static HTTP server                                         |

Note that for Rust, the _wasm32-wasi_ target, [_wasm-pack_](https://rustwasm.github.io/wasm-pack/), [`cargo-wasix`](https://wasix.org/docs/language-guide/rust/installation) and  are also installed.

Note that for .NET, the [_wasm-tools_](https://learn.microsoft.com/en-us/aspnet/core/blazor/tooling?view=aspnetcore-8.0&pivots=linux-macos#net-webassembly-build-tools) and the [_wasm-experimental_ workload](https://learn.microsoft.com/en-us/aspnet/core/client-side/dotnet-interop?view=aspnetcore-8.0#prerequisites) are also installed.

Note that for Wasm Tools, the languge toolings for [Rust](https://component-model.bytecodealliance.org/language-support/rust.html) and [JavaScript](https://component-model.bytecodealliance.org/language-support/javascript.html) are installed.

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

| Argument         | Default Value  |                              |
| ---------------- | -------------- | ---------------------------- |
| `base_image`     | `ubuntu:jammy` | The base image               |
| `wasi_sdk`       | `21`           | WASI SDK version             |
| `dotnet_repo`    | `22.04`        | Used .NET repository         |
| `dotnet_version` | `8.0`          | Installed .NET version       |
| `node_major`     | `20`           | Installed Node version       |
| `wasm_tools`     | `1.201.0`      | Installed Wasm Tools version |

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

- `cargo new hello-wasm`
- Look at _src/main.rs_
- Compile and run:

  ```bash
  cargo build --target wasm32-wasi
  wasmtime target/wasm32-wasi/debug/hello-wasm.wasm
  ```

#### Exercise

Goals: Make sure that you have the necessary tools (given if you use the Docker image), get familiar with compiling code to Wasm and running it outside of the browser with Wasmtime.

- Choose C or Rust
- Implement a program that prints all Fibonacci numbers up to 1000
- Compile it to Wasm
- Run it with Wasmtime

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
    (local $current i32) ;; will hold a fibonacci number
    (local $next i32) ;; will hold the subsequent fibonacci number
    (local $ptr i32) ;; will be used as a pointer to memory where to store the numbers
    (local $limit i32) ;; will define our upper bound for fibonacci calculation
    (local $temp i32) ;; temporary variable

    ;; Initializing our local variables.
    (local.set $current (i32.const 0))
    (local.set $next (i32.const 1))
    (local.set $ptr (i32.const 0))
    (local.set $limit (i32.const 100))

    ;; Storing the first two Fibonacci numbers (0 and 1) in memory.
    (i32.store (local.get $ptr) (local.get $current))
    ;; Update $ptr to point to the next memory cell.
    (local.set $ptr (i32.add (local.get $ptr) (i32.const 4)))
    (i32.store (local.get $ptr) (local.get $next))
    (local.set $ptr (i32.add (local.get $ptr) (i32.const 4)))

    ;; Loop that calculates Fibonacci numbers and stores them in memory.
    (loop $loop1
      ;; Store the sum of $current and $next in a temporary variable.
      (local.set $temp (i32.add (local.get $current) (local.get $next)))

      ;; Check if the new Fibonacci number is less than or equal to our limit.
      (if (i32.le_s (local.get $temp) (local.get $limit))
        (then
          ;; If yes, update $current to the value of $next.
          (local.set $current (local.get $next))
          ;; Update $next to the new Fibonacci number.
          (local.set $next (local.get $temp))
          ;; Store the new Fibonacci number in memory.
          (i32.store (local.get $ptr) (local.get $temp))
          ;; Update $ptr to point to the next memory cell.
          (local.set $ptr (i32.add (local.get $ptr) (i32.const 4)))
          ;; Continue loop from its beginning.
          (br $loop1)
        )
      )
    )

    ;; At the end, we return how many Fibonacci numbers have been calculated
    ;; and stored in memory by dividing the memory pointer by 4
    ;; (since WebAssembly's i32 takes up 4 bytes of memory).
    (i32.div_u (local.get $ptr) (i32.const 4))
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
for (let i = 0; i < len; i++) {
  console.log(fibonacciNumbers[i]);
}
```

Exercises:

- Store the WAT code locally and compile it with _wat2wasm_: `wat2wasm fib.wat`
- Decompile the Wasm code with _wasm2wat_: `wasm2wat fib.wasm`
- Decompile the Wasm code with _wasm2c_: `wasm2c fib.wasm`
- Try running _wat-desugar_ on the WAT code: : `wat-desugar fib.wat`
- Try running _wasm-stats_: `wasm-stats fib.wasm`

#### Palindrome

Palindrome checker writte with WAT, running in the browser. Sample code can be found [here](./palindrome).

#### Diving Deeper into WAT

[Introduction to WAT](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat) based on first day of _Advent of Code 2022_. See [justfile](https://github.com/rstropek/AdventOfCode2022/blob/main/Day01-wat/justfile) for commands. The sample contains hosts in

- [Rust](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-rs),
- [JavaScript](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-js) and
- [.NET](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-wat/wasm-host-dotnet)

Compare [Mini Rust sample](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-mini-rs) with [Full Rust sample](https://github.com/rstropek/AdventOfCode2022/tree/main/Day01-full-rs).

### Emscripten

Emscripten is a complete Open Source compiler toolchain to WebAssembly. Using Emscripten you can compile C and C++ code, or any other language that uses LLVM, into WebAssembly, and run it on the Web, Node.js, or other Wasm runtimes. Read more [here](https://emscripten.org/docs/introducing_emscripten/about_emscripten.html).

#### Using `cwrap`

The following examples uses [`cwrap`](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#interacting-with-code-ccall-cwrap). `cwrap` is quite straightforward and designed to be simple. It's suitable for scenarios where you only need to call a few C functions from JavaScript. It doesn't handle C++ classes or objects. It's quite limited in terms of type support. When your needs are pretty simple, such as calling a few C functions without involving C++ objects or classes, `cwrap` is a good choice because of its simplicity and less overhead.

```bash
mkdir emscripten
cd emscripten
mkdir test
cd test
```

Create the file _hello_function.cpp_ in the _test_ folder:

```cpp
#include <math.h>

extern "C" {
  int int_sqrt(int x) {
    return sqrt(x);
  }

  bool is_palindrome(char *text, int len) {
    char *end = text + len - 1;
    while (text < end) {
      if (*text != *end) { return false; }
      text++;
      end--;
    }

    return true;
  }
}
```

```bash
cd ..
emcc test/hello_function.cpp -o function.js -sEXPORTED_FUNCTIONS=_int_sqrt,_is_palindrome -sEXPORTED_RUNTIME_METHODS=ccall,cwrap
```

Create the file _index.html_:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
  </head>
  <body>
    <script src="function.js"></script>
    <script>
      Module.onRuntimeInitialized = () => {
        int_sqrt = Module.cwrap("int_sqrt", "number", ["number"]);
        console.log(int_sqrt(12));

        is_palindrome = Module.cwrap("is_palindrome", "number", [
          "string",
          "number",
        ]);
        text = "otto";
        console.log(is_palindrome(text, text.length));
      };
    </script>
  </body>
</html>
```

Run a local web server (`http-server`) and open the page in your browser. Check the console for results.

#### Using `embind`

[Embind](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/embind.html) is used to bind C++ functions and classes to JavaScript, so that the compiled code can be used in a natural way by "normal" JavaScript. _embind_ is more feature-rich and complex than `cwrap`. It provides a robust framework for interacting between C++ and JavaScript. Unlike `cwrap`, _embind_ allows you to expose entire C++ classes and objects to JavaScript, not just functions. It provides a wide range of type mappings and can handle complex data types, such as classes and enums. When you need to expose more than just functions and deal with C++ objects, classes, and other complex types, _embind_ would be the preferred choice despite its additional overhead.

```bash
mkdir embind
cd embind
mkdir test
cd test
```

Create the file _hello_function.cpp_ in the _test_ folder:

```cpp
#include <emscripten/bind.h>
#include <math.h>
#include <string>

using namespace emscripten;

extern "C" {
  int int_sqrt(int x) {
    return sqrt(x);
  }

  bool is_palindrome(const std::string& text)
  {
    int start = 0;
    int end = text.length() - 1;
    while (start < end) {
        if (text[start] != text[end]) {
            return false;
        }
        start++;
        end--;
    }

    return true;
  }
}

EMSCRIPTEN_BINDINGS(my_module) {
    function("int_sqrt", &int_sqrt);
    function("is_palindrome", &is_palindrome);
}
```

```bash
cd ..
emcc -l embind test/hello_function.cpp -o function.js
```

Create the file _index.html_:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
  </head>
  <body>
    <script src="function.js"></script>
    <script>
      Module.onRuntimeInitialized = () => {
        console.log(Module.int_sqrt(12));

        text = "radar";
        console.log(Module.is_palindrome(text));
      };
    </script>
  </body>
</html>
```

Run a local web server (`http-server`) and open the page in your browser. Check the console for results.

### WasmFiddle (Deprecated)

**Unfortunately, WasmFiddle is no longer available.** The sample code is kept here just for reference.

[_WasmFiddle_](https://wasdk.github.io/WasmFiddle/) **was** a great online tool for experimenting with Wasm. It allowed you to write Wasm code in C. It also allowed you to write JavaScript code that can call Wasm functions. You had log functions and you can even draw on a HTML Canvas. The tool was very useful for learning Wasm and experimenting with it.

Here is an example:

```c
// Define a structure to represent a point in 2D space
struct Point {
    long x;  // Horizontal coordinate
    long y;  // Vertical coordinate
};

// Define a structure to encapsulate two Point structures
struct TwoPoints {
    struct Point point1;  // First point in 2D space
    struct Point point2;  // Second point in 2D space
};

// Create a global variable to hold two points
struct TwoPoints points;

// Directional variables to dictate the movement of point1
int dir_x1 = 10;  // Horizontal direction (positive means moving right)
int dir_y1 = 15;  // Vertical direction (positive means moving up)

// Directional variables to dictate the movement of point2
int dir_x2 = 25;  // Horizontal direction (positive means moving right)
int dir_y2 = -5;  // Vertical direction (negative means moving down)

// Function to move two points within specified width and height
// and bounce them back when they hit the boundaries
void move(int width, int height) {
    // Move point1
    // Add respective direction values to point1 coordinates
    points.point1.x += dir_x1;
    points.point1.y += dir_y1;

    // Move point2
    // Add respective direction values to point2 coordinates
    points.point2.x += dir_x2;
    points.point2.y += dir_y2;

    // Check bounds and bounce for point1
    // If point1 x-coordinate is out of bounds, reverse its x-direction
    if (points.point1.x <= 0 || points.point1.x >= width) {
        dir_x1 = -dir_x1;
    }
    // If point1 y-coordinate is out of bounds, reverse its y-direction
    if (points.point1.y <= 0 || points.point1.y >= height) {
        dir_y1 = -dir_y1;
    }

    // Check bounds and bounce for point2
    // If point2 x-coordinate is out of bounds, reverse its x-direction
    if (points.point2.x <= 0 || points.point2.x >= width) {
        dir_x2 = -dir_x2;
    }
    // If point2 y-coordinate is out of bounds, reverse its y-direction
    if (points.point2.y <= 0 || points.point2.y >= height) {
        dir_y2 = -dir_y2;
    }
}

// Function to get a pointer to the points data
// This function could be used to access point data without exposing the actual structure
long* getPoints() {
  // Cast the address of `points` to a pointer to long
  // This allows accessing x and y coordinates as an array
  // Note: This breaks the abstraction of the point structures
  // and would require knowledge of the structure layout to use safely.
  return (long*)&points;
}
```

```js
// Initialize a WebAssembly (Wasm) module and instance
// `wasmCode` and `wasmImports` are assumed to be defined elsewhere in your code
var wasmModule = new WebAssembly.Module(wasmCode);
var wasmInstance = new WebAssembly.Instance(wasmModule, wasmImports);

// Acquire a reference to the memory used by the Wasm instance, and create
// a typed array (Int32Array) to manipulate the memory in a more accessible way.
// Note: Wasm memory is a contiguous buffer of bytes. Typed arrays allow us
// to interact with this buffer using JavaScript’s numeric types.
const buffer = wasmInstance.exports.memory.buffer;
const points = new Int32Array(buffer);

// Obtain the offset into Wasm memory where point data is stored.
// Divide by 4 because Int32Array views memory as 32-bit chunks,
// and we want to index into them, not the individual bytes.
let offset = wasmInstance.exports.getPoints() / 4;

// Initialize the points in the Wasm memory.
// These points will be used in the rendering logic below.
points[offset] = 10;
points[offset + 1] = 20;
points[offset + 2] = 30;
points[offset + 3] = 40;

// Initialize the canvas and get its 2D rendering context
// `lib.showCanvas()` is assumed to perform canvas-related initialization
// and `canvas` is assumed to be available in the scope.
lib.showCanvas();
let ctx = canvas.getContext("2d");
ctx.clearRect(0, 0, canvas.width, canvas.height);

// Define a counter that will limit the number of animation frames to 1000.
// It's useful to prevent an infinite animation loop.
let counter = 1000;

function getRandomColor() {
  // Generate random values for red, green, and blue channels.
  const r = Math.floor(Math.random() * 256);
  const g = Math.floor(Math.random() * 256);
  const b = Math.floor(Math.random() * 256);

  // Construct and return an RGB color string.
  return `rgb(${r},${g},${b})`;
}

// Define the animation function that will be called repeatedly
function step() {
  // Decrease the counter by one on each frame.
  counter--;

  // Call the `move` function exported from the Wasm instance,
  // which updates the position of points according to canvas dimensions.
  wasmInstance.exports.move(canvas.width, canvas.height);

  // Clear the entire canvas, preparing it for the next frame of drawing.
  // Try the code with the following line and without
  //ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Begin a new path for the line to be drawn between the points.
  ctx.beginPath();

  // Move the drawing cursor to the first point.
  ctx.moveTo(points[offset], points[offset + 1]);

  // Draw a line from the current position (first point) to the second point.
  ctx.lineTo(points[offset + 2], points[offset + 3]);

  // Set the style and width of the line.
  ctx.strokeStyle = getRandomColor();
  ctx.lineWidth = 5;

  // Actually draw the path using the previously defined line and style.
  ctx.stroke();

  // If the counter is not yet exhausted, request the next animation frame.
  if (counter > 0) {
    window.requestAnimationFrame(step);
  }
}

// Kickstart the animation by calling `step` on the next frame.
window.requestAnimationFrame(step);
```

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

You can also limit the CPU usage of Wasm by specifying a _fuel_ limit:

```bash
# Should work, enough fuel
wasmtime --dir=. demo.wasm --fuel 10000 hallo.txt hallo2.txt

# Should not work, Wasm runs out of fuel
wasmtime --dir=. demo.wasm --fuel 1000 hallo.txt hallo2.txt
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

### .NET with Wasm/WASI

```bash
mkdir dotnet-wasi
cd dotnet-wasi
dotnet new console
dotnet add package Wasi.Sdk --prerelease
ls -la ./bin/Debug/net8.0/
wasmtime ./bin/Debug/net8.0/dotnet-wasi.wasm
```

Read more [here](https://blog.jetbrains.com/dotnet/2022/12/15/the-future-of-net-with-wasm/). Note that this example uses experimental features of .NET and is _not_ ready for production!

### Blazor

Microsoft offers [good tutorials for Blazor Wasm](https://learn.microsoft.com/en-us/aspnet/core/blazor/tutorials/build-a-blazor-app?view=aspnetcore-8.0). This image contains the necessary tools to follow the tutorials.

**Notes**:

- You must run Blazor apps with `dotnet run --urls http://*:8080` to make them accessible from outside of the container.
- Blazor caches the Wasm- and DLL-files after the first load of the app. If you want to demonstrate how Blazor Wasm uses .NET DLLs in the browser, do not forget to clear the _Cache storage_ using your browser's dev tools.

### Wasm Component Model

#### WAT

```wat
(module
  (func $add (param $lhs i32) (param $rhs i32) (result i32)
      local.get $lhs
      local.get $rhs
      i32.add)
  (export "add" (func $add))
)
```

#### WIT

```wit
package example:component;

world example {
    export add: func(x: s32, y: s32) -> s32;
}
```

#### Build Wasm Component

```bash
wasm-tools component embed add.wit add.wat -o add.wasm
wasm-tools component new add.wasm -o add.component.wasm
```

#### Rust Host

See [wasm-component](https://github.com/rstropek/wasm-workshop/blob/main/wasm-component)

### Fermyon Spin

#### Hello World

- Create a new _Spin_ application: `spin new http-rust hello_spin`
- Build the application: `spin build`
- Take a look at the generated code: `ls -la target/wasm32-wasi/release/`
- Run the app: `spin up --listen [::]:8080` (this enables accessing the app from outside of the container)

#### Larger Example

A larger example (Todo list) can be found [here](https://github.com/rstropek/rust-api-fxs/tree/main/todo-spin). Sample requests can be found [here](https://github.com/rstropek/rust-api-fxs/blob/main/requests.http) (you can run time with _Rest Client_, _Postman_, or another tool for issuing HTTP requests).
