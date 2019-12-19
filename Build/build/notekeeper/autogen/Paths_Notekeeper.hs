{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_Notekeeper (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/bin"
libdir     = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/lib/x86_64-linux-ghc-8.6.5/Notekeeper-0.1.0.0-4nYyZJO0zYDFXtmuJvFAgr-notekeeper"
dynlibdir  = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/lib/x86_64-linux-ghc-8.6.5"
datadir    = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/share/x86_64-linux-ghc-8.6.5/Notekeeper-0.1.0.0"
libexecdir = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/libexec/x86_64-linux-ghc-8.6.5/Notekeeper-0.1.0.0"
sysconfdir = "/home/andrey/Documents/Progs/Haskell/Spock/Notekeeper/.stack-work/install/x86_64-linux-tinfo6/14d2c272fd0cb97534fec8b1f14cb72b4069a3b83caa9932a043a803bc760267/8.6.5/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Notekeeper_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Notekeeper_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Notekeeper_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Notekeeper_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Notekeeper_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Notekeeper_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
