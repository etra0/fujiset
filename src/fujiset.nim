import fuji

proc main() =
  let sdk: Sdk = init()
  let cameras = sdk.detect(USB, nil)
  echo "Available cameras :", $cameras

  let camera = sdk.open(cameras[0])
  echo "features: ", $(camera)
  echo "Camera info: ", camera.info()

  let apis = camera.get_apis()

  # Collect all the valid values:
  echo "-----"
  echo "Supported APIS: ", $apis
  echo "-----"

  let output = camera.get_prop(GetHighLightTone, 1)
  echo "Highlight tone: ", $output

when isMainModule:
  main()

