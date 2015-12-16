module DeliveryPerson (DeliveryPerson, Location(..), initial, render, animate, navigateTo) where

import House exposing (House)
import Warehouse exposing (Warehouse)
import Sprite exposing (Sprite)
import Basics exposing (atan2)
import Pathfinder exposing (find)
import Time exposing (Time)
import AnimationState exposing (animateObject, rotateFrames)
import List exposing (head)


onTheWaySprite : Sprite
onTheWaySprite =
  { size = (2, 3)
  , offset = (0, -1)
  , frames = 24
  , src = "img/delivery-person.png"
  }


type Location
  = AtHouse House
  | AtWarehouse Warehouse
  | OnTheWay


type alias DeliveryPerson =
  { location : Location
  , position : (Float, Float)
  , route : List (Int, Int)
  , elapsed: Time
  , frames : List (Int)
  }


animate: Time -> DeliveryPerson -> DeliveryPerson
animate time deliveryPerson =
  let
    updateDeliveryPerson deliveryPerson =
      {deliveryPerson | frames = rotateFrames deliveryPerson.frames}
  in
    case deliveryPerson.location of
      OnTheWay -> animateObject 250 time updateDeliveryPerson deliveryPerson
      _ -> deliveryPerson

initial : (Int, Int) -> DeliveryPerson
initial position =
  { location = OnTheWay
  , position = (toFloat (fst position), toFloat (snd position))
  , route = [(0, 0)]
  , elapsed = 0
  , frames = [0, 1, 2]
  }


calculateDirection : (Float, Float) -> Int
calculateDirection (x, y) =
  (2 + round (atan2 y x * 4 / pi)) % 8


direction : DeliveryPerson -> Int
direction deliveryPerson =
  case deliveryPerson.route of
    first :: rest -> calculateDirection
      ( toFloat (fst first) - fst deliveryPerson.position
      , toFloat (snd first) - snd deliveryPerson.position
      )
    _ -> 0


render : DeliveryPerson -> List Sprite.Box
render deliveryPerson =
  case deliveryPerson.location of
    OnTheWay ->
      [ { sprite = onTheWaySprite
        , position =
            ( floor (fst deliveryPerson.position)
            , floor (snd deliveryPerson.position)
            )
        , layer = 2
        , frame =  direction deliveryPerson * 3 + Maybe.withDefault 0 (head deliveryPerson.frames)
        , attributes = []
        }
      ]
    _ -> []


navigationStart : DeliveryPerson -> (Int, Int)
navigationStart deliveryPerson = (0, 0)


navigateTo : (Int, Int) -> List (Int, Int) -> (Int, Int) -> DeliveryPerson -> DeliveryPerson
navigateTo gridSize obstacles destination deliveryPerson =
  let
    start = navigationStart deliveryPerson
  in
    { deliveryPerson |
        route = Pathfinder.find gridSize obstacles start destination
    }
