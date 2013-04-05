{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ImplicitParams #-}

module Testing.Ypnos.CUDA.Expr.Combinators where

import Test.Framework (testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck

import Data.List

import Ypnos
import Ypnos.CUDA
import Ypnos.Core.Grid

import Ypnos.Examples.Stencils
import Ypnos.Examples.Reductions

import Data.Array.Accelerate hiding (fst, snd, size, fromIntegral)
import qualified Data.Array.Accelerate.Interpreter as I

import Data.Array.Unboxed hiding (Array)

import Control.Monad

comb_tests = testGroup "Ypnos.CUDA.Expr.Combinators"
    [ testProperty "Reduce" prop_reduce
    , testProperty "Run against accelerate" prop_run
    , testProperty "Run against original Ypnos" prop_run2
    ]

bounded l x y = upper l [x,y] && lower 0 [x,y]
upper l = all (\ x -> x < l)
lower l = all (\ x -> x >= l)

prop_reduce :: [Int] -> Int -> Int -> Gen Prop
prop_reduce xs x y =  bounded 50 x y && (length xs) > 0 ==>
    sumReducer' xs x y == sumReducer xs x y

runner :: ([Float] -> (Int,Int) -> [Float])
       -> ([Float] -> (Int,Int) -> [Float])
       -> [Float] -> (Int,Int) -> Gen Prop
runner run1 run2 xs (x, y) = upper 10 [x, y] && lower 2 [x, y] && length xs > 0 ==>
    run1 xs (x,y) == run2 xs (x,y)

prop_run = runner (raiseToList runAvg) (runAvgY)
prop_run2 = runner (runAvgY') (runAvgY)
