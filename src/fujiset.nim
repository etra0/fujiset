import fuji
import os

proc main() =
  let sdk: Sdk = init()
  let cameras = sdk.detect(USB, nil)
  echo "Available cameras :", $cameras

  let camera = sdk.open(cameras[0])
  echo "features: ", $(camera)
  echo "Camera info: ", camera.info()

  let apis = camera.get_apis()
  echo "APIS: ", $apis

when isMainModule:
  main()

