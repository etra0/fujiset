import std/winlean
import ./apis

type
  # CameraList was yoinked from the SDK Header
  CameraList {.packed.} = object
    Product: array[255, char]
    SerialNo: array[255, char]
    IPAddress: array[255, char]
    Framework: array[255, char]
    valid: bool

  # DeviceInformation was yoinked from the SDK Header.
  DeviceInformation* {.packed.} = object
    Vendor: array[256, char]
    Manufacturer: array[256, char]
    Product: array[256, char]
    Firmware: array[256, char]
    DeviceType: array[256, char]
    SerialNo: array[256, char]
    Framework: array[256, char]
    DeviceId: uint8
    DeviceName: array[32, char]
    YNo: array[32, char]

# This is for debugging purposes so we don't actually care about its beauty
proc `$`*(di: DeviceInformation): string =
  template tcstr(field: untyped): untyped =
    $cast[cstring](unsafeAddr field[0])

  let smth = (
    vendor: tcstr(di.Vendor),
    manu: tcstr(di.Manufacturer),
    prod: tcstr(di.Product),
    firmw: tcstr(di.Firmware),
    dev_type: tcstr(di.DeviceType),
    # serial: tcstr(di.SerialNo),
    framework: tcstr(di.Framework),
    yno: tcstr(di.YNo),
    name: tcstr(di.DeviceName))
  result &= $smth

type Result* {.pure.} = enum
  Error = -1, Success = 0

type ConnectionType* {.pure.} = enum
  USB = 1, wifi_local = 0x10, wifi_ip = 0x20

type CameraHandle* = distinct Handle

proc `copy=`*(dest: var CameraHandle, src: CameraHandle) {.error.}

type CameraMode* {.size: sizeof(int32).} = enum
  Tether, Raw, Br, Webcam

type CameraModeFlags* = set[CameraMode]

{.push dynlib: "./bin/XAPI.dll".}

# init must be called before doing anything since initializes internal tables
# of the SDK.
proc init*(h: Handle): Result {.cdecl, importc: "XSDK_Init".}

# before calling exit, you nmust be sure you have deleted every object you
# obtained in between..
proc exit*(): Result {.cdecl, importc: "XSDK_Exit".}

proc detect*(conn_type: ConnectionType, p_interface: cstring,
    device_name: cstring, count: var int): Result {.cdecl,
    importc: "XSDK_Detect".}

proc open*(name: cstring, camera_handle: var CameraHandle,
          camera_mode: var CameraModeFlags,
          p_option: uint64 = 0): Result {.cdecl, importc: "XSDK_OpenEx".}

proc close*(camera_handle: CameraHandle) {.cdecl, importc: "XSDK_Close".}

proc device_info*(camera_handle: CameraHandle,
                 device_info: var DeviceInformation): Result {.cdecl,
                     importc: "XSDK_GetDeviceInfo".}

proc get_apis*(camera_handle: CameraHandle, device_info: var DeviceInformation,
               num_apis: var int, api_codes: ptr APICode): Result {.cdecl,
                                                                        importc:
                                                                        "XSDK_GetDeviceInfoEx".}

proc get_prop*(camera_handle: CameraHandle, api_code: int, api_param: int,
    output: var int): Result {.cdecl, importc: "XSDK_GetProp".}

proc set_prop*(camera_handle: CameraHandle, api_code: int,
    api_param: int): Result {.cdecl, importc: "XSDK_SetProp", varargs.}

proc get_error*(camera_handle: CameraHandle, api_code: var APICode,
                errno: var int): Result {.cdecl,
                    importc: "XSDK_GetErrorNumber".}


{.pop.}
