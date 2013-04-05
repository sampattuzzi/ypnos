module Ypnos.Examples.Reductions where

import Ypnos
import Ypnos.CUDA

import Data.Array.Accelerate hiding (fst, snd, size, fromIntegral)
import qualified Data.Array.Accelerate.Interpreter as I

sumReduce = mkReducer (+) (+) 0 id

sumReducer :: [Int] -> Int -> Int -> Int
sumReducer xs x y = reduceG sumReduce arr
  where arr = fromList (Z :. x :. y) (cycle xs)

red :: Shape sh => (a -> a -> a) -> a -> Array sh a -> a
red f d a = foldr f d (toList a)

sumReduce' :: Shape sh => Array sh Int -> Int
sumReduce' = red (+) 0

sumReducer' xs x y = sumReduce' arr
  where arr = fromList (Z :. x :. y) (cycle xs)
