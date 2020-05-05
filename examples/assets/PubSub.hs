{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

-- generated by 'Morpheus' CLI
module PubSub
  ( rootResolver,
  )
where

import Data.Morpheus.Kind (ENUM, INPUT_OBJECT, OBJECT, SCALAR, UNION)
import Data.Morpheus.Types
  ( Event (..),
    GQLRootResolver (..),
    GQLScalar (..),
    GQLType (..),
    IOMutRes,
    IORes,
    IOSubRes,
    ScalarValue (..),
    SubRootRes,
    toMutResolver,
  )
import Data.Text (Text)
import GHC.Generics (Generic)

data Channel
  = Channel -- ChannelA | ChannelB

data Content
  = Content -- ContentA Int | ContentB String

rootResolver :: GQLRootResolver IO Channel Content Query Mutation Subscription
rootResolver =
  GQLRootResolver
    { queryResolver = resolveQuery,
      mutationResolver = resolveMutation,
      subscriptionResolver = resolveSubscription
    }

---- GQL Query -------------------------------
data Query = Query
  { deity :: ArgDeity -> IORes Deity,
    character :: ArgCharacter -> IORes Character,
    hero :: () -> IORes Human
  }
  deriving (Generic)

data ArgDeity = ArgDeity
  { name :: Maybe [Maybe [Maybe [[Maybe [Text]]]]],
    mythology :: Maybe Text
  }
  deriving (Generic)

data ArgCharacter = ArgCharacter
  { characterID :: Text,
    age :: Maybe Int
  }
  deriving (Generic)

instance GQLType Query where
  type KIND Query = OBJECT

resolveQuery :: IORes Query
resolveQuery = return Query {deity = const resolveDeity, character = const resolveCharacter, hero = const resolveHuman}

---- GQL Mutation -------------------------------
data Mutation = Mutation
  { createDeity :: ArgCreateDeity -> IOMutRes Channel Content Deity,
    createCharacter :: ArgCreateCharacter -> IOMutRes Channel Content Character
  }
  deriving (Generic)

data ArgCreateDeity = ArgCreateDeity
  { deityName :: Maybe [Maybe [Maybe [[Maybe [Text]]]]],
    deityMythology :: Maybe Text
  }
  deriving (Generic)

data ArgCreateCharacter = ArgCreateCharacter
  { charRealm :: Realm,
    charMutID :: Text
  }
  deriving (Generic)

instance GQLType Mutation where
  type KIND Mutation = OBJECT

resolveMutation :: IOMutRes Channel Content Mutation
resolveMutation =
  return
    Mutation
      { createDeity = const $ toMutResolver [Event {channels = [Channel], content = Content}] resolveDeity,
        createCharacter = const $ toMutResolver [Event {channels = [Channel], content = Content}] resolveCharacter
      }

---- GQL Subscription -------------------------------
data Subscription = Subscription
  { newDeity :: () -> IOSubRes Channel Content Deity,
    newCharacter :: () -> IOSubRes Channel Content Character
  }
  deriving (Generic)

instance GQLType Subscription where
  type KIND Subscription = OBJECT

resolveSubscription :: SubRootRes IO Channel Subscription
resolveSubscription =
  return
    Subscription
      { newDeity = const $ Event {channels = [Channel], content = const resolveDeity},
        newCharacter = const $ Event {channels = [Channel], content = const resolveCharacter}
      }

---- GQL City -------------------------------
data City
  = Athens
  | Ithaca
  | Sparta
  | Troy
  deriving (Generic)

instance GQLType City where
  type KIND City = ENUM

resolveCity :: IORes City
resolveCity = return Athens

---- GQL Power -------------------------------
data Power
  = Power
      Int
      Int

instance GQLType Power where
  type KIND Power = SCALAR

instance GQLScalar Power where
  parseValue _ = pure (Power 0 0)
  serialize (Power x y) = Int (x + y)

resolvePower :: IORes Power
resolvePower = return $ Power 0 0

---- GQL Realm -------------------------------
data Realm = Realm
  { owner :: Text,
    place :: Maybe Int
  }
  deriving (Generic)

instance GQLType Realm where
  type KIND Realm = INPUT_OBJECT

---- GQL Deity -------------------------------
data Deity = Deity
  { fullName :: () -> IORes Text,
    power :: () -> IORes Power
  }
  deriving (Generic)

instance GQLType Deity where
  type KIND Deity = OBJECT

resolveDeity :: IORes Deity
resolveDeity = return Deity {fullName = const $ return "", power = const resolvePower}

---- GQL Creature -------------------------------
data Creature = Creature
  { creatureName :: () -> IORes Text,
    realm :: () -> IORes City
  }
  deriving (Generic)

instance GQLType Creature where
  type KIND Creature = OBJECT

resolveCreature :: IORes Creature
resolveCreature = return Creature {creatureName = const $ return "", realm = const resolveCity}

---- GQL Human -------------------------------
data Human = Human
  { humanName :: () -> IORes Text,
    profession :: () -> IORes (Maybe Text)
  }
  deriving (Generic)

instance GQLType Human where
  type KIND Human = OBJECT

resolveHuman :: IORes Human
resolveHuman = return Human {humanName = const $ return "", profession = const $ return Nothing}

---- GQL Character -------------------------------
data Character
  = Character_CREATURE Creature
  | Character_DEITY Deity
  | Character_HUMAN Human
  deriving (Generic)

instance GQLType Character where
  type KIND Character = UNION

resolveCharacter :: IORes Character
resolveCharacter = Character_CREATURE <$> resolveCreature
