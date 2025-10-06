const VirtualMachine = require('./index');

// Example 1: Simple arithmetic
console.log('Example 1: Simple arithmetic (2 + 3)');
const vm1 = new VirtualMachine();
const program1 = [
  { opcode: 'PUSH', operand: 2 },
  { opcode: 'PUSH', operand: 3 },
  { opcode: 'ADD' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
vm1.execute(program1);
console.log('Stack:', vm1.getStack());
console.log();

// Example 2: Multiple operations
console.log('Example 2: Multiple operations ((5 + 3) * 2)');
const vm2 = new VirtualMachine();
const program2 = [
  { opcode: 'PUSH', operand: 5 },
  { opcode: 'PUSH', operand: 3 },
  { opcode: 'ADD' },
  { opcode: 'PUSH', operand: 2 },
  { opcode: 'MUL' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
vm2.execute(program2);
console.log('Stack:', vm2.getStack());
console.log();

// Example 3: Division
console.log('Example 3: Division (10 / 2)');
const vm3 = new VirtualMachine();
const program3 = [
  { opcode: 'PUSH', operand: 10 },
  { opcode: 'PUSH', operand: 2 },
  { opcode: 'DIV' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
vm3.execute(program3);
console.log('Stack:', vm3.getStack());
console.log();

// Example 4: Subtraction
console.log('Example 4: Subtraction (15 - 7)');
const vm4 = new VirtualMachine();
const program4 = [
  { opcode: 'PUSH', operand: 15 },
  { opcode: 'PUSH', operand: 7 },
  { opcode: 'SUB' },
  { opcode: 'PRINT' },
  { opcode: 'HALT' }
];
vm4.execute(program4);
console.log('Stack:', vm4.getStack());
console.log();

// Example 5: Complex expression ((10 + 5) * 3 - 20) / 5
console.log('Example 5: Complex expression ((10 + 5) * 3 - 20) / 5');
const vm5 = new VirtualMachine();
const program5 = [
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
vm5.execute(program5);
console.log('Stack:', vm5.getStack());
