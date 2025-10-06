const VirtualMachine = require('./index');

describe('VirtualMachine', () => {
  let vm;

  beforeEach(() => {
    vm = new VirtualMachine();
  });

  describe('Basic Operations', () => {
    test('should push values onto the stack', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5, 10]);
    });

    test('should pop values from the stack', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'POP' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5]);
    });

    test('should halt execution', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'HALT' },
        { opcode: 'PUSH', operand: 10 }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5]);
    });
  });

  describe('Arithmetic Operations', () => {
    test('should add two numbers', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'ADD' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([8]);
    });

    test('should subtract two numbers', () => {
      const program = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'SUB' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([7]);
    });

    test('should multiply two numbers', () => {
      const program = [
        { opcode: 'PUSH', operand: 4 },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'MUL' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([12]);
    });

    test('should divide two numbers', () => {
      const program = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PUSH', operand: 2 },
        { opcode: 'DIV' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5]);
    });

    test('should perform integer division', () => {
      const program = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'DIV' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([3]);
    });
  });

  describe('Complex Operations', () => {
    test('should handle complex arithmetic expression', () => {
      // ((10 + 5) * 3 - 20) / 5 = 5
      const program = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'ADD' },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'MUL' },
        { opcode: 'PUSH', operand: 20 },
        { opcode: 'SUB' },
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'DIV' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5]);
    });

    test('should handle multiple operations in sequence', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'PUSH', operand: 3 },
        { opcode: 'ADD' },
        { opcode: 'PUSH', operand: 2 },
        { opcode: 'MUL' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([16]);
    });
  });

  describe('PRINT Operation', () => {
    test('should print value without removing it from stack', () => {
      const program = [
        { opcode: 'PUSH', operand: 42 },
        { opcode: 'PRINT' },
        { opcode: 'HALT' }
      ];
      const output = vm.execute(program);
      expect(output).toEqual([42]);
      expect(vm.getStack()).toEqual([42]);
    });

    test('should print multiple values', () => {
      const program = [
        { opcode: 'PUSH', operand: 1 },
        { opcode: 'PRINT' },
        { opcode: 'PUSH', operand: 2 },
        { opcode: 'ADD' },
        { opcode: 'PRINT' },
        { opcode: 'HALT' }
      ];
      const output = vm.execute(program);
      expect(output).toEqual([1, 3]);
    });
  });

  describe('Error Handling', () => {
    test('should throw error on stack underflow for POP', () => {
      const program = [
        { opcode: 'POP' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on stack underflow for ADD', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'ADD' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on stack underflow for SUB', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'SUB' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on stack underflow for MUL', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'MUL' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on stack underflow for DIV', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'DIV' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on division by zero', () => {
      const program = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PUSH', operand: 0 },
        { opcode: 'DIV' }
      ];
      expect(() => vm.execute(program)).toThrow('Division by zero');
    });

    test('should throw error on stack underflow for PRINT', () => {
      const program = [
        { opcode: 'PRINT' }
      ];
      expect(() => vm.execute(program)).toThrow('Stack underflow');
    });

    test('should throw error on unknown opcode', () => {
      const program = [
        { opcode: 'INVALID' }
      ];
      expect(() => vm.execute(program)).toThrow('Unknown opcode: INVALID');
    });
  });

  describe('Reset Functionality', () => {
    test('should reset the VM state', () => {
      const program = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'PRINT' },
        { opcode: 'HALT' }
      ];
      vm.execute(program);
      expect(vm.getStack()).toEqual([5, 10]);
      expect(vm.output).toEqual([10]);
      
      vm.reset();
      expect(vm.getStack()).toEqual([]);
      expect(vm.output).toEqual([]);
      expect(vm.pc).toBe(0);
      expect(vm.running).toBe(false);
    });

    test('should allow reuse after reset', () => {
      const program1 = [
        { opcode: 'PUSH', operand: 5 },
        { opcode: 'HALT' }
      ];
      vm.execute(program1);
      expect(vm.getStack()).toEqual([5]);
      
      const program2 = [
        { opcode: 'PUSH', operand: 10 },
        { opcode: 'HALT' }
      ];
      vm.execute(program2);
      expect(vm.getStack()).toEqual([10]);
    });
  });
});
