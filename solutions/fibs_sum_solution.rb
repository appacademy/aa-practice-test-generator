# Implement a method that finds the sum of the first n
# fibonacci numbers recursively. Assume n > 0.

def fibs_sum(n)
  return 0 if n == 0
  return 1 if n == 1

  fibs_sum(n-1) + fibs_sum(n-2) + 1
end

# extra credit, a fully memoized solution that hackily gets around the recursive call spec
# def fibs_sum(n, orig_n = nil)
#   orig_n ||= n
#   if n == 1
#     return (orig_n == n ? 1 : [1])
#   elsif n == 2
#     return (orig_n == n ? 2 : [1, 1])
#   end
#   last_fib_seq = fibs_sum(n-1, orig_n)
#   full_fib_seq = last_fib_seq + [last_fib_seq[-1] + last_fib_seq[-2]]
#   orig_n == n ? full_fib_seq.sum : full_fib_seq
# end