(*
  The following function num implements the finite state automaton for
  scanning a decimal number. For example:
  - Valid numbers: "1"; "1.1"; "11.1"; "11.11"; ".11";
  - Invalid numbers: "."; "1."; "B"

  The function is composed of three mutually recursive functions one, two
  and three, each representing a state in the FSA it implements. Note that 
  all the recursive calls are tail recursive. Therefore, the implementation
  inherently scales.
  
  LAZY EVALUATION.
  The main point of difference in this implementation w.r.t to the first
  implementation is the use of lazy evaluation to postpone the further 
  computation to the point when it is demanded by the lexer. This is to decouple
  the implementation of the state machine from the lexer's policy of selecting
  the appropriate token among those found in the input stream. This job is
  rightfully of the lexical analyser, and not the FSAs it invokes. To achieve this,
  instead of making a mutually recursive call to the other state function,
  it returns the function (unevaluated) that represents the state to which the
  transition is happening.

  THE state TYPE.
  The state type is used as the return type of the functions so that the
  FSA can return a coherent type in both of the following two cases:
  - State. When the current character is consumed and the FSA proceeds to another
    state. For more details, see state.ml.
  - Termination. When the current character is consumed resulting in the termination of
    execution of the FSA. The termination of execution may itself happen in two
    ways:
    * success. This means that the current lexeme was successfully consumed. In which
      case Termination(true) is returned. This also means that the state is an
      accepting state.
    * failure. This means that the current lexeme wasn't successfully consumed.
      It doesn't belong the token class of this FSA. In which case 
      Termination(false) is returned.

  LOOKAHEAD.
  The lexical analyser typical doesn't have the luxury of making a lot of back-n-forth
  movements on the input stream. At most, it is allowed to take a certain bounded
  number of leading characters (known as the lookahead k) in the input stream into account 
  and make its next decision (i.e. either to transition to another state, or 
  termination in success or failure). Typically, k is given the value 1.

  In the given implementation, we see this happening through the lookahead variable. Note
  that in any circumstance, num always advances one and only character at a time on the
  input stream. Hence, there is no ambiguity left for the lexer to determine where in the
  input stream should it place its pointer. All live FSAs are at the same position in
  the input stream at any given time.

  USAGE.
  See test_num.ml for usage information.
*)

(* Returns the initial state of the FSA and the list of accepting states *)
let num () : State.state * ((char -> char option -> State.state) list) =
  let is_digit c = (c >= '0' && c <= '9') in
  let rec one (c : char) (lookahead : char option) : State.state =
    if (is_digit c) then
      match lookahead with 
        Some(c') ->
          if (is_digit c') || (c' = '.') then
            State.State(one)
          else
            State.Terminate(true)
      | None -> State.Terminate(true)
    else if c = '.' then
      match lookahead with
        Some(c') ->
          if (is_digit c') then
            State.State(two)
          else
            State.Terminate(false)
      | None -> State.Terminate(false)
    else
      State.Terminate(false)
  and two (c : char) (lookahead : char option) : State.state =
    if (is_digit c) then
      match lookahead with 
        Some(c') ->
          if (is_digit c') then
            State.State(three)
          else
            State.Terminate(true)
      | None -> State.Terminate(true)
    else
      State.Terminate(false)
  and three (c : char) (lookahead : char option) : State.state =
    if (is_digit c) then
      match lookahead with 
        Some(c') ->
          if (is_digit c') then
            State.State(three)
          else
            State.Terminate(true)
      | None         -> State.Terminate(true)
    else
      State.Terminate(false) 
  in
    (State.State(one), [one; three])
