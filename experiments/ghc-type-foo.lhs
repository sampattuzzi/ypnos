> {-# LANGUAGE EmptyDataDecls, MultiParamTypeClasses, TypeFamilies, ConstraintKinds, FlexibleInstances, FlexibleContexts, TypeOperators #-}

> data Stencil a
> data Exp a
> data Grid a
> data Grid' a = GridNormal a | GridStencil (Exp a)

> instance Num (Exp a) where

> class RunG g arr where
>   -- type Arr Grid g x y 
>    run :: ((g a) `arr`  b) -> g a -> g b

> instance RunG Grid (->) where
>    -- type Arr Grid x y = x -> y
>    run = runCPU

> instance RunG Grid' Arr where
>    -- type Arr Grid' x y = x -> Exp y
>    run (Arr f) = run' f

> data Arr a b = Arr (a -> Exp b)

> run' :: ((Grid' a) -> Exp b) -> Grid' a -> Grid' b
> run' f = runGPU (f . conv)

> runCPU :: (Grid a -> b) -> Grid a -> Grid b
> runCPU = undefined

> conv :: Stencil a -> Grid' a
> conv = undefined

> runGPU :: (Stencil a -> Exp b) -> Grid' a -> Grid' b
> runGPU = undefined