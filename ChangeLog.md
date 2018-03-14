# Revision history for ghc-call-stack-extras

## 0.1.0.2  -- 2018-03-14

* Don't try to catch exceptions; that way leads madness.
  It should be done in `renderCallStack` in `base`, but this
  functionality isn't there (yet).

## 0.1.0.1  -- 2018-03-14

* Fix string forcing

## 0.1.0.0  -- 2018-03-14

* Start package with `callStackNote`.
