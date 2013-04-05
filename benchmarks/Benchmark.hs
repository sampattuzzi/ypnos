{-# LANGUAGE GADTs #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Benchmark where

import System.Environment

import Ypnos.Examples.Stencils
  (runAvgY, runAvg, runAvgY', raiseToList, runLife, runLife', runId)
import Ypnos.Examples.Reductions

import Criterion
import Criterion.Monad
import Criterion.Analysis
import Criterion.Environment
import Criterion.Config
import Statistics.Resampling.Bootstrap
import Data.Vector.Unboxed hiding (map, mapM, foldr, foldr1, (++))
import Prelude hiding (sum, length)
import Control.Monad.Trans
import Control.Exception
import Foreign.CUDA.Driver.Error

l  = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0]
l2 = [True, False, False, True, False, True]
l3 = [1,2,3,4,5,6,7,8,9,10]

avgGPU = runAvgY l
avgCPU = runAvgY' l
avgA = raiseToList runAvg l

lifeCPU = runLife' l2
lifeGPU = runLife  l2

idGPU = runId l

sumGPU (x,y) = sumReducer l3 x y
sumCPU (x,y) = sumReducer' l3 x y

stenBench :: ((Int,Int) -> b) -> [Benchmark]
stenBench f = [ bench "10x10" $ whnf f (10,10)
              , bench "100x10" $ whnf f (100,10)
              , bench "100x100" $ whnf f (100,100)
              --, bench "1000x1000" $ whnf f (1000,1000)
              ]

--main = defaultMain [ bgroup "Ypnos" (stenBench runAvgY')
--                   , bgroup "Accelerate" (stenBench runAvgA')
--                   ]
type Result = (Double, Double, Double)

runB :: Fun -> Int -> IO Result
runB (Fun f) x = let v = do env <- measureEnvironment
                            l <- runBenchmark env (whnf f (x,x))
                            cfg <- getConfig
                            let conf = fromLJ cfgConfInterval cfg
                            let res  = fromLJ cfgResamples cfg
                            s <- liftIO $ analyseSample conf l res
                            let m = anMean s
                            return (estPoint m,
                                    estLowerBound m,
                                    estUpperBound m)

         in  withConfig defaultConfig v

makeSet :: (Int -> IO Result) -> [Int] -> IO [[String]]
makeSet f range = let tup x = do print ("Running for " ++ (show x))
                                 res <- try (f x)
                                 case res of
                                   Right (y, l, u) ->
                                     return [show x, show y, show l, show u]
                                   Left (e::CUDAException) -> tup (x+1)
                  in  mapM tup range

insert i x y = x ++ i ++ y

makeLine [] = ""
makeLine xs = foldr1 (insert ", ") xs

printCSV :: [[String]] -> String
printCSV lls = foldr (insert "\n") "" (map makeLine lls)

type FunS = String
type ImplS = String

data Fun where
  Fun :: ((Int,Int) -> b) -> Fun

getFun :: FunS -> ImplS -> Fun
getFun "avg" "gpu" = Fun avgGPU
getFun "avg" "cpu" = Fun avgCPU
getFun "life" "gpu" = Fun lifeGPU
getFun "life" "cpu" = Fun lifeCPU
getFun "id" "gpu" = Fun idGPU
getFun "sum" "gpu" = Fun sumGPU
getFun "sum" "cpu" = Fun sumCPU

main = do [function, impl, begin, step, end, filename] <- getArgs
          let fun = getFun function impl
          let b = read begin :: Int
          let s = read step :: Int
          let e = read end :: Int

          a <- makeSet (runB fun) ([b, s.. e])
          let ca = printCSV a
          writeFile filename ca
