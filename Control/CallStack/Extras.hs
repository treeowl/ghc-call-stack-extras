{-# language RankNTypes, ScopedTypeVariables, Trustworthy #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Control.CallStack.Extras
-- Copyright   :  (c) 2018 David Feuer
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  David.Feuer@gmail.com
-- Stability   :  experimental
-- Portability :  non-portable
--
-- Currently this module only supports adding notes to call
-- stacks, but it may offer more features later.
--
-----------------------------------------------------------------------------
module Control.CallStack.Extras
  ( callStackNote
  ) where
import GHC.Stack
import GHC.Stack.Types
import Unsafe.Coerce

-- | Add a note to the current call stack. This note will be included
-- in the stack trace in case of an error. Be sure not to insert
-- notes that throw errors, or stack traces will get confusing.
--
-- === Example
--
-- Suppose we've written
--
-- @
-- f :: HasCallStack => (HasCallStack => Int -> Int -> Int) -> Int -> Int
-- f g x = callStackNote ("x = " ++ show x) $ g 5 x
-- 
-- quotTrace :: HasCallStack => Int -> Int -> Int
-- quotTrace _ 0 = error "divide by zero"
-- quotTrace x y = x `quot` y
-- @
-- 
-- calling @ print $ f quotTrace 0 @ will print something like
--
-- > Test: divide by zero
-- > CallStack (from HasCallStack):
-- >   error, called at Test.hs:11:17 in main:Main
-- >   quotTrace, called at Test.hs:14:18 in main:Main
-- >   g, called at Test.hs:8:44 in main:Main
-- >   callStackNote (x = 0)
-- >     , called at Test.hs:8:9 in main:Main
-- >   f, called at Test.hs:14:16 in main:Main
callStackNote
  :: HasCallStack
  => String
  -> (HasCallStack => a)
  -> a
callStackNote
  | Magic2 x <- unsafeCoerce (Magic boom) = x

newtype Magic a = Magic (CallStack -> String -> (CallStack -> a) -> a)
newtype Magic2 a = Magic2 (HasCallStack => String -> (HasCallStack => a) -> a)

boom :: CallStack -> String -> (CallStack -> a) -> a
boom cs s f =
    let cs' = case popCallStack cs of
           EmptyCallStack -> EmptyCallStack
           PushCallStack x y z -> PushCallStack (x ++ " (" ++ s ++ ")\n    ") y z
           r@(FreezeCallStack _) -> r
    in f cs'
