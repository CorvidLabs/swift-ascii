# ASCII Pixel Art - WebAssembly

Convert ASCII art to pixel art SVG in the browser using Swift compiled to WebAssembly.

## Requirements

- [SwiftWasm toolchain](https://swiftwasm.org)
- Node.js 18+

## Development

Start the development server:

```bash
swift run carton dev
```

Open http://127.0.0.1:8080 in your browser.

## Building

Build the WebAssembly bundle:

```bash
swift run carton bundle --product ascii-pixel-wasm
```

Output will be in `Bundle/` directory.

## JavaScript API

Once loaded, the module exposes `window.ASCIIPixelArt`:

### asciiToSVG(ascii, color?, size?)

Convert ASCII art to SVG string.

```javascript
const svg = ASCIIPixelArt.asciiToSVG(`
  ##
 ####
  ##
`, '#FF0000', 256);

document.body.innerHTML = svg;
```

**Parameters:**
- `ascii` (string) - ASCII art text
- `color` (string, optional) - Hex color, default "#000000"
- `size` (number, optional) - Canvas size in pixels, default 256

### parseToJSON(ascii, color?)

Parse ASCII art to JSON grid data.

```javascript
const json = ASCIIPixelArt.parseToJSON(ascii, '#00FF00');
const grid = JSON.parse(json);
console.log(grid.width, grid.height, grid.pixels);
```

### mergeLayers(layers, size?, bgColor?)

Merge multiple ASCII layers into one SVG.

```javascript
const svg = ASCIIPixelArt.mergeLayers([
    { ascii: backgroundArt, color: '#87CEEB', zIndex: 0 },
    { ascii: bodyArt, color: '#FFD800', zIndex: 1 },
    { ascii: outlineArt, color: '#000000', zIndex: 2 }
], 512, '#1A1A2E');
```

## Fill Characters

Characters that create a pixel: `#` `*` `X` `@` `O`

Characters that are transparent: space, `.`, `-`

## License

MIT
