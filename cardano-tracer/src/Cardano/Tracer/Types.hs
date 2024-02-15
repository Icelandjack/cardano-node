{-# LANGUAGE StandaloneKindSignatures #-}

module Cardano.Tracer.Types
  ( AcceptedMetrics
  , ConnectedNodes
  , ConnectedNodesNames
  , DataPointRequestors
  , MetricsStores
  , NodeId (..)
  , NodeName
  , ProtocolsBrake
  , Registry (..)
  , HandleRegistry
  ) where

import Control.Concurrent.MVar (MVar)
import Control.Concurrent.STM.TVar (TVar)
import Data.Kind
import Data.Map.Strict (Map)
import Data.Text (Text)
import Data.Set (Set)
import Data.Bimap (Bimap)
import System.Metrics qualified as EKG
import System.IO (Handle)

import System.Metrics.Store.Acceptor (MetricsLocalStore)

import Cardano.Tracer.Configuration
import Trace.Forward.Utils.DataPoint (DataPointRequestor)

-- | Unique identifier of connected node, based on 'remoteAddress' from
--   'ConnectionId', please see 'ouroboros-network'.
newtype NodeId = NodeId Text
  deriving (Eq, Ord, Show)

type NodeName = Text

type MetricsStores = (EKG.Store, TVar MetricsLocalStore)

-- | We have to create EKG.Store and MetricsLocalStore
--   to keep all the metrics accepted from the node.
type AcceptedMetrics = TVar (Map NodeId MetricsStores)

-- | We have to store 'DataPointRequestor's to be able
--   to ask particular node for some 'DataPoint's.
type DataPointRequestors = TVar (Map NodeId DataPointRequestor)

-- | This set contains ids of currently connected nodes.
--   When the node is connected, its id will be added to this set,
--   and when it is disconnected, its id will be deleted from this set.
--   So, 'ConnectedNodes' is used as a "source of truth" about currently
--   connected nodes.
type ConnectedNodes = TVar (Set NodeId)

-- | We have to map node's id to its name (received with 'NodeInfo').
type ConnectedNodesNames = TVar (Bimap NodeId NodeName)

-- | The flag we use to stop the protocols from their acceptor's side.
type ProtocolsBrake = TVar Bool

type    Registry :: Type -> Type -> Type
newtype Registry a b = Registry { getRegistry :: MVar (Map a b) }

type HandleRegistry :: Type
type HandleRegistry = Registry (NodeName, LoggingParams) (Handle, FilePath)
