;; This module contains logic to check if a string is a palindrome.
(module
  ;; Declare a single page of memory (64KiB) and export it with the name "memory".
  (memory 1)
  (export "memory" (memory 0))
  ;; Export the function 'is_palindrome' so it can be called from JavaScript (or another host environment).
  (export "is_palindrome" (func $is_palindrome))

  ;; Define the function 'is_palindrome' which takes two parameters: a pointer to the string and its length.
  ;; The function returns an i32 value: 1 if the string is a palindrome and 0 if it is not.
  (func $is_palindrome (param $ptr i32) (param $len i32) (result i32)
    ;; Declare local variables: 
    ;; $i - used to traverse from the start of the string,
    ;; $end - used to traverse from the end of the string,
    ;; $result - to store the intermediate and final results of the palindrome check.
    (local $i i32)
    (local $end i32)
    (local $result i32)

    ;; Initialize $i to 0 as we start from the beginning of the string.
    (local.set $i (i32.const 0))
    ;; Initialize $end to len - 1, pointing to the last character of the string.
    (local.set $end (i32.sub (local.get $len) (i32.const 1)))
    ;; Initialize $result to 1 assuming the string is a palindrome until proven otherwise.
    (local.set $result (i32.const 1))
    
    ;; Begin a block labeled $b.
    (block $b
      ;; Begin a loop labeled $l.
      (loop $l
        ;; Break to block $b if $i is greater than or equal to $end.
        (br_if $b (i32.ge_u (local.get $i) (local.get $end)))
        
        ;; Check if characters at positions $i and $end are equal.
        (if 
          ;; If characters are not equal,
          ;; we use i32.ne to compare the characters at positions $i and $end in the memory.
          (i32.ne 
            ;; Load the character at position $i.
            (i32.load8_u (i32.add (local.get $ptr) (local.get $i)))
            ;; Load the character at position $end.
            (i32.load8_u (i32.add (local.get $ptr) (local.get $end))))
            ;; If characters are not equal, set $result to 0 and break to block $b.
            (then
              (local.set $result (i32.const 0))
              (br $b)
            )
        )
        
        ;; Increment $i by 1 to move towards the end of the string.
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        ;; Decrement $end by 1 to move towards the start of the string.
        (local.set $end (i32.sub (local.get $end) (i32.const 1)))
        ;; Continue the loop.
        (br $l)
      )
    )
    ;; Return $result which is 1 if the string is a palindrome and 0 if it is not.
    (local.get $result)
  )
)
