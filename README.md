# virtualmachine

A simple stack-based virtual machine implementation in JavaScript.

## Features

- Stack-based architecture
- Basic arithmetic operations (ADD, SUB, MUL, DIV)
- Stack manipulation (PUSH, POP)
- Output capability (PRINT)
- Program control (HALT)
- Comprehensive error handling

## Installation

```bash
npm install
```

## Usage

### Basic Example

```javascript
const VirtualMachine = require('./index');

const vm = new VirtualMachine();
const program = [
  { opcode: 'PUSH', operand: 2 },
  { opcode: 'PUSH', operand: 3 },
  { opcode: 'ADD' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];

vm.execute(program);
// Output: 5
console.log('Result:', vm.getStack()); // [5]
```

## Instruction Set

### Stack Operations

- **PUSH** `operand` - Push a value onto the stack
- **POP** - Remove and return the top value from the stack

### Arithmetic Operations

- **ADD** - Pop two values, add them, and push the result
- **SUB** - Pop two values, subtract them (a - b), and push the result
- **MUL** - Pop two values, multiply them, and push the result
- **DIV** - Pop two values, divide them (a / b), and push the result (integer division)

### I/O Operations

- **PRINT** - Print the top value of the stack (without removing it)

### Control Operations

- **HALT** - Stop program execution

## Examples

Run the example programs:

```bash
npm run example
```

### Example 1: Simple Arithmetic (2 + 3)

```javascript
const program = [
  { opcode: 'PUSH', operand: 2 },
  { opcode: 'PUSH', operand: 3 },
  { opcode: 'ADD' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
// Output: 5
```

### Example 2: Complex Expression ((10 + 5) * 3 - 20) / 5

```javascript
const program = [
  { opcode: 'PUSH', operand: 10 },
  { opcode: 'PUSH', operand: 5 },
  { opcode: 'ADD' },      // 15
  { opcode: 'PUSH', operand: 3 },
  { opcode: 'MUL' },      // 45
  { opcode: 'PUSH', operand: 20 },
  { opcode: 'SUB' },      // 25
  { opcode: 'PUSH', operand: 5 },
  { opcode: 'DIV' },      // 5
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
// Output: 5
```

## API

### VirtualMachine

#### `constructor()`

Creates a new virtual machine instance.

#### `execute(program)`

Executes a program (array of instructions).

**Parameters:**
- `program` (Array): Array of instruction objects

**Returns:**
- Array: Output from PRINT operations

#### `reset()`

Resets the VM to its initial state (clears stack, output, and resets program counter).

#### `getStack()`

Returns a copy of the current stack state.

**Returns:**
- Array: Copy of the stack

## Testing

Run the test suite:

```bash
npm test
```

## Error Handling

The VM handles the following error conditions:

- **Stack underflow**: Attempting to pop from an empty stack
- **Division by zero**: Attempting to divide by zero
- **Unknown opcode**: Executing an unrecognized instruction

## License

ISC
