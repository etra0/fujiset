import fuji
import std/strutils

proc main() =
  let sdk: Sdk = init()
  let cameras = sdk.detect(USB)

  let camera = sdk.open(cameras[0])
  echo "features: ", $(camera)
  echo "Camera info: ", camera.info()

  let apis = camera.get_apis()
  echo "Supported apis: ", $(apis)

  const requested_api = GetFilmSimulationMode
  if apis.contains(requested_api):
    echo "requested_api is supported, getting the prop..."
    try:
      let output = camera.get_prop(GetGrainEffect, 1)
      echo "Result: ", $output

      # echo "Setting provia"
      # camera.set_prop(SetFilmSimulationMode, 1, 1)
    except:
      echo "Last error: ", camera.get_error()

when isMainModule:
  main()

