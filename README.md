This is a MIPS Assembly Language project implemented for the MARS (MIPS Assembler and Runtime Simulator) environment. The project is an interactive, educational game designed to train and test a user's proficiency in converting between 8-bit binary numbers and their decimal integer equivalents (0–255).

Game Features

Conversion Modes: Random problems are generated in Binary and Decimal format that too randomly. The user has to provide the Binary equivalent to a Decimal question and a Decimal equivalent to a binary question.
Progression: The game features 10 levels. Level L requires the player to solve L problems, resulting in a total of 55 unique problems for a perfect game.
Score & Feedback: Each correct answer awards +1 point. The game provides immediate sound (via MIDI syscalls) and textual feedback on correctness.
Input Robustness: Includes robust parsing and validation to reject non-numeric characters, strings of incorrect length, and out-of-range values.
Timing: Implements a post-input timeout check using MARS syscall 30 (System Time) to penalize slow answers.
