import fuji
import os

proc main() =
  with_sdk(sdk):
    let cameras = sdk.detect(ConnectionType.USB, nil)
    echo "Available cameras :", $cameras

    let camera = sdk.open(cameras[0])
    echo "features: ", $(camera)

    echo "Camera info: ", camera.info()

when isMainModule:
  main()
