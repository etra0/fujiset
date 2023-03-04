include "./fuji/defines.nim"
import os

type Sdk = object


proc init*(): Sdk =
  if init(0) != Result.Complete:
    raise newException(IOError, "Couldn't init SDK")

# I think this shouldn't be necessary.
proc `=copy`*(dest: var Sdk, source: Sdk) {.error.}

# Handy wrapper to make sure you're doing stuff with the SDK initializated and
# destroyed for you.
template with_sdk*(name: untyped, body: untyped) =
  var name: Sdk = init()
  block:
    body
  echo "Closing api"
  if exit() != Complete:
    raise newException(IOError, "Couldn't close the SDK")

# detect returns a sequence with the available cameras. According to the SDK,
# we can either ask them by their name or with the templated string
# ENUM:<index>, since I couldn't found any way to query all names of the
# cameras, I resorted to just return a list with the templated strings, you can
# check after which camera you got with the `camera.info()`.
proc detect*(sdk: Sdk, conn_type: ConnectionType, p_interface: cstring = nil): seq[string] =
  var count = 0
  discard detect(conn_type, p_interface, nil, count)
  for i in 0..<count:
    result.add("ENUM:" & $(i))

type
  CameraObj = object
    handle: CameraHandle
    modes*: CameraModeFlags
  Camera = ref CameraObj

proc `$`*(x: Camera): string =
  $(x.modes)

proc open*(sdk: Sdk, name: string): Camera =
  result = new CameraObj
  if open(name.cstring, result.handle, result.modes) != Result.Complete:
    raise newException(IOError, "Something went wrong")
  return result

proc info*(camera: Camera): DeviceInformation =
  discard device_info(camera.handle, result)

proc `=destroy`*(x: var CameraObj) =
  echo "Destroying camera"
  close(x.handle)
  # The SDK recommends us to sleep 600 ms before calling SDK_exit... *sigh*
  sleep(600)
