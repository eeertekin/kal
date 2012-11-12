{ASTBase} = require './ast'

Nodes = [
  class File extends ASTBase
    parse: ->
      @lock()
      @statements = @opt_multi Statement
      @req 'EOF'

  class Block extends ASTBase
    parse: ->
      @req 'NEWLINE'
      @req 'INDENT'
      @lock()      
      @statements = @opt_multi Statement
      @req 'DEDENT'
      
  class Statement extends ASTBase
    parse: ->
      @statement = @req ReturnStatement, IfStatement, WhileStatement, ForStatement, 
                        DeclarationStatement, AssignmentStatement, ExpressionStatement
      @lock()
    
  class ReturnStatement extends ASTBase
    parse: ->
      @req_val 'return'
      @lock()
      @expr = @opt Expression
      @req 'NEWLINE'
  
  class IfStatement extends ASTBase
    parse: ->
      @req_val 'if'
      @lock()
      @conditional = @req Expression
      @true_block = @req Block, Statement
      @else_block = @opt ElseStatement
        
  class ElseStatement extends ASTBase
    parse: ->
      @req_val 'else'
      @lock()
      @false_block = @req Block, Statement
  
  class WhileStatement extends ASTBase
  class ForStatement extends ASTBase
  class DeclarationStatement extends ASTBase
  class AssignmentStatement extends ASTBase
    parse: ->
      @lvalue   = @req UnaryExpression
      @assignOp = @req 'LITERAL'
      @error "not a valid assignment operator: #{assignOp.value}" if @assignOp.value not in ['=']
      @lock()
      @rvalue   = @req Expression
      @req 'NEWLINE'

  class ExpressionStatement extends ASTBase
    parse: ->
      @expr = @req Expression
      @req 'NEWLINE'
      
  class BlankStatment extends ASTBase
    parse: ->
      @req 'NEWLINE'

  class BinOp extends ASTBase
    parse: ->
      @op = @req 'IDENTIFIER', 'LITERAL'
      if @op.type is 'LITERAL'
        @error "unexpected operator #{@op.value}" if @op.value in [')',']','}',';',':']
        @lock()
        @error "unexpected operator #{@op.value}" if @op.value not in ['+','-','*','/']
      else
        @error "unexpected operator #{@op.value}" if @op.value not in ['and','or','xor','in','is']
  class Expression extends ASTBase
    parse: ->
      @left  = @req UnaryExpression
      @op    = @opt BinOp
      if @op?
        @lock()
        @right = @req Expression
    
  class UnaryExpression extends ASTBase
    parse: ->
      @base    = @req ParenExpression, ListExpression, MapExpression, NumberConstant, StringConstant, 'IDENTIFIER'
      @indexer = @opt IndexExpression
  class NumberConstant extends ASTBase
    parse: ->
      @token = @req 'NUMBER'
    
  class StringConstant extends ASTBase
    parse: ->
      @token = @req 'STRING'
  
  class IndexExpression extends ASTBase
      
  class ParenExpression extends ASTBase
    parse: ->
      @req_val '('
      @lock()
      @expr = @req Expression
      @req_val ')'
      
  class ListExpression extends ASTBase
  class MapExpression extends ASTBase
]

exports.Grammar = {}
exports.Grammar[v.name] = v for v in Nodes when v.__super__?.constructor is ASTBase
exports.GrammarRoot = exports.Grammar.File