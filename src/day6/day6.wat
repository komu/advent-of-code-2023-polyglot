(module
    (memory $mem (export "memory") 1)
  
    (func $wins (export "part2") (param $time i64) (param $distance i64) (result i64)
        (local $charge i64)
        (local $sum i64)

        (local.set $charge (i64.const 1))
        (local.set $sum (i64.const 0))

        (loop 
            (local.set $charge (i64.add (local.get $charge) (i64.const 1)))
            
            (if (i64.gt_u
                    (i64.mul (local.get $charge)
                             (i64.sub (local.get $time) (local.get $charge)))
                    (local.get $distance))
              (then
                (local.set $sum (i64.add (local.get $sum) (i64.const 1)))))
            
            (br_if 0 (i64.lt_u (local.get $charge) (local.get $time)))
          )
        
        (local.get $sum))
    
    (func (export "part1") (param $times i32) (param $distances i32) (param $count i32) (result i64)
       (local $i i32)
       (local $product i64)
       (local $offset i32)
       
       (local.set $i (i32.const 0))
       (local.set $product (i64.const 1))
       
       (block
         (loop
           (br_if 1 (i32.ge_u (local.get $i) (local.get $count)))
           (local.set $offset (i32.mul (local.get $i) (i32.const 4)))
            
           (local.set $product (i64.mul (local.get $product)
               (call $wins (i64.extend_i32_u (i32.load (i32.add (local.get $offset) (local.get $times))))
                           (i64.extend_i32_u (i32.load (i32.add (local.get $offset) (local.get $distances)))))))
           (local.set $i (i32.add (local.get $i) (i32.const 1)))
           (br 0)
         )
       )
       
       (local.get $product)
    )
)
