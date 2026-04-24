module Domain.Wip where

class Wip a b where
    fromWip :: a -> b