import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (..)
import Task
import Time exposing (..)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL
type alias Build =
  { building: Maybe Bool
  , id: Maybe String
  , number : Int
  , result: Maybe String
  , url : String
  }

type alias Model =
  { builds : List Build
  , isLoading : Bool
  }

init : (Model, Cmd Msg)
init =
  ( {builds = [], isLoading = False}
  , Cmd.none
  )

-- UPDATE
type Msg
  = Refresh
  | UpdateBuild Build
  | UpdateBuilds (List Build)
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Refresh ->
      ({ model | isLoading = True }, fetchBuilds)

    UpdateBuild build -> (model, Cmd.none)

    UpdateBuilds builds ->
      ({ model
         | builds = builds
         , isLoading = False
       }, Cmd.none)

    FetchFail _ ->
      ({ model | isLoading = False }, Cmd.none)

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text "Builds"]
    , button [ onClick Refresh ] [ text "Refresh!" ]
    , br [] []
    , ul [] (List.map (\build -> li [] [text build.url]) model.builds)
    ]

-- SUBSCRIBPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- HTTP
fetchBuilds : Cmd Msg
fetchBuilds =
  let
    url =
      "here is the job"
  in
    Task.perform FetchFail UpdateBuilds (Http.get decodeBuilds url)

fetchBuild : String -> Cmd Msg
fetchBuild url =
  let
    api = url ++ "api/json"
  in
    Task.perform FetchFail UpdateBuild (Http.get decodeBuild url)

-- DECODERS
decodeBuild : Decoder Build
decodeBuild =
  object5 Build
    (maybe("building" := bool))
    (maybe("id" := string))
    ("number" := int)
    (maybe("result" := string))
    ("url" := string)

decodeBuilds : Decoder (List Build)
decodeBuilds =
  at ["builds"] (Json.list decodeBuild)
