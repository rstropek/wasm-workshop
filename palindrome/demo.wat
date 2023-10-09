(module
  (memory 1)
  (export "memory" (memory 0))
  (export "is_palindrome" (func $is_palindrome))

  (func $is_palindrome (param $ptr i32) (param $len i32) (result i32)
    (local $i i32)
    (local $end i32)
    (local $result i32)

    (local.set $i (i32.const 0))
    (local.set $end (i32.sub (local.get $len) (i32.const 1)))
    (local.set $result (i32.const 1))
    
    (block $b
      (loop $l
        (br_if $b (i32.ge_u (local.get $i) (local.get $end)))
        
        ;; check if characters are equal
        (if 
          (i32.ne 
            (i32.load8_u (i32.add (local.get $ptr) (local.get $i)))
            (i32.load8_u (i32.add (local.get $ptr) (local.get $end))))
            (then
              (local.set $result (i32.const 0))
              (br $b)
            )
        )
        
        
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (local.set $end (i32.sub (local.get $end) (i32.const 1)))
        (br $l)
      )
    )
    (local.get $result)
  )
)
