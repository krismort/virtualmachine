/**
 * A simple stack-based virtual machine
 */
class VirtualMachine {
  constructor() {
    this.stack = [];
    this.pc = 0; // Program counter
    this.running = false;
    this.output = [];
  }

  /**
   * Reset the VM to initial state
   */
  reset() {
    this.stack = [];
    this.pc = 0;
    this.running = false;
    this.output = [];
  }

  /**
   * Execute a program
   * @param {Array} program - Array of instructions
   */
  execute(program) {
    this.reset();
    this.running = true;
    
    while (this.running && this.pc < program.length) {
      const instruction = program[this.pc];
      this.executeInstruction(instruction);
      this.pc++;
    }
    
    return this.output;
  }

  /**
   * Execute a single instruction
   * @param {Object} instruction - Instruction object with opcode and optional operand
   */
  executeInstruction(instruction) {
    const { opcode, operand } = instruction;

    switch (opcode) {
      case 'PUSH':
        this.stack.push(operand);
        break;
      
      case 'POP':
        if (this.stack.length === 0) {
          throw new Error('Stack underflow');
        }
        return this.stack.pop();
      
      case 'ADD':
        if (this.stack.length < 2) {
          throw new Error('Stack underflow');
        }
        {
          const b = this.stack.pop();
          const a = this.stack.pop();
          this.stack.push(a + b);
        }
        break;
      
      case 'SUB':
        if (this.stack.length < 2) {
          throw new Error('Stack underflow');
        }
        {
          const b = this.stack.pop();
          const a = this.stack.pop();
          this.stack.push(a - b);
        }
        break;
      
      case 'MUL':
        if (this.stack.length < 2) {
          throw new Error('Stack underflow');
        }
        {
          const b = this.stack.pop();
          const a = this.stack.pop();
          this.stack.push(a * b);
        }
        break;
      
      case 'DIV':
        if (this.stack.length < 2) {
          throw new Error('Stack underflow');
        }
        {
          const b = this.stack.pop();
          const a = this.stack.pop();
          if (b === 0) {
            throw new Error('Division by zero');
          }
          this.stack.push(Math.floor(a / b));
        }
        break;
      
      case 'PRINT':
        if (this.stack.length === 0) {
          throw new Error('Stack underflow');
        }
        {
          const value = this.stack[this.stack.length - 1];
          this.output.push(value);
          console.log(value);
        }
        break;
      
      case 'HALT':
        this.running = false;
        break;
      
      default:
        throw new Error(`Unknown opcode: ${opcode}`);
    }
  }

  /**
   * Get the current stack state
   */
  getStack() {
    return [...this.stack];
  }
}

module.exports = VirtualMachine;
