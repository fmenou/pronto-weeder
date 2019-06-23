{-# LANGUAGE OverloadedStrings #-}

module Pronto
  (
    sayHello
  ) where

import           Data.Text (Text)

sayHello :: Text -> String
sayHello text = show $ text
