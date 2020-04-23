# escript-antlr4

## Getting started

1. Install `escript-antlr4` and `antlr4ts` as dependencies using your preferred
   package manager.

```bash
npm install escript-antlr4 antlr4ts --save
```

```bash
yarn add escript-antlr4 antlr4ts
```

2. Use your grammar in TypeScript (or JavaScript)

```typescript
import { EscriptLexer, EscriptParser } from 'escript-antlr4';
import { ANTLRInputStream, CommonTokenStream } from 'antlr4ts';

const program = `
program main(arg0, arg1)
    Print(arg0);
endprogram

function f1() endfunction
function f2() endfunction
`;

const inputStream = new ANTLRInputStream(program);

const lexer = new EscriptLexer(inputStream);
const tokenStream = new CommonTokenStream(lexer);
const parser = new EscriptParser(tokenStream);

/**
 * Parse the input:
 * 	- A source file (.src or .inc) has entry point `compilationUnit`.
 *  - A module file (.em) has entry point `moduleUnit()`.
 */

const tree = parser.compilationUnit();
```

The two main ways to inspect the tree are by using a listener or a visitor, you
can read about the differences between the two
[here](https://github.com/antlr/antlr4/blob/master/doc/listeners.md).

###### Listener Approach

```typescript
// ...
import { EscriptParserListener, ProgramDeclarationContext } from 'escript-antlr4';
import { ParseTreeWalker } from 'antlr4ts/tree';

class EnterProgramListener implements EscriptParserListener {
    enterProgramDeclaration(context: ProgramDeclarationContext) {
        console.log(`Program name: ${context.IDENTIFIER().text}`);
        // ...
    }

    // other enterX functions...
}

// Create the listener
const listener: EscriptParserListener = new EnterProgramListener();
// Use the entry point for listeners
ParseTreeWalker.DEFAULT.walk(listener, tree);
```

###### Visitor Approach

```typescript
// ...
import { EscriptParserVisitor, FunctionDeclarationContext } from 'escript-antlr4';
import { AbstractParseTreeVisitor } from 'antlr4ts/tree';

// Extend the AbstractParseTreeVisitor to get default visitor behaviour
class CountElementsVisitor
    extends AbstractParseTreeVisitor<number>
    implements EscriptParserVisitor<number> {

    defaultResult() {
        return 0;
    }

    aggregateResult(aggregate: number, nextResult: number) {
        return aggregate + nextResult;
    }

    visitFunctionDeclaration(context: FunctionDeclarationContext): number {
        return 1 + super.visitChildren(context);
    }
}

// Create the visitor
const countElementsVisitor = new CountElementsVisitor();
// Use the visitor entry point
const count = countElementsVisitor.visit(tree);
console.log(`There are ${count} function declarations`);
```
